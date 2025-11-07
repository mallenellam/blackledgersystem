<script>
  import { onMount, createEventDispatcher } from 'svelte';
  const dispatch = createEventDispatcher();

  export let lines = [];
  export let speed = 40;
  export let pause = 400;

  let display = '';
  let started = false;
  let typing = true; // controls blinking cursor

  async function animateEntropy(hex) {
    let out = '';
    const target = hex.replace(/\[|\]/g, '');
    const len = target.length;
    for (let frame = 0; frame < 10; frame++) {
      out =
        '[' +
        Array.from({ length: len }, () =>
          Math.floor(Math.random() * 16).toString(16).toUpperCase()
        ).join('') +
        ']';
      display = display.replace(/\[[0-9A-F]+\]$/, out);
      await new Promise((r) => setTimeout(r, 50));
    }
    display = display.replace(
      /\[[0-9A-F]+\]$/,
      '[' + target + ']'
    );
  }

  async function typeAll() {
    for (const line of lines) {
      for (let i = 0; i < line.length; i++) {
        display += line[i];
        await new Promise((r) => setTimeout(r, speed));
      }
      display += '\n';

      const match = line.match(/\[0x([0-9A-F]+)\]/i);
      if (match) await animateEntropy(`[${match[1]}]`);

      await new Promise((r) => setTimeout(r, pause));
    }
    typing = false; // stop blinking
    dispatch('complete');
  }

  onMount(() => {
    if (!started && lines.length) {
      started = true;
      typeAll();
    }
  });
</script>

<pre class="whitespace-pre text-fg opacity-80 text-sm animate-flicker">{display}{#if typing}<span class="cursor">_</span>{/if}</pre>


<style>
.cursor {
  animation: blink 0.8s steps(1, start) infinite;
}
@keyframes blink {
  50% {
    opacity: 0;
  }
}
</style>
