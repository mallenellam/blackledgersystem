<script lang="ts">
  import { supabase } from '$lib/supabaseClient';
  import { selectedCharacter } from '$lib/stores';
  import { onMount } from 'svelte';
  import { goto } from '$app/navigation';

  let c;
  let jobs = [];

  const unsubscribe = selectedCharacter.subscribe(v => c = v);

  onMount(async () => {
    if (!c) goto('/characters');
    const { data } = await supabase.rpc('get_available_jobs', { _character_id: c.id });
    jobs = data ?? [];
  });
</script>

<div class="min-h-screen bg-black text-cyan-200 grid grid-cols-3 gap-4 p-8">
  <div class="col-span-1 border border-cyan-700 p-4">
    <h2 class="text-xl mb-2">{c.name} — {c.persona}</h2>
    <p>CONTROL {c.control_die}</p>
    <p>MIND {c.mind_die}</p>
    <p>BODY {c.body_die}</p>
  </div>

  <div class="col-span-2 border border-cyan-700 p-4">
    <h2 class="text-xl mb-4">Available Jobs</h2>
    {#if jobs.length === 0}
      <p>No fixer contacts yet.</p>
    {:else}
      <ul>
        {#each jobs as job}
          <li class="mb-2 hover:bg-cyan-900/30 p-2 cursor-pointer"
              on:click={() => goto(`/job/${job.job_id}`)}>
            <strong>{job.title}</strong> — Tier {job.risk_tier} — {job.reward_credits}₵
          </li>
        {/each}
      </ul>
    {/if}
  </div>
</div>
