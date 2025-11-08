<script>
  import { onMount } from 'svelte';
  import { goto } from '$app/navigation';
  import { supabase } from '$lib/supabaseClient';
  import { devMode } from '$lib/stores/authStore.js';
  import Modal from '$lib/components/Modal.svelte';
  import { RULES } from '$lib/data/rules.js';
  import { tick } from 'svelte';
  import { createClient } from '@supabase/supabase-js';

  let activeModal = $state(null);
  function openModal(key) {
    activeModal = key;
  }

  let name = $state('');
  let alias = $state('');
  let role = $state('');
  let persona = $state('');
  let bio = $state('');
  let wallet_balance = $state(0);

  let skillMap = new Map(); // maps skill name -> skill_id
  let message = $state('');
  let saving = $state(false);

  // collapsible toggles
  let showIdentity = $state(true);
  let showAttributes = $state(true);
  let showSecondary = $state(true);
  let showSkills = $state(true);
  let showBackground = $state(false);
  let showWallet = $state(false);

  // Default dice
  let body_die_size = $state(8);
  let mind_die_size = $state(8);
  let soul_die_size = $state(8);    
  let selectedSkill = '';
  let chosenSkills = [];


  // --- Toast system ---
    let toast = $state(null);
    let toastTimeout = $state(null);

    function showToast(text, type = 'info', retryable = false, hold = false) {
      clearTimeout(toastTimeout);
      toast = { text, type, retryable };
      if (!hold) toastTimeout = setTimeout(() => (toast = null), 5000);
    }

    // Update toast text without closing it
    function updateToast(text, type = 'info') {
      if (!toast) toast = {};
      toast.text = text;
      toast.type = type;
    }

    // Allow retry after rollback
    function retryCreate() {
      toast = null;
      createCharacter();
    }

  function rollDie(sides) {
    return Math.floor(Math.random() * sides) + 1;
  }

  let rolling = false;

  async function rollWallet() {
    if (rolling) return; // safety guard

    rolling = true;

    // collect secondary attribute dice values
    const attrs = Object.values(secondary);
    const topTwo = attrs.sort((a, b) => b - a).slice(0, 2);

    // convert die size to sides (e.g., 8 -> d8)
    const rollResults = topTwo.map(v => rollDie(v));

    // d10 + d12 simulated by top two attributes
    const total = rollResults.reduce((a, b) => a + b, 0) * 300;

    wallet_balance = total;
    message = `Wallet generated: ${rollResults.join(' + ')} × 300 = ${wallet_balance}₳`;
  }

  const diceOptions = [6, 8, 10];

  // ---- Attribute logic for Body/Mind/Soul ----
  function adjustAttributes(changedAttr, newValue) {
    body_die_size = Math.min(Math.max(body_die_size, 6), 10);
    mind_die_size = Math.min(Math.max(mind_die_size, 6), 10);
    soul_die_size = Math.min(Math.max(soul_die_size, 6), 10);

    if (newValue === 10) {
      body_die_size = mind_die_size = soul_die_size = 6;
      if (changedAttr === 'body') body_die_size = 10;
      if (changedAttr === 'mind') mind_die_size = 10;
      if (changedAttr === 'soul') soul_die_size = 10;
    } else if (newValue === 8) {
      const maxDie = Math.max(body_die_size, mind_die_size, soul_die_size);
      if (maxDie === 10) {
        let d8count = [body_die_size, mind_die_size, soul_die_size].filter(d => d === 8).length;
        if (d8count >= 1) {
          if (changedAttr !== 'body' && body_die_size === 8) body_die_size = 6;
          if (changedAttr !== 'mind' && mind_die_size === 8) mind_die_size = 6;
          if (changedAttr !== 'soul' && soul_die_size === 8) soul_die_size = 6;
        }
      }
    }
  }

  // ---- Secondary attributes (5) ----
  const SECONDARIES = ['muscle', 'reflex', 'intellect', 'insight', 'presence'];
  const SECONDARY_OPTIONS = [6, 8, 10, 12];
  let secondary = $state({
    muscle: 6,
    reflex: 6,
    intellect: 6,
    insight: 6,
    presence: 6
  });

  function countDice(size) {
    return Object.values(secondary).filter(v => v === size).length;
  }

  const limits = { 6: 2, 8: 1, 10: 1, 12: 1 };

  function canSet(attr, value) {
    const allowed = !(countDice(value) >= limits[value] && secondary[attr] !== value);
    console.log(attr, value, 'canSet?', allowed, 'count', countDice(value));
    return allowed;
  }

  // click handler
  function setSecondary(attr, value) {
    if (secondary[attr] === value) {
      secondary[attr] = 0;
    } else if (canSet(attr, value)) {
      secondary[attr] = value;
    }

    console.log('secondary updated:', structuredClone(secondary));
  }


  // ---- Skill assignment logic ----
