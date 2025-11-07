<script>
  import { createEventDispatcher, onMount } from 'svelte';
  const dispatch = createEventDispatcher();

  onMount(() => {
    setTimeout(() => dispatch('complete'), 800); // short fade
  });
</script>

<div class="disconnect-flash">
  <h1>DISCONNECTING...</h1>
</div>

<style>
.disconnect-flash {
  position: fixed;
  inset: 0;
  display: flex;
  align-items: center;
  justify-content: center;
  background: radial-gradient(circle at center, rgba(255,0,102,0.05) 0%, rgba(0,0,0,0.95) 100%);
  color: var(--accent);
  font-family: 'Share Tech Mono', monospace;
  z-index: 9999;
  animation: fadeOut 0.8s ease-in forwards;
}

.disconnect-flash h1 {
  font-size: 1.8rem;
  letter-spacing: 0.2em;
  text-shadow: 0 0 10px var(--accent), 0 0 25px var(--accent);
  animation: flicker 0.15s infinite alternate;
}

@keyframes flicker {
  0% { opacity: 0.85; }
  100% { opacity: 1; }
}

@keyframes fadeOut {
  0% { opacity: 0; }
  10%,70% { opacity: 1; }
  100% { opacity: 0; visibility: hidden; }
}
</style>
