console.log(import.meta.env.VITE_SUPABASE_URL);

<script>
  // --- Reactive state ---
  let primary = $state({ body: 6, mind: 6, soul: 6 });
  let secondary = $state({
    muscle: 6,
    reflex: 6,
    intellect: 6,
    insight: 6,
    presence: 6
  });
  let skills = $state([
    { name: 'Hacking', tier: 6 },
    { name: 'Firearms', tier: 6 },
    { name: 'Negotiation', tier: 6 },
    { name: 'Stealth', tier: 6 },
    { name: 'Medicine', tier: 6 }
  ]);

  let selectedSkill = $state('');
  let charName = $state('');
  let error = $state('');

  const validDice = [4, 6, 8, 10, 12];

  // --- Allocation Rules ---
  function validPrimary(p) {
    const vals = Object.values(p);
    const counts = vals.reduce((acc, v) => ((acc[v] ??= 0), acc[v]++, acc), {});
    const three8 = vals.every(v => v === 8);
    const pattern = counts[10] === 1 && counts[8] === 1 && counts[6] === 1;
    return three8 || pattern;
  }

  function validSecondary(s) {
    const counts = Object.values(s).reduce((a, v) => ((a[v] ??= 0), a[v]++, a), {});
    return counts[12] === 1 && counts[10] === 1 && counts[8] === 1 && counts[6] === 2;
  }

  function validSkills(sk) {
    const counts = sk.reduce((a, s) => ((a[s.tier] ??= 0), a[s.tier]++, a), {});
    return counts[8] === 2 && counts[6] === 3;
  }

  // --- Utility ---
  function canSetPrimary(attr, die) {
    const test = { ...primary, [attr]: die };
    return validPrimary(test);
  }
  function canSetSecondary(attr, die) {
    const test = { ...secondary, [attr]: die };
    return validSecondary(test);
  }
  function canSetSkill(idx, die) {
    const test = skills.map((s, i) => (i === idx ? { ...s, tier: die } : s));
    return validSkills(test);
  }

  // --- Handlers ---
  function setPrimary(attr, die) {
    if (canSetPrimary(attr, die)) primary[attr] = die;
    else error = 'Primary allocation must be 1×d10, 1×d8, 1×d6, or 3×d8.';
  }

  function setSecondary(attr, die) {
    if (canSetSecondary(attr, die)) secondary[attr] = die;
    else error =
      'Secondary allocation must be 2×d6, 1×d8, 1×d10, 1×d12.';
  }

  function setSkill(idx, die) {
    if (canSetSkill(idx, die)) skills[idx].tier = die;
    else error = 'Skill allocation must be 2×d8 and 3×d6.';
  }

  // --- REST Submit ---
  async function createCharacter() {
    error = '';
    if (!charName) {
      error = 'Name required.';
      return;
    }
    if (!validPrimary(primary)) {
      error = 'Invalid primary attribute configuration.';
      return;
    }
    if (!validSecondary(secondary)) {
      error = 'Invalid secondary attribute configuration.';
      return;
    }
    if (!validSkills(skills)) {
      error = 'Invalid skill configuration.';
      return;
    }

    const payload = {
      name: charName,
      primary,
      secondary,
      skills
    };

    try {
      const res = await fetch('/api/characters', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload)
      });

      if (!res.ok) throw new Error(`HTTP ${res.status}`);
      console.log('Character created successfully');
    } catch (e) {
      console.error(e);
      error = 'Failed to create character.';
    }
  }
</script>

<!-- --- UI --- -->
<div class="character-creator">
  <h1>Create Character</h1>

  {#if error}
    <div class="error">{error}</div>
  {/if}

  <label>Name</label>
  <input bind:value={charName} placeholder="Enter character name" />

  <section>
    <h2>Primary Attributes</h2>
    {#each Object.entries(primary) as [attr, val]}
      <div class="attribute">
        <span>{attr.toUpperCase()}</span>
        <div class="buttons">
          {#each validDice as die}
            <button class:selected={val === die} on:click={() => setPrimary(attr, die)}>
              d{die}
            </button>
          {/each}
        </div>
      </div>
    {/each}
  </section>

  <section>
    <h2>Secondary Attributes</h2>
    {#each Object.entries(secondary) as [attr, val]}
      <div class="attribute">
        <span>{attr.toUpperCase()}</span>
        <div class="buttons">
          {#each validDice as die}
            <button class:selected={val === die} on:click={() => setSecondary(attr, die)}>
              d{die}
            </button>
          {/each}
        </div>
      </div>
    {/each}
  </section>

  <section>
    <h2>Skills</h2>
    {#each skills as skill, i}
      <div class="attribute">
        <span>{skill.name}</span>
        <div class="buttons">
          {#each [6, 8] as die}
            <button class:selected={skill.tier === die} on:click={() => setSkill(i, die)}>
              d{die}
            </button>
          {/each}
        </div>
      </div>
    {/each}
  </section>

  <button class="create" on:click={createCharacter}>
    Create Character
  </button>
</div>

<style>
  .character-creator {
    max-width: 600px;
    margin: auto;
    color: #eee;
    font-family: 'Share Tech Mono', monospace;
  }
  h1, h2 { color: #00ffc8; text-transform: uppercase; }
  .attribute { margin-bottom: 0.5rem; }
  .buttons button {
    margin: 0.25rem;
    padding: 0.4rem 0.7rem;
    background: #111;
    color: #0ff;
    border: 1px solid #0ff;
    cursor: pointer;
  }
  .buttons button.selected { background: #0ff; color: #111; }
  .error { color: #f33; margin: 0.5rem 0; }
  .create {
    margin-top: 1rem;
    padding: 0.75rem 1.5rem;
    background: #0ff;
    color: #111;
    border: none;
    text-transform: uppercase;
    font-weight: bold;
    cursor: pointer;
  }
  input {
    width: 100%;
    background: #111;
    border: 1px solid #0ff;
    color: #0ff;
    padding: 0.4rem;
    margin-bottom: 1rem;
  }
</style>
