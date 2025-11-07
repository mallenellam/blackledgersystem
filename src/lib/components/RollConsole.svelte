<script>
  import { onMount } from 'svelte';
  import { rolls } from '$lib/stores/ui';
  import { responses } from '$lib/utils/narration';

  let control = 'd8';
  let entropy = 'd8';
  let flicker = false;

  function triggerFlicker() {
    flicker = true;
    setTimeout(() => (flicker = false), 300);
  }

  function mockRoll() {
    const c = Math.ceil(Math.random() * parseInt(control.slice(1)));
    const e = Math.ceil(Math.random() * parseInt(entropy.slice(1)));
    const margin = c - e;

    const band =
      margin >= 3 ? 'CLEAN' :
      margin >= 1 ? 'SUCCESS' :
      margin === 0 ? 'MIXED' :
      margin >= -2 ? 'FAIL' : 'CRASH';

    const pool = responses[band];
    const narration = pool[Math.floor(Math.random() * pool.length)];

    rolls.update(r => [...r, { c, e, margin, band, narration, timestamp: Date.now() }]);
    triggerFlicker();
  }
</script>

<div class="relative w-full max-w-lg mx-auto">
  <div class="absolute inset-0 bg-scanlines mix-blend-overlay opacity-30 pointer-events-none animate-flicker"></div>

  <div class="flex items-center justify-center gap-2 bg-black/60 border border-accent rounded-xl shadow-glow-accent p-3 transition duration-300 hover:shadow-glow animate-glowpulse"
       class:animate-flicker={flicker}>
    <label for="control-input" class="text-accent text-sm tracking-wider">CONTROL</label>
    <input
      id="control-input"
      bind:value={control}
      placeholder="d8"
      class="bg-transparent border border-accent rounded px-2 w-14 text-center text-fg focus:outline-none"
    />
    <label for="entropy-input" class="text-accent text-sm tracking-wider">ENTROPY</label>
    <input
      id="entropy-input"
      bind:value={entropy}
      placeholder="d8"
      class="bg-transparent border border-accent rounded px-2 w-14 text-center text-fg focus:outline-none"
    />
    <button on:click={mockRoll}
            class="border border-accent rounded px-3 py-1 text-accent hover:bg-accent hover:text-bg transition">
      ROLL
    </button>
  </div>
</div>
