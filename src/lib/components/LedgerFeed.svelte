<script>
  import { rolls } from '$lib/stores/ui';
  import { fly } from 'svelte/transition';
  import { tick } from 'svelte';

  // stores typed-out text per roll
  let visibleText = {};
  let typing = false;

  // whenever rolls update, animate newest one
  $: if ($rolls.length) {
    const latest = $rolls[$rolls.length - 1];
    if (!visibleText[latest.timestamp]) {
      typeOut(latest.timestamp, latest.narration);
    }
  }

  async function typeOut(id, text) {
    if (typing) return;
    typing = true;
    visibleText[id] = '';
    for (let i = 0; i < text.length; i++) {
      visibleText[id] = text.slice(0, i + 1);
      await tick();
      await new Promise(r => setTimeout(r, 50 + Math.random() * 40)); // speed
    }
    typing = false;
  }
</script>

<div
  class="ledger w-full bg-black/40 border border-accent rounded-md text-sm font-mono text-fg p-3 overflow-y-auto shadow-glow"
>
  {#each $rolls as roll (roll.timestamp)}
    <div class="flex mb-1" in:fly={{ y: 10, duration: 200 }}>
      <span class="text-accent min-w-[4.5rem]">{roll.band}</span>
      <span class="flex-1 text-left text-fg opacity-80 whitespace-pre-wrap">
        <span class="crt-text">
    {#if visibleText[roll.timestamp]}
      {visibleText[roll.timestamp]}
    {:else}
      {roll.narration}
    {/if}
  </span>
        <span class:cursor-blink={typing && $rolls[$rolls.length - 1].timestamp === roll.timestamp}>_</span>
        <span class="text-fg/60"> [{roll.c}/{roll.e}]</span>
      </span>
    </div>
  {/each}
</div>

<style>
.ledger {
  height: 300px;
  margin-top: 0.75rem;
  margin-bottom: 0.5rem;
  text-align: left;
  line-height: 1.4;
  border-radius: 0.5rem;
  box-shadow:
    inset 0 0 20px rgba(0, 255, 170, 0.08),
    0 0 20px rgba(255, 0, 102, 0.4);
  position: relative;
}
.ledger::before {
  content: "";
  position: absolute;
  inset: 0;
  border-radius: inherit;
  pointer-events: none;
  box-shadow: inset 0 0 30px rgba(0, 255, 170, 0.12);
}

/* blinking cursor */
@keyframes blink {
  0%, 50% { opacity: 1; }
  51%, 100% { opacity: 0; }
}
.cursor-blink {
  display: inline-block;
  animation: blink 1s step-end infinite;
}

/* --- Active typing shimmer --- */
.crt-text {
  position: relative;
  display: inline-block;
  animation: crt-glow 2s linear infinite;
  background: repeating-linear-gradient(
    to bottom,
    rgba(255,255,255,0.04) 0px,
    rgba(0,0,0,0.1) 2px,
    rgba(0,0,0,0.2) 3px
  );
  -webkit-background-clip: text;
  background-clip: text;
  color: transparent;
  mix-blend-mode: screen;
}

/* subtle sweep of brightness across letters */
@keyframes crt-glow {
  0% {
    filter: brightness(0.95) contrast(110%) saturate(120%);
    text-shadow: 0 0 1px #00ffcc44, 0 0 2px #00ffcc22;
  }
  50% {
    filter: brightness(1.1) contrast(130%) saturate(150%);
    text-shadow: 0 0 2px #00ffcc66, 0 0 4px #ff006633;
  }
  100% {
    filter: brightness(0.95) contrast(110%) saturate(120%);
    text-shadow: 0 0 1px #00ffcc44, 0 0 2px #00ffcc22;
  }
}

</style>
