<script lang="ts">
  import { page } from '$app/stores';
  import { supabase } from '$lib/supabaseClient';
  import { selectedCharacter } from '$lib/stores';
  import { onMount } from 'svelte';
  import { goto } from '$app/navigation';
  import { writable } from 'svelte/store';

  let c;
  let crewId;
  let haul;
  let haulItems = [];
  let crewMembers = [];
  let distribution = new Map(); // credits distribution
  const loading = writable(true);
  const notes = writable('');

  const unsubscribe = selectedCharacter.subscribe(v => c = v);
  $: crewId = $page.params.id;

  async function loadHaul() {
    const { data, error } = await supabase
      .from('hauls')
      .select('*, jobs(title, job_type, risk_tier)')
      .eq('crew_id', crewId)
      .eq('distributed', false)
      .order('created_at', { ascending: false })
      .limit(1)
      .single();
    if (!error) haul = data;
  }

  async function loadHaulItems() {
    if (!haul) return;
    const { data, error } = await supabase
      .from('haul_items')
      .select('*')
      .eq('haul_id', haul.id);
    if (!error) haulItems = data ?? [];
  }

  async function loadCrewMembers() {
    const { data, error } = await supabase
      .from('crew_members')
      .select('character_id, characters(name, wallet_balance)')
      .eq('crew_id', crewId);
    if (!error) crewMembers = data ?? [];
  }

  function adjustSplit(character_id, amount) {
    distribution.set(character_id, Number(amount));
  }

  async function claimItem(itemId, charId) {
    const { error } = await supabase
      .from('haul_items')
      .update({ assigned_to: charId })
      .eq('id', itemId);
    if (error) alert('Error assigning item: ' + error.message);
    else await loadHaulItems();
  }

  async function moveToStorage(itemId) {
    const { data, error } = await supabase
      .from('haul_items')
      .select('item_name, item_type, quantity, value_estimate')
      .eq('id', itemId)
      .single();

    if (!error && data) {
      await supabase.from('crew_storage').insert([
        {
          crew_id: crewId,
          item_name: data.item_name,
          item_type: data.item_type,
          quantity: data.quantity,
          shared: true
        }
      ]);
      await supabase.from('haul_items').delete().eq('id', itemId);
      await loadHaulItems();
    }
  }

  async function finalizeDistribution() {
    if (!haul) return;

    const total = Array.from(distribution.values()).reduce((a,b)=>a+b,0);
    if (total > haul.credits) {
      alert('Cannot distribute more than total credits.');
      return;
    }

    for (const [charId, amt] of distribution.entries()) {
      if (amt > 0) {
        await supabase.rpc('increment_wallet', { _character_id: charId, _amount: amt });
      }
    }

    await supabase.from('hauls').update({
      distributed: true,
      notes: $notes
    }).eq('id', haul.id);

    goto(`/crew/${crewId}`);
  }

  onMount(async () => {
    await loadHaul();
    await loadCrewMembers();
    await loadHaulItems();
    loading.set(false);
  });

    // in the same script section
  async function saveSuggestion() {
    await supabase.from('haul_split_suggestions').insert([
      { haul_id: haul.id, character_id: c.id, suggestion: Object.fromEntries(distribution) }
    ]);
    alert('Suggestion sent to crew leader.');
  }
</script>

