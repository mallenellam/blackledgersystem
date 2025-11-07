<script>
  import RollConsole from '$lib/components/RollConsole.svelte';
  import LedgerFeed from '$lib/components/LedgerFeed.svelte';
  import StatusBar from '$lib/components/StatusBar.svelte';
</script>

<div class="crt-frame">
  <div class="crt-inner">
    <div class="px-3 flex flex-col items-center justify-between p-4 text-fg">
      <h1 class="neon-text glow-accent text-xl tracking-widest animate-textflicker">
        BLACK LEDGER : RUNNER TERMINAL
      </h1>
<div class="flex flex-col items-center justify-center w-full h-full">
  <RollConsole />
  <LedgerFeed />
  <StatusBar />
</div>
    </div>
  </div>
</div>