let skills = $state([
  { name: 'Hacking', tier: 6 },
  { name: 'Firearms', tier: 6 },
  { name: 'Negotiation', tier: 6 },
  { name: 'Stealth', tier: 6 },
  { name: 'Medicine', tier: 6 }
]);

let selectedSkills = $state([
  { name: 'Hacking', tier: 6 },
  { name: 'Firearms', tier: 6 },
  { name: 'Negotiation', tier: 6 },
  { name: 'Stealth', tier: 6 },
  { name: 'Medicine', tier: 6 }
]);

// In devMode we’ll mock the skills list; otherwise, load from Supabase

onMount(async () => {
  try {
    const SUPABASE_URL = import.meta.env.VITE_SUPABASE_URL;
    const SUPABASE_KEY = import.meta.env.VITE_SUPABASE_ANON_KEY;
    const res = await fetch(`${SUPABASE_URL}/rest/v1/skills?select=id,name,attribute,description`, {
      headers: { apikey: SUPABASE_KEY, Authorization: `Bearer ${SUPABASE_KEY}` },
    });
    const data = await res.json();

    skills = data.sort((a, b) => a.name.localeCompare(b.name));
    await tick(); // ✅ wait for re-render
    console.log('✅ Skills assigned to reactive var:', skills.length);
  } catch (err) {
    console.error('Error loading skills:', err);
  }
});


    function addSkill() {
      if (!selectedSkill) return;
      const skill = JSON.parse(selectedSkill);

      // prevent duplicates
      if (chosenSkills.find(s => s.name === skill.name)) return;

      chosenSkills.push(skill);
      selectedSkill = '';
    }

    // Options & validation
    const SKILL_DICE = [6, 8];

    function setSkillDie(index, die) {
      if (selectedSkills[index].die === die) {
        selectedSkills[index].die = 0; // toggle off
      } else if (canAssignSkillDie(die)) {
        selectedSkills[index].die = die;
      }
      selectedSkills = [...selectedSkills];
    }

    function canAssignSkillDie(die) {
      const count = selectedSkills.filter(s => s.die === die).length;
      if (die === 6) return count < 3;
      if (die === 8) return count < 2;
      return false;
    }

    function countSkillDice(die) {
      return selectedSkills.filter(s => s.die === die).length;
    }

  // ---- Save character ----
  async function createCharacter() {
  if (!name.trim()) {
    message = 'Name is required.';
    showToast('Name is required.', 'error');
    return;
  }

  const { data: { user }, error } = await supabase.auth.getUser();

  saving = true;
  showToast('Initializing dossier...', 'info', false, true);

  const SUPABASE_URL = import.meta.env.VITE_SUPABASE_URL;
  const SUPABASE_KEY = import.meta.env.VITE_SUPABASE_ANON_KEY;
  const headers = {
    'apikey': SUPABASE_KEY,
    'Authorization': `Bearer ${SUPABASE_KEY}`,
    'Content-Type': 'application/json',
    'Prefer': 'return=representation'
  };

  const newCharacter = {
    name,
    owner_user_id: 'fd61f7e9-c12e-4e4d-81fc-61ede648ba0e',
    user_id: 'fd61f7e9-c12e-4e4d-81fc-61ede648ba0e',
    body_die_size,
    base_body_die_size: body_die_size,
    mind_die_size,
    base_mind_die_size: mind_die_size,
    soul_die_size,
    base_soul_die_size: soul_die_size,
    
    alias,
    bio,
    wallet_balance,
    created_at: new Date().toISOString()
  };

  let createdChar = null;

  try {
    // --- Step 1: Character ---
    updateToast('Writing core record...', 'info');

    if (devMode) {
      const fakeId = crypto.randomUUID();
      console.log('🧪 Mock character created:', newCharacter);
      showToast('Mock dossier generated.', 'success');
      goto(`/characters/${fakeId}/edit`);
      return;
    }

    const charRes = await fetch(`${SUPABASE_URL}/rest/v1/characters`, {
      method: 'POST',
      headers,
      body: JSON.stringify(newCharacter)
    });

    if (!charRes.ok) throw new Error(await charRes.text());
    [createdChar] = await charRes.json();

    if (createdChar?.id) {
      console.log('✅ Character created:', createdChar);
      showToast('Dossier initialized. Redirecting...', 'success');
      goto(`/characters/${createdChar.id}/edit`);
    } else {
      throw new Error('Character created, but no ID returned');
      showToast('Character created, but ID missing.', 'warning');
    }

    // --- Step 2: Attributes ---
    updateToast('Linking attributes...', 'info');
    const attrRows = Object.entries(secondary).map(([attr_key, die_size]) => ({
      character_id: createdChar.id,
      attr_key: attr_key.replace('_die_size', ''), // 👈 strip suffix,
      die_size
    }));
    const attrRes = await fetch(`${SUPABASE_URL}/rest/v1/character_attributes`, {
      method: 'POST',
      headers,
      body: JSON.stringify(attrRows)
    });
    if (!attrRes.ok) throw new Error(await attrRes.text());

    // --- Step 3: Skills ---

    updateToast('Linking skills...', 'info');
    const skillRows = selectedSkills
      .filter(s => s.skill && s.die > 0)
      .map(s => ({
        character_id: createdChar.id,
        skill_id: s.skillId,
        die_size: s.die,
        skill_name: s.skill?.name ?? '',
      }))
      .filter(r => r.skill_id);

    if (skillRows.length) {
      const skillRes = await fetch(`${SUPABASE_URL}/rest/v1/character_skills`, {
        method: 'POST',
        headers,
        body: JSON.stringify(skillRows)
      });
      if (!skillRes.ok) throw new Error(await skillRes.text());
    }

    // --- Step 4: Success ---
    updateToast('Upload complete.', 'success');
    message = 'Character dossier successfully created.';
    goto(`/characters/${createdChar.id}/edit`);

  } catch (err) {
    console.error('Creation error:', err);
    updateToast('Dossier initialized. Redirecting...', 'success');

    if (createdChar?.id) {
      try {
        await fetch(`${SUPABASE_URL}/rest/v1/characters?id=eq.${createdChar.id}`, {
          method: 'DELETE',
          headers
        });

        updateToast('Rollback complete — retry?', 'error', true);
      } catch (rollbackErr) {
        console.error('Rollback failed:', rollbackErr);
        showToast('Rollback failed. Manual cleanup required.', 'error', true);
      }
    } else {
      showToast('Character creation failed.', 'error', true);
    }
  } finally {
    saving = false;
  }
}
</script>

