<script>
  import { createEventDispatcher, onMount } from 'svelte';
  const dispatch = createEventDispatcher();

  onMount(() => {
    // Let the animation play, then tell the parent we're done
    setTimeout(() => dispatch('complete'), 1600);
  });
</script>

<div class="access-overlay denied">
  <h1>ACCESS DENIED</h1>
</div>

<style>
.access-overlay {
  position: fixed;
  inset: 0;
  display: flex;
  align-items: center;
  justify-content: center;
  font-family: 'Share Tech Mono', monospace;
  z-index: 9999;
  color: var(--accent);
  text-shadow: 0 0 15px var(--accent), 0 0 30px var(--accent);
  background: radial-gradient(circle at center, rgba(255,0,0,0.08) 0%, rgba(0,0,0,0.9) 100%);
  animation: fadeOut 1.6s ease-out forwards;
}

.access-overlay.denied {
  color: #ff0033;
  text-shadow:
    0 0 12px #ff0033,
    0 0 25px #ff0033,
    0 0 45px #ff0033;
}

.access-overlay h1 {
  font-size: 2.5rem;
  letter-spacing: 0.25em;
  animation:
    glitch 0.3s infinite alternate,
    flicker 0.2s infinite alternate;
}

@keyframes glitch {
  0% { transform: skew(0deg); }
  50% { transform: skew(2deg, -2deg); }
  100% { transform: skew(-1deg, 1deg); }
}

@keyframes flicker {
  0% { opacity: 1; }
  50% { opacity: 0.8; }
  100% { opacity: 1; }
}

@keyframes fadeOut {
  0% { opacity: 0; }
  10%, 85% { opacity: 1; }
  100% { opacity: 0; visibility: hidden; }
}
</style>
