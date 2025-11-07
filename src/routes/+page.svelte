<script>
  import { goto } from '$app/navigation';
  import { supabase } from '$lib/supabaseClient';
  import Typewriter from '$lib/components/Typewriter.svelte';

  const subsystems = [
    'BIO-METRIC MATRIX',
    'NEURAL LATTICE',
    'CRYPTOMESH ROUTER',
    'MEMETIC FIREWALL',
    'PHANTOM SOCKET',
    'SYNAPSE CACHE',
    'HAPTIC INTERFACE',
    'DECK DRIVERS',
    'LEDGER CHAINLINK',
    'ENIGMA ARCHIVE',
    'ANOMALY DETECTOR'
  ];

  function randomHex(len = 4) {
    return Array.from({ length: len }, () =>
      Math.floor(Math.random() * 16).toString(16).toUpperCase()
    ).join('');
  }

  function generateBootLog() {
    const picks = [...subsystems].sort(() => 0.5 - Math.random()).slice(0, 5);
    const log = [
      'INITIALIZING NETWORK LINK...',
      'VERIFYING IDENTITY HASH... OK'
    ];
    for (const name of picks) {
      log.push(`${name} [0x${randomHex(4)}]... OK`);
    }
    log.push('MOUNTING LEDGER PARTITIONS... OK');
    log.push('ESTABLISHING SECURE CHANNEL... OK');
    log.push('');
    log.push(`ACCESS NODE : COMPROMISED [${randomHex(8)}]`);
    log.push('Connection stable — data link secure.');
    return log;
  }

  const bootLines = generateBootLog();
  let headerDone = false;
  let typingDone = false;

  function handleHeaderComplete() {
    headerDone = true;
  }

  function handleBootComplete() {
    typingDone = true;
  }

  async function enterTerminal() {
    const { data: { session } } = await supabase.auth.getSession();

    // optional: simulate network handshake delay
    await new Promise((r) => setTimeout(r, 600));

    goto(session ? '/characters' : '/auth');
  }
</script>

<div class="crt-frame">
  <div class="crt-inner">
    <div class="crt-curvature flex flex-col items-center justify-center text-center p-6 text-fg">
      <div class="w-full max-w-xl px-6 pl-2">
        <!-- Header typing first -->
        <Typewriter
          lines={['BLACK LEDGER SYSTEM v1.0']}
          speed={40}
          pause={300}
          on:complete={handleHeaderComplete}
        />

        <!-- Boot log starts after header -->
        {#if headerDone}
          <Typewriter
            lines={bootLines}
            speed={40}
            pause={350}
            on:complete={handleBootComplete}
          />
        {/if}

        {#if typingDone}
          <div class="mt-6 text-left">
            <button
              class="border border-accent text-accent px-6 py-2 hover:bg-accent hover:text-bg transition-all duration-300 shadow-glow-accent uppercase tracking-widest btn-neon"
              on:click={enterTerminal}
            >
              Enter
            </button>
          </div>
        {/if}
      </div>
    </div>
  </div>
</div>

<style>
@keyframes pulse {
  0%, 100% { box-shadow: 0 0 10px var(--accent); }
  50% { box-shadow: 0 0 20px var(--accent); }
}
.btn-neon { animation: pulse 2s infinite; }
</style>
