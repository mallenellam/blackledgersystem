<script lang="ts">
  import { page } from '$app/stores';
  import { supabase } from '$lib/supabaseClient';
  import { selectedCharacter } from '$lib/stores';
  import { onMount } from 'svelte';
  import { goto } from '$app/navigation';
  import { writable } from 'svelte/store';
  import RollConsole from '$lib/components/RollConsole.svelte';
  import LedgerFeed from '$lib/components/LedgerFeed.svelte';
  import StatusBar from '$lib/components/StatusBar.svelte';
  
  let c;                       // character
  let job = null;              // job data
  let intel = [];              // job intel feed
  let actions = [];            // persona actions
  let results = writable([]);  // action log
  let jobId;

  const unsubscribe = selectedCharacter.subscribe(v => c = v);
  $: jobId = $page.params.id;

  // Persona-specific actions
  const roleTemplates = {
    Hacker: [
      { label: 'Probe Network', name: 'probe_network' },
      { label: 'Spoof Credentials', name: 'spoof_credentials' },
      { label: 'Launch Intrusion Trace', name: 'launch_intrusion_trace' },
      { label: 'Share Data', name: 'share_data' }
    ],
    Face: [
      { label: 'Call Contacts', name: 'call_contacts' },
      { label: 'Negotiate Terms', name: 'negotiate_terms' },
      { label: 'Spread Rumor', name: 'spread_rumor' }
    ],
    Muscle: [
      { label: 'Scout Perimeter', name: 'scout_perimeter' },
      { label: 'Intimidate Guard', name: 'intimidate_guard' }
    ],
    Analyst: [
      { label: 'Analyze Intel', name: 'analyze_intel' },
      { label: 'Predict Pattern', name: 'predict_pattern' }
    ]
  };

  async function loadJob() {
    const { data, error } = await supabase
      .from('jobs')
      .select('*, fixers(name)')
      .eq('id', jobId)
      .single();
    if (error) console.error(error);
    job = data;
  }

  async function loadIntel() {
    const { data, error } = await supabase
      .from('intel')
      .select('*')
      .eq('job_id', jobId)
      .order('created_at', { ascending: false });
    if (!error) intel = data ?? [];
  }

  async function performAction(actionName: string) {
    const { data, error } = await supabase.rpc('perform_action', {
      _character_id: c.id,
      _job_id: jobId,
      _action_name: actionName
    });

    if (error) {
      console.error(error);
      results.update(r => [...r, { action: actionName, band: 'ERROR', note: error.message }]);
      return;
    }

    // Log result locally
    results.update(r => [...r, data]);

    // If CLEAN or SUCCESS → maybe auto insert intel
    if (['CLEAN', 'SUCCESS'].includes(data.band)) {
      await supabase.rpc('record_intel_discovery', {
        _job_id: jobId,
        _character_id: c.id,
        _intel_type: 'action_log',
        _title: `Result: ${data.action}`,
        _description: `Margin ${data.margin} (${data.band}) — actionable data recovered.`
      });
      loadIntel();
    }
  }

  onMount(async () => {
    if (!c) goto('/characters');
    actions = roleTemplates[c.persona] || [];
    await loadJob();
    await loadIntel();

    // Realtime intel updates
    supabase
      .channel(`intel_${jobId}`)
      .on(
        'postgres_changes',
        { event: 'INSERT', schema: 'public', table: 'intel', filter: `job_id=eq.${jobId}` },
        payload => {
          intel = [payload.new, ...intel];
        }
      )
      .subscribe();
  });
</script>

<!-- UI -->
<div class="min-h-screen bg-black text-cyan-200 p-8 grid grid-cols-3 gap-4">
  <!-- LEFT: DOSSIER -->
  <div class="col-span-1 border border-cyan-700 p-4">
    {#if job}
      <h1 class="text-xl font-bold">{job.title}</h1>
      <p class="text-sm opacity-60 mb-4">Fixer: {job.fixers?.name}</p>
      <p class="mb-2">{job.synopsis}</p>
      <p class="text-xs opacity-70">Entropy: {job.entropy_die}</p>
      <p class="text-xs opacity-70">Risk Tier: {job.risk_tier}</p>
    {/if}
  </div>

  <!-- CENTER: INTEL FEED -->
  <div class="col-span-1 border border-cyan-700 p-4 overflow-y-auto">
    <h2 class="text-lg mb-2">Intel Feed</h2>
    {#if intel.length > 0}
      {#each intel as item}
        <div class="mb-3 p-2 border border-cyan-800/60">
          <h3 class="text-cyan-400 text-sm">{item.title}</h3>
          <p class="text-xs opacity-70">{item.description}</p>
          <p class="text-[10px] opacity-50">Discovered by: {item.discovered_by}</p>
        </div>
      {/each}
    {:else}
      <p class="opacity-50 text-sm">No intel recovered yet.</p>
    {/if}
  </div>

  <!-- RIGHT: ACTION CONSOLE -->
  <div class="col-span-1 border border-cyan-700 p-4 flex flex-col">
    <h2 class="text-lg mb-4">Actions ({c.persona})</h2>
    <div class="flex flex-col gap-2 mb-4">
      {#each actions as a}
        <button class="btn" on:click={() => performAction(a.name)}>{a.label}</button>
      {/each}
    </div>

    <h3 class="text-sm mb-1 opacity-70">Roll Results</h3>
    <div class="overflow-y-auto h-64 border border-cyan-800/50 p-2">
      {#each $results as r (r.action + r.margin)}
        <p class="text-xs mb-1">
          <span class="text-cyan-400">{r.action}</span> →
          <span class={r.band === 'CLEAN' ? 'text-green-400' :
                        r.band === 'FAIL' ? 'text-red-400' :
                        r.band === 'CRASH' ? 'text-pink-500' : 'text-cyan-300'}>
            {r.band}
          </span>
          (C:{r.control} / E:{r.entropy})
        </p>
      {/each}
    </div>
  </div>
</div>

<style>
  .btn {
    background: rgba(0, 255, 255, 0.1);
    border: 1px solid cyan;
    padding: 0.5rem;
    font-size: 0.8rem;
    text-transform: uppercase;
    transition: all 0.2s;
  }
  .btn:hover {
    background: cyan;
    color: black;
  }
</style>

