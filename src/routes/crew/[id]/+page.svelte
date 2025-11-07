<script lang="ts">
  import { page } from '$app/stores';
  import { supabase } from '$lib/supabaseClient';
  import { selectedCharacter } from '$lib/stores';
  import { onMount } from 'svelte';
  import { goto } from '$app/navigation';
  import { writable } from 'svelte/store';

  let c;
  let crew;
  let members = [];
  let intel = [];
  let filteredIntel = [];
  let activeCategory = 'All';
  let categories = ['All', 'Blueprint', 'Rumor', 'Signal', 'Log', 'Data'];

  let heat = 0;           // actual heat
  let perceivedHeat = 0;  // crew’s subjective heat level
  let jobs = [];
  let crewId;

  const loading = writable(true);
  const unsubscribe = selectedCharacter.subscribe(v => c = v);
  $: crewId = $page.params.id;

  // Data loaders
  async function loadCrew() {
    const { data, error } = await supabase.from('crews').select('*').eq('id', crewId).single();
    if (!error) crew = data;
  }

  async function loadMembers() {
    const { data, error } = await supabase
      .from('crew_members')
      .select('character_id, role_in_crew, characters(name, persona, control_die)')
      .eq('crew_id', crewId);
    if (!error) members = data;
  }

  async function loadIntel() {
    const { data, error } = await supabase
      .from('intel')
      .select('*')
      .eq('visibility', 'crew')
      .eq('job_id', supabase.sql`ANY (SELECT job_id FROM character_jobs WHERE crew_id = ${crewId})`)
      .order('created_at', { ascending: false });
    if (!error) intel = filteredIntel = data ?? [];
  }

  async function loadHeat() {
    const { data, error } = await supabase
      .from('crew_heat_summary')
      .select('*')
      .eq('crew_id', crewId)
      .single();
    if (!error) {
      heat = data.total_heat ?? 0;
      // Perceived heat adds some in-world uncertainty
      perceivedHeat = Math.max(0, Math.round(heat * (0.7 + Math.random() * 0.4)));
    }
  }

  async function loadJobs() {
    const { data, error } = await supabase
      .from('jobs')
      .select('id,title,status,risk_tier')
      .in('id', supabase.sql`(SELECT job_id FROM character_jobs WHERE crew_id = ${crewId})`);
    if (!error) jobs = data;
  }

  function filterByCategory(cat) {
    activeCategory = cat;
    filteredIntel =
      cat === 'All'
        ? intel
        : intel.filter(i => (i.intel_type || '').toLowerCase() === cat.toLowerCase());
  }

  onMount(async () => {
    if (!c) goto('/characters');
    await loadCrew();
    await loadMembers();
    await loadIntel();
    await loadHeat();
    await loadJobs();
    loading.set(false);

    // Realtime updates
    supabase
      .channel(`crew_${crewId}`)
      .on('postgres_changes', { event: 'INSERT', schema: 'public', table: 'intel' }, payload => {
        if (payload.new.visibility === 'crew') {
          intel = [payload.new, ...intel];
          filterByCategory(activeCategory);
        }
      })
      .on('postgres_changes', { event: 'INSERT', schema: 'public', table: 'heat' }, payload => {
        if (payload.new.crew_id === crewId) {
          heat += payload.new.value;
          perceivedHeat = Math.max(0, Math.round(heat * (0.7 + Math.random() * 0.4)));
        }
      })
      .subscribe();
  });
</script>

{#if $loading}
  <div class="min-h-screen bg-black text-cyan-300 flex items-center justify-center">
    Linking crew data...
  </div>
{:else}
  <div class="min-h-screen bg-black text-cyan-200 p-8 grid grid-cols-3 gap-4">
    <!-- LEFT: CREW INFO -->
    <div class="col-span-1 border border-cyan-700 p-4">
      <h1 class="text-xl font-bold mb-2">{crew.name}</h1>
      <p class="text-sm opacity-70 mb-2">Actual Heat: <span class="text-cyan-400">{heat}</span></p>
      <p class="text-sm opacity-70 mb-4">Perceived Heat: <span class="text-amber-400">{perceivedHeat}</span></p>

      <!-- Glowing Heat Bar -->
      <div class="relative w-full h-3 bg-cyan-900 rounded overflow-hidden mb-4">
        <div
          class="absolute top-0 left-0 h-3 bg-gradient-to-r from-cyan-400 to-red-500 animate-pulse"
          style="width: {Math.min(heat, 100)}%;">
        </div>
        <div
          class="absolute top-0 left-0 h-3 bg-amber-400/50 mix-blend-screen"
          style="width: {Math.min(perceivedHeat, 100)}%;">
        </div>
      </div>

      <h2 class="text-sm opacity-70 mb-2">Crew Members</h2>
      <ul>
        {#each members as m}
          <li class="border-b border-cyan-800/50 py-1">
            <strong>{m.characters.name}</strong> — {m.characters.persona}
            <span class="text-xs opacity-60">({m.role_in_crew || 'N/A'})</span>
          </li>
        {/each}
      </ul>
    </div>

    <!-- CENTER: CREW INTEL -->
    <div class="col-span-1 border border-cyan-700 p-4 overflow-y-auto">
      <h2 class="text-lg mb-3">Crew Intel</h2>

      <!-- Category Tabs -->
      <div class="flex flex-wrap gap-2 mb-3">
        {#each categories as cat}
          <button
            class="px-2 py-1 border border-cyan-700 text-xs uppercase tracking-wide hover:bg-cyan-800/40"
            class:selected={cat === activeCategory}
            on:click={() => filterByCategory(cat)}>
            {cat}
          </button>
        {/each}
      </div>

      {#if filteredIntel.length > 0}
        {#each filteredIntel as item}
          <div class="mb-3 border border-cyan-800 p-2">
            <h3 class="text-cyan-400 text-sm">{item.title}</h3>
            <p class="text-xs opacity-70">{item.description}</p>
            <p class="text-[10px] opacity-50">Type: {item.intel_type || 'unknown'} | by {item.discovered_by}</p>
          </div>
        {/each}
      {:else}
        <p class="text-sm opacity-50">No intel in this category.</p>
      {/if}
    </div>

    <!-- RIGHT: ACTIVE JOBS -->
    <div class="col-span-1 border border-cyan-700 p-4">
      <h2 class="text-lg mb-3">Active Jobs</h2>
      {#if jobs.length > 0}
        <ul>
          {#each jobs as job}
            <li
              class="mb-2 border border-cyan-800 p-2 hover:bg-cyan-900/30 cursor-pointer"
              on:click={() => goto(`/job/${job.id}`)}>
              <strong>{job.title}</strong> — Tier {job.risk_tier}
              <p class="text-xs opacity-60">{job.status}</p>
            </li>
          {/each}
        </ul>
      {:else}
        <p class="text-sm opacity-50">No current contracts.</p>
      {/if}
    </div>
  </div>
{/if}

<style>
  button[selected] {
    background: cyan;
    color: black;
  }
</style>
