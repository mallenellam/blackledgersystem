<script>
  import { createEventDispatcher, onMount } from 'svelte';
  const dispatch = createEventDispatcher();

  onMount(() => {
    // wait for the animation to play, then notify parent
    setTimeout(() => dispatch('complete'), 1500);
  });
</script>

<div class="access-overlay">
  <h1>ACCESS GRANTED</h1>
</div>

<style>
.access-overlay {
  position: fixed;
  inset: 0;
  display: flex;
  align-items: center;
  justify-content: center;
  background: radial-gradient(circle at center, rgba(0,255,150,0.05) 0%, rgba(0,0,0,0.9) 100%);
  color: var(--accent);
  font-family: 'Share Tech Mono', monospace;
  text-shadow: 0 0 15px var(--accent), 0 0 30px var(--accent);
  z-index: 9999;
  animation: fadeOut 1.5s ease-out forwards;
}

.access-overlay h1 {
  font-size: 2.5rem;
  letter-spacing: 0.3em;
  animation: pulse 0.6s ease-in-out infinite alternate;
}

@keyframes pulse {
  from { opacity: 0.8; transform: scale(1); }
  to { opacity: 1; transform: scale(1.05); }
}

@keyframes fadeOut {
  0% { opacity: 0; }
  10%,80% { opacity: 1; }
  100% { opacity: 0; visibility: hidden; }
}
</style>
