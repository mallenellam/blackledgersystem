<script lang="ts">
  import { page } from '$app/stores';
  import { supabase } from '$lib/supabaseClient';
  import { selectedCharacter } from '$lib/stores';
  import { onMount } from 'svelte';
  import { goto } from '$app/navigation';

  let c;
  let job;
  let summary;
  const unsubscribe = selectedCharacter.subscribe(v => c = v);
  $: jobId = $page.params.id;

  async function loadJobSummary() {
    const { data, error } = await supabase
      .from('jobs')
      .select('id,title,reward_credits,risk_tier,fixer_id,fixers(name)')
      .eq('id', jobId)
      .single();

    if (!error) job = data;

    // Optional: fetch aggregated roll log
    const { data: rolls } = await supabase
      .from('roll_events')
      .select('band')
      .eq('job_id', jobId);

    const clean = rolls?.filter(r => r.band === 'CLEAN').length ?? 0;
    const crash = rolls?.filter(r => r.band === 'CRASH').length ?? 0;

    summary = { clean, crash };
  }

  onMount(async () => {
    if (!c) goto('/characters');
    await loadJobSummary();
  });

  function backToDashboard() {
    goto('/dashboard');
  }
</script>

<div class="min-h-screen bg-black text-cyan-200 flex flex-col items-center justify-center p-8">
  {#if job}
    <h1 class="text-3xl text-green-400 mb-2 tracking-wider">MISSION COMPLETE</h1>
    <h2 class="text-xl mb-4">{job.title}</h2>

    <div class="text-center mb-6">
      <p>Fixer: {job.fixers?.name}</p>
      <p>Tier {job.risk_tier} — Reward: {job.reward_credits}₵</p>
      <p class="text-xs opacity-60 mt-2">
        Roll outcomes: {summary.clean} clean / {summary.crash} crashes
      </p>
    </div>

    <div class="border border-cyan-700 p-4 w-80 text-sm text-cyan-300 mb-6">
      <p>Your crew cashes out. The neon fades. <br/>
         The ledger marks another success… temporarily.</p>
    </div>

    <button class="btn" on:click={backToDashboard}>Return to Dashboard</button>
  {/if}
</div>

<style>
  .btn {
    border: 1px solid cyan;
    padding: 0.75rem 2rem;
    background: rgba(0,255,255,0.1);
    text-transform: uppercase;
    transition: all 0.2s;
  }
  .btn:hover {
    background: cyan;
    color: black;
  }
</style>
