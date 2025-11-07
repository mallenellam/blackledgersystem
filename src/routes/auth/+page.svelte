<script>
  import { goto } from '$app/navigation';
  import { setSession } from '$lib/stores/authStore.js';
  import AccessGranted from '$lib/components/AccessGranted.svelte';
  import AccessDenied from '$lib/components/AccessDenied.svelte';

  const providers = ['google', 'github', 'twitch', 'azure'];
  let showAccess = false;
  let showDenied = false;

  async function fakeLogin(provider) {
    console.log(`Simulated login via ${provider}...`);

    // 20% chance of denial for demo purposes
    if (Math.random() < 0.2) {
      showDenied = true;
      return;
    }

    setSession({
      user: {
        id: 'debug-user-id-001',
        email: `${provider}@blackledger.dev`,
        provider
      }
    });

    showAccess = true;
  }

  function handleAccessComplete() {
    goto('/characters');
  }

  function handleDeniedComplete() {
    showDenied = false; // simply hide overlay for now
  }
</script>


<style>
button {
  opacity: 0;
  transform: translateY(10px);
  animation: fadeInUp 0.4s ease forwards;
}
button:nth-child(1) { animation-delay: 0.2s; }
button:nth-child(2) { animation-delay: 0.4s; }
button:nth-child(3) { animation-delay: 0.6s; }
button:nth-child(4) { animation-delay: 0.8s; }

@keyframes fadeInUp {
  to {
    opacity: 1;
    transform: translateY(0);
  }
}
</style>

<div class="crt-frame">
  <div class="crt-inner">
    <div class="crt-curvature flex flex-col items-center justify-center p-6 text-fg w-full">
      <h1 class="text-accent text-2xl glow-accent mb-6 tracking-widest animate-textflicker">
        ACCESS NODE : OAUTH
      </h1>

      <div
        class="w-full max-w-xs mt-4 space-y-4"
        style="display: flex; flex-direction: column; align-items: stretch; justify-content: center;"
      >
        {#each providers as provider}
          <button
            on:click={() => fakeLogin(provider)}
            class="w-full border border-accent text-accent px-6 py-3 text-left hover:bg-accent hover:text-bg transition-all duration-300 shadow-glow-accent uppercase tracking-widest block"
          >
            Connect with {provider}
          </button>
        {/each}
      </div>

      <p class="text-fg mt-6 opacity-80 text-sm text-center">
        Secure channel link will redirect upon authentication.
      </p>
    </div>
  </div>
  {#if showAccess}
    <AccessGranted on:complete={handleAccessComplete} />
  {/if}

  {#if showDenied}
    <AccessDenied on:complete={handleDeniedComplete} />
  {/if}
</div>
