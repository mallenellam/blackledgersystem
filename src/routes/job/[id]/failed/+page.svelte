<script lang="ts">
  import { page } from '$app/stores';
  import { supabase } from '$lib/supabaseClient';
  import { selectedCharacter } from '$lib/stores';
  import { onMount } from 'svelte';
  import { goto } from '$app/navigation';

  let c;
  let job;
  const unsubscribe = selectedCharacter.subscribe(v => c = v);
  $: jobId = $page.params.id;

  async function loadJob() {
    const { data, error } = await supabase
      .from('jobs')
      .select('id,title,fixers(name),risk_tier')
      .eq('id', jobId)
      .single();
    if (!error) job = data;
  }

  onMount(async () => {
    if (!c) goto('/characters');
    await loadJob();
  });

  function backToDashboard() {
    goto('/dashboard');
  }
</script>

<div class="min-h-screen bg-black text-red-400 flex flex-col items-center justify-center p-8">
  {#if job}
    <h1 class="text-3xl mb-2 tracking-wider">JOB FAILED</h1>
    <h2 class="text-xl mb-4">{job.title}</h2>

    <div class="text-center mb-6 text-red-300">
      <p>Fixer: {job.fixers?.name}</p>
      <p>Tier {job.risk_tier}</p>
    </div>

    <div class="border border-red-700 p-4 w-80 text-sm mb-6">
      <p>The system logged every misstep. <br/>
         Heat rises. Credits evaporate. <br/>
         The network remembers your crash.</p>
    </div>

    <button class="btn" on:click={backToDashboard}>Return to Dashboard</button>
  {/if}
</div>

<style>
  .btn {
    border: 1px solid red;
    padding: 0.75rem 2rem;
    background: rgba(255,0,0,0.1);
    text-transform: uppercase;
    transition: all 0.2s;
  }
  .btn:hover {
    background: red;
    color: black;
  }
</style>