{#if $loading}
  <div class="min-h-screen flex items-center justify-center bg-black text-cyan-300">
    Reconciling assets...
  </div>
{:else}
  <div class="min-h-screen bg-black text-cyan-200 p-8 grid grid-cols-3 gap-4">
    <!-- LEFT: JOB CONTEXT -->
    <div class="col-span-1 border border-cyan-700 p-4">
      {#if haul}
        <h1 class="text-xl font-bold mb-2">{haul.jobs.title}</h1>
        <p class="text-xs opacity-70 mb-2">Type: {haul.jobs.job_type}</p>
        <p class="text-xs opacity-70 mb-2">Tier: {haul.jobs.risk_tier}</p>
        <p class="text-sm mb-3">Total Credits: <span class="text-cyan-400">{haul.credits}</span></p>
        <p class="text-xs opacity-60 italic">
          “{haul.notes || 'Crew logs show a successful pull. Now the split begins.'}”
        </p>
      {:else}
        <p>No pending hauls.</p>
      {/if}
    </div>

    <!-- MIDDLE: CREDITS DISTRIBUTION -->
    <div class="col-span-1 border border-cyan-700 p-4">
      <h2 class="text-lg mb-2">Credit Distribution</h2>
      {#if crewMembers.length > 0 && haul}
        <ul>
          {#each crewMembers as m}
            <li class="mb-2 flex justify-between items-center">
              <span>{m.characters.name}</span>
              <input
                type="number"
                min="0"
                class="w-20 bg-transparent border border-cyan-700 text-right"
                placeholder="0"
                on:change={(e)=>adjustSplit(m.character_id,e.target.value)}
              />
            </li>
          {/each}
        </ul>
        <textarea
          bind:value={$notes}
          placeholder="Add final notes..."
          class="mt-4 w-full bg-transparent border border-cyan-700 p-2 text-xs text-cyan-300"
          rows="3"></textarea>
        <button class="btn mt-4 w-full" on:click={finalizeDistribution}>Finalize Haul</button>
      {/if}
    </div>

    <!-- RIGHT: LOOT PANEL -->
    <div class="col-span-1 border border-cyan-700 p-4 overflow-y-auto">
      <h2 class="text-lg mb-2">Recovered Assets</h2>
      {#if haulItems.length > 0}
        {#each haulItems as item}
          <div class="border border-cyan-800 p-2 mb-2">
            <strong class="text-cyan-400">{item.item_name}</strong>
            <p class="text-xs opacity-70">{item.item_type}</p>
            <p class="text-[10px] opacity-60">Qty: {item.quantity} | Value: {item.value_estimate}₵</p>

            {#if item.assigned_to}
              <p class="text-xs text-amber-400 mt-1">Claimed by {
                crewMembers.find(m => m.character_id === item.assigned_to)?.characters.name || 'Unknown'
              }</p>
            {:else}
              <div class="flex gap-2 mt-2">
                <select
                  class="bg-transparent border border-cyan-700 text-xs flex-1"
                  on:change={(e)=>claimItem(item.id,e.target.value)}>
                  <option value="">Assign to...</option>
                  {#each crewMembers as m}
                    <option value={m.character_id}>{m.characters.name}</option>
                  {/each}
                </select>
                <button class="text-xs border border-cyan-700 px-2" on:click={() => moveToStorage(item.id)}>
                  Store
                </button>
              </div>
            {/if}
          </div>
        {/each}
      {:else}
        <p class="text-sm opacity-50">No physical or data assets recovered.</p>
      {/if}
    </div>
    <!-- below your existing loot panel -->

<!-- HEAT / CREW SUMMARY -->
<div class="col-span-3 mt-6 border border-cyan-700 p-4">
  <h2 class="text-lg mb-2">Crew Heat Impact</h2>
  <p class="text-sm opacity-70 mb-2">Current Heat: <span class="text-cyan-400">{heat}</span></p>
  <p class="text-xs opacity-60 mb-3 italic">
    Redistribution, noise, and fixer chatter can shift heat. Finalizing the haul adjusts it automatically.
  </p>
  <button class="btn" on:click={() => supabase.rpc('apply_heat_from_haul', { _crew_id: crewId, _delta: -2 })}>
    Reduce Heat (−2)
  </button>
  <button class="btn ml-2" on:click={() => supabase.rpc('apply_heat_from_haul', { _crew_id: crewId, _delta: 3 })}>
    Increase Heat (+3)
  </button>
</div>

<!-- VOTING: only show if not leader -->
{#if !crewMembers.find(m => m.character_id === c.id)?.role_in_crew?.toLowerCase().includes('leader')}
  <div class="col-span-3 mt-6 border border-cyan-700 p-4">
    <h2 class="text-lg mb-2">Suggest Split</h2>
    <p class="text-xs opacity-60 mb-3">
      Propose your preferred credit division; the leader reviews before finalizing.
    </p>
    <button class="btn" on:click={saveSuggestion}>Submit Suggestion</button>
  </div>
{/if}

  </div>
{/if}

{#if item.item_type === 'data' && !item.decrypted}
  <button class="text-xs border border-amber-400 px-2 mt-2"
    on:click={async () => {
      const { data: newJob, error } = await supabase.rpc('spawn_followup_job', { _haul_item_id: item.id });
      if (!error) {
        await supabase.from('haul_items').update({ decrypted: true }).eq('id', item.id);
        alert('New intel mission spawned: ' + newJob);
      }
    }}>
    Decrypt / Spawn Follow-Up
  </button>
{/if}


<style>
  .btn {
    border: 1px solid cyan;
    background: rgba(0,255,255,0.1);
    padding: 0.5rem 1rem;
    text-transform: uppercase;
    transition: all 0.2s;
  }
  .btn:hover {
    background: cyan;
    color: black;
  }
</style>
