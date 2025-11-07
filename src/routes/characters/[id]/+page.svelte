<script>
  import { onMount } from 'svelte';
  import { page } from '$app/stores';
  import { supabase } from '$lib/supabaseClient';
  import { goto } from '$app/navigation';
  import { devMode } from '$lib/stores/authStore';

  let character = null;
  let loading = true;
  let expanded = { skills: false, gear: false, cyber: false, deck: false, bio: false };

  const mockCharacters = [
    {
      id: '1111-aaaa',
      name: 'Nero-9',
      alias: 'The Butcher of Neon Alley',
      role: 'Enforcer',
      bio: 'A prototype combat synth with too much autonomy.',
      body_die: 'd10',
      mind_die: 'd6',
      soul_die: 'd8',
      heat: 2,
      notoriety: 3,
      wallet_balance: 8500,
      status: 'Active',
      gear: ['AutoShot d8', 'Reinforced Jacket', 'StimPatch x2'],
      cyberware: ['Subdermal Armor', 'Optic HUD'],
      deck: ['Daemon.SW', 'ICEpick', 'Scrambler'],
      programs: ['Counter-ICE', 'Signal Masking']
    }
  ];

  onMount(async () => {
    const id = $page.params.id;
    if (devMode) {
      character = mockCharacters.find(c => c.id === id);
      loading = false;
      return;
    }

    const { data, error } = await supabase.from('characters').select('*').eq('id', id).single();
    if (error) console.error(error);
    character = data;
    loading = false;
  });

  function toggle(key) {
    expanded[key] = !expanded[key];
  }
</script>

{#if loading}
  <div class="crt-frame"><div class="crt-inner flex items-center justify-center">LOADING...</div></div>
{:else if !character}
  <div class="crt-frame"><div class="crt-inner flex items-center justify-center">NO CHARACTER FOUND</div></div>
{:else}
  <div class="crt-frame overflow-y-auto">
    <div class="crt-inner p-4 text-fg">
      <h1 class="text-accent text-2xl glow-accent mb-2">{character.name}</h1>
      <p class="opacity-80 text-sm mb-4">{character.alias} — {character.role}</p>

      <div class="grid grid-cols-3 gap-4 text-center mb-6">
        <div><strong>BODY</strong><br/>{character.body_die}</div>
        <div><strong>MIND</strong><br/>{character.mind_die}</div>
        <div><strong>SOUL</strong><br/>{character.soul_die}</div>
      </div>

      <div class="flex justify-between mb-4 text-sm opacity-80">
        <span>Heat: {character.heat}</span>
        <span>Notoriety: {character.notoriety}</span>
        <span>Cred: ¤{character.wallet_balance}</span>
      </div>

      <div class="space-y-3">
        <Section title="ATTRIBUTES & SKILLS" keyName="skills">
          <p>[Skills block coming soon]</p>
        </Section>

        <Section title="GEAR" keyName="gear">
          <ul>{#each character.gear as g}<li>{g}</li>{/each}</ul>
        </Section>

        <Section title="CYBERWARE" keyName="cyber">
          <ul>{#each character.cyberware as c}<li>{c}</li>{/each}</ul>
        </Section>

        <Section title="CYBERDECK & PROGRAMS" keyName="deck">
          <ul>{#each character.programs as p}<li>{p}</li>{/each}</ul>
        </Section>

        <Section title="BIOGRAPHY" keyName="bio">
          <p>{character.bio}</p>
        </Section>
      </div>
    </div>
  </div>
{/if}

<!-- Inline Svelte section component -->
<script context="module">
  export function Section({ title, keyName, $$slots }) {
    let expanded = false;
    function toggle() { expanded = !expanded; }

    return {
      $$render() {
        return `
          <div class="border-t border-accent pt-2">
            <h2 class="text-accent text-lg cursor-pointer flex justify-between items-center" on:click="${toggle}">
              ${title}
              <span>${expanded ? '−' : '+'}</span>
            </h2>
            ${expanded ? `<div class="mt-2 ml-2 text-sm opacity-90">${$$slots.default ? $$slots.default({}) : ''}</div>` : ''}
          </div>
        `;
      }
    };
  }
</script>

<style>
.crt-frame {
  max-height: 80vh;
  overflow-y: auto;
  scrollbar-color: var(--accent) var(--bg);
  scrollbar-width: thin;
}
</style>