<div class="crt-frame">
  <div class="crt-inner">
    <div class="crt-curvature overflow-y-auto max-h-[85vh] p-6 text-fg text-sm font-mono leading-relaxed">
      <h1 class="text-accent text-lg glow-accent mb-3 tracking-widest">CREATE NEW DOSSIER</h1>

      <!-- IDENTITY -->
      <div class="collapsible">
        <h2 class="section-title" onclick={() => (showIdentity = !showIdentity)}>
          IDENTITY {showIdentity ? '▼' : '▶'}
        </h2>
        {#if showIdentity}
          <div class="fadein ml-2 space-y-3 mt-2">
            <div><label class="label">Name</label><input bind:value={name} class="input-line" /></div>
            <div><label class="label">Alias</label><input bind:value={alias} class="input-line" /></div>
          </div>
        {/if}
      </div>

      <!-- CORE ATTRIBUTES -->
      <div class="collapsible">
        <div class="flex items-center justify-between">
          <h2
            class="section-title cursor-pointer"
            onclick={() => (showAttributes = !showAttributes)}
          >
            ATTRIBUTES {showAttributes ? '▼' : '▶'}
          </h2>

          <button
            onclick={(e) => {
              e.stopPropagation();
              openModal('attributes');
            }}
            class="info-btn ml-3"
          >
            INFO
          </button>
        </div>


        {#if showAttributes}
          <div class="fadein ml-2 mt-2 grid grid-cols-3 gap-4">
            <div>
              <label class="label">Body</label>
              <select bind:value={body_die_size} class="input-line" onchange={(e)=>adjustAttributes('body', +e.target.value)}>
                {#each diceOptions as d}<option value={d}>d{d}</option>{/each}
              </select>
            </div>
            <div>
              <label class="label">Mind</label>
              <select bind:value={mind_die_size} class="input-line" onchange={(e)=>adjustAttributes('mind', +e.target.value)}>
                {#each diceOptions as d}<option value={d}>d{d}</option>{/each}
              </select>
            </div>
            <div>
              <label class="label">Soul</label>
              <select bind:value={soul_die_size} class="input-line" onchange={(e)=>adjustAttributes('soul', +e.target.value)}>
                {#each diceOptions as d}<option value={d}>d{d}</option>{/each}
              </select>
            </div>
          </div>
          <p class="text-xs opacity-70 mt-2 ml-1">
            One may be <span class="text-accent">d10</span>, forcing others to <span class="text-accent">d6</span>.  
            One may then rise to <span class="text-accent">d8</span>.
          </p>
        {/if}
      </div>

      <!-- SECONDARY ATTRIBUTES -->
      <div class="collapsible">
        <h2 class="section-title" onclick={() => (showSecondary = !showSecondary)}>
          SECONDARY ATTRIBUTES {showSecondary ? '▼' : '▶'}
        </h2>
        {#if showSecondary}
          <div class="fadein ml-2 mt-2 grid grid-cols-2 md:grid-cols-3 gap-4">
            {#each SECONDARIES as attr}
              <div>
                <label class="label">{attr}</label>
                <div class="flex gap-1 mt-1">
                  {#each SECONDARY_OPTIONS as opt}
                    <button
                      class="dice-btn px-2 py-1 border border-accent/40 text-xs transition-all duration-200 rounded-sm"
                      class:selected={secondary[attr] === opt}
                      onclick={() => setSecondary(attr, opt)}
                      disabled={!canSet(attr, opt) && secondary[attr] !== opt}
                    >
                      d{opt}
                    </button>
                  {/each}
                </div>
              </div>
            {/each}
          </div>

          <div class="text-xs opacity-80 mt-3 ml-1 font-mono flex flex-wrap gap-3">
            <span class="text-accent">d6:</span> {countDice(6)}/2
            <span class="text-accent">d8:</span> {countDice(8)}/1
            <span class="text-accent">d10:</span> {countDice(10)}/1
            <span class="text-accent">d12:</span> {countDice(12)}/1
          </div>

          <p class="text-xs opacity-70 mt-2 ml-1">
            Assign exactly 2×<span class="text-accent">d6</span>, 1×<span class="text-accent">d8</span>,
            1×<span class="text-accent">d10</span>, and 1×<span class="text-accent">d12</span>.
          </p>
        {/if}
      </div>

      <!-- SKILLS -->
      <div class="collapsible">
        <h2 class="section-title" onclick={() => (showSkills = !showSkills)}>
          SKILLS {showSkills ? '▼' : '▶'}
        </h2>

        {#if showSkills}
          <div class="fadein ml-2 mt-2 space-y-3">
          <!-- debug block -->
          <p class="text-xs text-accent mt-2">
            Skills available: {skills.length}
          </p>
            {#each selectedSkills as entry, i (skills.length + '-' + i)}
              <div class="grid grid-cols-2 gap-3">
                <select
                  class="input-line"
                  bind:value={entry.skillId}
                  onchange={(e) => {
                    const id = e.target.value;
                    const skill = skills.find((s) => s.id === id);
                    selectedSkills[i] = { ...selectedSkills[i], skill, skillId: id };
                    selectedSkills = [...selectedSkills];
                  }}
                >
                  <option value="">Select skill</option>
                  {#if skills.length}
                    {#each skills as skill}
                      <option
                        value={skill.id}
                        disabled={selectedSkills.some(
                          (s, idx) => idx !== i && s.skill?.id === skill.id
                        )}
                      >
                        {skill.name} ({skill.attribute}) – {skill.description}
                      </option>
                    {/each}
                  {:else}
                    <option disabled>Loading skills...</option>
                  {/if}
                </select>

                <div class="flex gap-2">
                  {#each SKILL_DICE as die}
                    <button
                      class="dice-btn px-2 py-1 border border-accent/40 text-xs transition-all duration-200 rounded-sm"
                      class:selected={entry.die === die}
                      onclick={() => setSkillDie(i, die)}
                      disabled={!canAssignSkillDie(die)}
                    >
                      d{die}
                    </button>
                  {/each}

                </div>
              </div>
            {/each}
  

            <!-- Tracker -->
            <div class="text-xs opacity-80 mt-3 font-mono flex gap-3">
              <span class="text-accent">d6:</span> {countSkillDice(6)}/3
              <span class="text-accent">d8:</span> {countSkillDice(8)}/2
            </div>

            <p class="text-xs opacity-70 mt-1 ml-1">
              Assign exactly 3×<span class="text-accent">d6</span> and 2×<span class="text-accent">d8</span> across five skills.
            </p>
          </div>
        {/if}
      </div>


      <!-- BACKGROUND -->
      <div class="collapsible">
        <h2 class="section-title" onclick={() => (showBackground = !showBackground)}>
          BACKGROUND {showBackground ? '▼' : '▶'}
        </h2>
        {#if showBackground}
          <div class="fadein ml-2 mt-2">
            <label class="label">Bio</label>
            <textarea bind:value={bio} rows="3" class="input-line resize-y"></textarea>
          </div>
        {/if}
      </div>

      <!-- WALLET -->
      <div class="collapsible">
        <h2 class="section-title" onclick={() => (showWallet = !showWallet)}>
          WALLET {showWallet ? '▼' : '▶'}
        </h2>
        <br/>
        {#if showWallet}
          <div class="fadein ml-2 mt-2 space-y-2">
            <div class="flex items-center gap-3">
              <button
                onclick={rollWallet}
                class="border border-accent text-accent px-4 py-1 hover:bg-accent hover:text-bg transition-all duration-300 shadow-glow-accent uppercase tracking-widest text-xs"
                disabled={rolling}
              >
                {rolling ? 'ROLLING...' : 'ROLL WALLET'}
              </button>
              <span class="text-accent font-mono">{wallet_balance} ₳</span>
            </div>

            <p class="text-xs opacity-70 ml-1">
              Uses your two highest secondary attributes (d10 + d12 × 300) to determine starting funds.
            </p>
          </div>
        {/if}
      </div>


      <br/>
      <div class="mt-6 flex justify-center">
        <button
          onclick={createCharacter}
          class="border border-accent text-accent px-6 py-2 hover:bg-accent hover:text-bg transition-all duration-300 shadow-glow-accent uppercase tracking-widest"
          disabled={saving}
        >
          {saving ? 'CREATING...' : 'CREATE CHARACTER'}
        </button>
      </div>

      {#if message}
        <p class="text-center mt-3 opacity-80">{message}</p>
      {/if}

      {#if activeModal}
        <Modal
          title={RULES[activeModal].title}
          body={RULES[activeModal].body}
          on:close={() => (activeModal = null)}
        />
      {/if}
    </div>
  </div>
  {#if toast}
    <div
      class="fixed bottom-6 right-6 px-5 py-3 rounded-md text-sm font-mono shadow-lg z-50 transition-all duration-300"
      class:toast-success={toast.type === 'success'}
      class:toast-error={toast.type === 'error'}
      class:toast-info={toast.type === 'info'}
    >
      <span>{toast.text}</span>
      {#if toast.retryable}
        <button onclick={retryCreate} class="ml-3 underline hover:text-accent">Retry</button>
      {/if}
    </div>
  {/if}
</div>

<style>
.label { color: var(--accent); text-transform: uppercase; font-size: 0.75rem; letter-spacing: 0.05em; }
.input-line {
  width: 100%; background: transparent;
  border: 1px solid rgba(255, 0, 102, 0.5);
  color: var(--fg);
  padding: 0.4rem 0.6rem;
  font-family: 'Share Tech Mono', monospace;
  font-size: 0.9rem; outline: none;
  transition: border-color 0.3s ease, box-shadow 0.3s ease;
}
.input-line:focus { border-color: var(--accent); box-shadow: 0 0 8px var(--accent); }
.section-title {
  color: var(--accent); font-weight: bold; text-transform: uppercase;
  text-shadow: 0 0 5px var(--accent); cursor: pointer; transition: color 0.3s ease;
}
.section-title:hover { color: #ff3388; text-shadow: 0 0 8px var(--accent); }
.collapsible { border-top: 1px solid rgba(255, 0, 102, 0.25); padding-top: 0.4rem; margin-top: 0.5rem; }
.fadein { animation: flicker-in 0.3s ease-in; }
@keyframes flicker-in { 0%,19%,21%,23%,25%,54%,56%,100%{opacity:1;}20%,24%,55%{opacity:0.6;} }

button.selected {
  background-color: var(--accent);
  color: var(--bg);
  border-color: var(--accent);
  box-shadow: 0 0 6px var(--accent);
}

button:not(.selected):hover {
  background-color: rgba(255, 0, 102, 0.2);
  box-shadow: 0 0 4px rgba(255, 0, 102, 0.3);
}

button:disabled {
  opacity: 0.3;
  cursor: not-allowed;
  box-shadow: none;
  filter: brightness(0.8);
}

/* --- CRT Dice Button Styling --- */
.dice-btn {
  background-color: rgba(10, 10, 14, 0.8);
  color: var(--fg);
  border: 1px solid rgba(255, 0, 102, 0.3);
  box-shadow: 0 0 6px rgba(78, 227, 182, 0.15);
  transition: all 0.2s ease;
}

/* standby glow (unselected) */
.dice-btn:not(.selected):not(:disabled) {
  background-color: rgba(0, 255, 170, 0.05);
  animation: standbyGlow 3s ease-in-out infinite;
}

/* selected (active neon hot pink) */
.dice-btn.selected {
  background-color: var(--accent);
  color: var(--bg);
  border-color: var(--accent);
  box-shadow: 0 0 8px var(--accent), 0 0 15px var(--accent);
}

/* hover state */
.dice-btn:not(.selected):hover {
  background-color: rgba(255, 0, 102, 0.2);
  box-shadow: 0 0 6px rgba(255, 0, 102, 0.4);
}

/* disabled when limits reached */
.dice-btn:disabled {
  opacity: 0.25;
  cursor: not-allowed;
  filter: brightness(0.6);
  box-shadow: none;
}

/* subtle cyan pulse for standby dice */
@keyframes standbyGlow {
  0%, 100% {
    box-shadow: 0 0 4px rgba(78, 227, 182, 0.15);
  }
  50% {
    box-shadow: 0 0 8px rgba(78, 227, 182, 0.35);
  }
}

@keyframes walletFlash {
  0% { text-shadow: 0 0 2px var(--accent); opacity: 0.8; }
  50% { text-shadow: 0 0 10px var(--accent); opacity: 1; }
  100% { text-shadow: 0 0 2px var(--accent); opacity: 0.8; }
}

span.text-accent.font-mono {
  animation: walletFlash 1s ease-in-out;
}

.info-btn {
  display: inline-block;
  border: 1px solid var(--accent);
  color: var(--accent);
  background: transparent;
  padding: 0.15rem 0.5rem;
  font-size: 0.65rem;
  letter-spacing: 0.1em;
  text-transform: uppercase;
  font-family: 'Share Tech Mono', monospace;
  box-shadow: 0 0 4px var(--accent);
  transition: all 0.25s ease-in-out;
}

.info-btn:hover {
  background: var(--accent);
  color: var(--bg);
  box-shadow: 0 0 10px var(--accent);
  transform: translateX(2px);
}
.toast-success {
  background-color: rgba(0,255,170,0.15);
  border: 1px solid var(--accent);
  color: var(--accent);
}
.toast-error {
  background-color: rgba(255,0,102,0.15);
  border: 1px solid rgba(255,0,102,0.8);
  color: #ff6699;
}
.toast-info {
  background-color: rgba(78,227,182,0.15);
  border: 1px solid rgba(78,227,182,0.6);
  color: #4ee3b6;
}
.toast-info::after {
  content: ' ▓▒░';
  animation: dataflow 1.2s steps(3) infinite;
}
@keyframes dataflow {
  0% { content: ' ▓▒░'; }
  33% { content: ' ▒░▓'; }
  66% { content: ' ░▓▒'; }
  100% { content: ' ▓▒░'; }
}
</style>

