<script>
  import { onMount } from 'svelte';
  import { goto } from '$app/navigation';
  import { get } from 'svelte/store';
  import { supabase } from '$lib/supabaseClient';
  import { session, devMode } from '$lib/stores/authStore.js';

  let characters = [];
  let loading = true;
  let expanded = {};

  onMount(async () => {
    if (devMode) {
      characters = [
        {
          id: '1111-aaaa',
          name: 'NERO-9',
          alias: 'The Hammer',
          role: 'Enforcer',
          status: 'Active',
          combat_status: 'Stable',
          body_die_size: 10,
          mind_die_size: 6,
          soul_die_size: 8,
          heat: 5,
          notoriety: 12,
          wallet_balance: 2150,
          current_stress: 2,
          bio: 'Prototype combat synth built for war. Runs red when cornered.'
        },
        {
          id: '2222-bbbb',
          name: 'ECHO-7',
          alias: 'Ghostline',
          role: 'Infiltrator',
          status: 'Recovering',
          combat_status: 'Wounded',
          body_die_size: 6,
          mind_die_size: 10,
          soul_die_size: 8,
          heat: 3,
          notoriety: 7,
          wallet_balance: 1420,
          current_stress: 1,
          bio: 'Former network phantom. Whispered in the datastreams too long.'
        },
        {
          id: '3333-cccc',
          name: 'RAVEN-3',
          alias: 'Echo Witch',
          role: 'Net Surgeon',
          status: 'Active',
          combat_status: 'Stable',
          body_die_size: 8,
          mind_die_size: 8,
          soul_die_size: 10,
          heat: 1,
          notoriety: 4,
          wallet_balance: 980,
          current_stress: 4,
          bio: 'Street oracle. Half metal, half myth. Tunes code through prayer.'
        }
      ];
      loading = false;
    } else {
      const currentSession = get(session);
      if (!currentSession) return goto('/auth');

      const { data, error } = await supabase
        .from('characters')
        .select('*')
        .eq('user_id', currentSession.user.id);

      if (error) console.error('Error loading characters:', error);
      else characters = data;
      loading = false;
    }
  });

  function toggleExpand(id) {
    expanded[id] = !expanded[id];
  }

  function openCharacter(id) {
    goto(`/characters/${id}`);
  }

  function createCharacter() {
    goto('/characters/create');
  }
</script>

<div class="crt-frame">
  <div class="crt-inner">
    <div class="crt-curvature p-6 text-fg text-left overflow-y-auto">
      <h1 class="text-accent glow-accent text-2xl mb-6 tracking-widest text-center">
        RUNNER DOSSIERS
      </h1>

      {#if loading}
        <p class="opacity-70 animate-flicker">Decrypting character index...</p>
      {:else if characters.length > 0}
        <ul class="space-y-3">
          {#each characters as c}
            <li class="border border-accent/30 rounded-md p-3 shadow-glow hover:shadow-glow-accent transition-all duration-300">
              <!-- Header -->
              <div class="flex justify-between items-center cursor-pointer" on:click={() => toggleExpand(c.id)}>
                <div>
                  <p class="text-lg text-accent glow-accent">
                    {c.name} <span class="opacity-70 text-sm">({c.alias})</span>
                  </p>
                  <p class="text-sm opacity-70">{c.role}</p>
                </div>
                <div class="text-sm opacity-70 flex flex-col items-end">
                  <span class="uppercase">{c.status}</span>
                </div>
              </div>
              <br/>

              <!-- Expanded details -->
              <div class="expandable" class:expanded={expanded[c.id]}>
                {#if expanded[c.id]}
                  <div class="mt-3 text-sm border-t border-accent/20 pt-2 grid grid-cols-2 md:grid-cols-3 gap-2">
                    <p>BODY: <span class="text-accent">d{c.body_die_size}</span></p>
                    <p>MIND: <span class="text-accent">d{c.mind_die_size}</span></p>
                    <p>SOUL: <span class="text-accent">d{c.soul_die_size}</span></p>
                    <p>Heat: <span class="text-accent">{c.heat}</span></p>
                    <p>Notoriety: <span class="text-accent">{c.notoriety}</span></p>
                    <p>Stress: <span class="text-accent">{c.current_stress}</span></p>
                    <p>Wallet: <span class="text-accent">{c.wallet_balance} ₳</span></p>
                    <p>Combat Status: <span class="text-accent">{c.combat_status}</span></p>
                  </div>
                  <br/>
                  <p class="opacity-80 text-sm italic">{c.bio}</p>
                  <br/>
                  <div class="flex justify-end mt-4">
                    <button
                      on:click={() => openCharacter(c.id)}
                      class="border border-accent text-accent px-4 py-1 hover:bg-accent hover:text-bg transition-all duration-300 shadow-glow-accent uppercase tracking-widest text-xs"
                    >
                      Enter Dossier
                    </button>
                  </div>
                  <br/>
                {/if}
              </div>
            </li>
          {/each}
        </ul>
      {:else}
        <p class="opacity-70 text-center">No dossiers found for this user.</p>
      {/if}

      <br/>
      <div class="flex justify-center mt-8">
        <button
          on:click={createCharacter}
          class="border border-accent text-accent px-6 py-2 hover:bg-accent hover:text-bg transition-all duration-300 shadow-glow-accent uppercase tracking-widest"
        >
          Create New Character
        </button>
      </div>
    </div>
  </div>
</div>

<style>
.expandable {
  overflow: hidden;
  max-height: 0;
  opacity: 0;
  transition:
    max-height 0.5s ease-in-out,
    opacity 0.4s ease-in-out;
}
.expandable.expanded {
  max-height: 500px;
  opacity: 1;
  animation: crtFlicker 0.3s ease-in;
  filter: brightness(1.05) drop-shadow(0 0 3px var(--accent));
}
@keyframes crtFlicker {
  0%, 19%, 21%, 23%, 25%, 54%, 56%, 100% { opacity: 1 }
  20%, 24%, 55% { opacity: 0.7 }
}
</style>
