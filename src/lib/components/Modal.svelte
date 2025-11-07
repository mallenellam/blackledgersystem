<script>
  import { createEventDispatcher } from 'svelte';
  const dispatch = createEventDispatcher();

  export let title = 'INFO';
  export let body = '';
</script>

<div class="modal-overlay" on:click={() => dispatch('close')}>
  <div class="modal-content" on:click|stopPropagation>
    <h2 class="modal-title">{title}</h2>
    <div class="modal-body">
      <slot>{body}</slot>
    </div>
    <div class="modal-footer">
      <button
        class="border border-accent text-accent px-4 py-1 hover:bg-accent hover:text-bg shadow-glow-accent uppercase tracking-widest text-xs"
        on:click={() => dispatch('close')}
      >
        Close
      </button>
    </div>
  </div>
</div>

<style>
/* --- Full-screen overlay --- */
.modal-overlay {
  position: fixed;
  inset: 0;
  background: rgba(0, 0, 0, 0.8);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
  animation: fadeIn 0.3s ease-in;
}

/* --- CRT modal window --- */
.modal-content {
  position: relative;
  background: radial-gradient(circle at center, #111 0%, #000 80%);
  border: 2px solid var(--accent);
  border-radius: 0.75rem;
  box-shadow:
    0 0 20px var(--accent),
    inset 0 0 30px rgba(255, 0, 102, 0.25);
  padding: 1rem 1.25rem 1.5rem;
  width: 90%;
  max-width: 720px;
  max-height: 80vh;
  overflow-y: auto;
  font-family: 'Share Tech Mono', monospace;
  color: var(--fg);
  text-shadow: 0 0 3px var(--fg);
  animation: crtPop 0.25s ease-out;
}

/* --- Modal title --- */
.modal-title {
  text-align: center;
  color: var(--accent);
  font-size: 1.2rem;
  font-weight: bold;
  letter-spacing: 0.1em;
  margin-bottom: 0.75rem;
  text-shadow: 0 0 10px var(--accent);
}

/* --- Modal body --- */
.modal-body {
  font-size: 0.9rem;
  line-height: 1.5;
  opacity: 0.9;
  white-space: pre-wrap;
  scrollbar-width: thin;
  scrollbar-color: var(--accent) rgba(0,0,0,0.4);
}

.modal-body::-webkit-scrollbar {
  width: 8px;
}
.modal-body::-webkit-scrollbar-thumb {
  background-color: var(--accent);
  border-radius: 4px;
}

/* --- Footer --- */
.modal-footer {
  display: flex;
  justify-content: center;
  margin-top: 1rem;
}

/* --- Animations --- */
@keyframes fadeIn {
  from { opacity: 0; }
  to { opacity: 1; }
}

@keyframes crtPop {
  0% { transform: scale(0.9); opacity: 0.5; filter: brightness(0.7); }
  50% { transform: scale(1.02); filter: brightness(1.2); }
  100% { transform: scale(1); opacity: 1; }
}
</style>
