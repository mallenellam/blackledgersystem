<script lang="ts">
  import { page } from '$app/stores';
  import { supabase } from '$lib/supabaseClient';
  import { selectedCharacter } from '$lib/stores';
  import { onMount } from 'svelte';
  import { goto } from '$app/navigation';

  let c;
  let upgrades = [];
  let balance = 0;
  const unsubscribe = selectedCharacter.subscribe(v => c = v);

  async function loadCharacter() {
    const { data, error } = await supabase.from('characters').select('*').eq('id', $page.params.id).single();
    if (!error) balance = data.wallet_balance;
  }

  async function purchaseUpgrade(item, cost) {
    if (balance < cost) {
      alert('Insufficient funds.');
      return;
    }

    await supabase.from('cyberware').insert([{ character_id: c.id, name: item, cost }]);
    await supabase.rpc('increment_wallet', { _character_id: c.id, _amount: -cost });
    balance -= cost;
  }

  onMount(loadCharacter);
</script>

<div class="min-h-screen bg-black text-cyan-200 p-8">
  <h1 class="text-xl mb-4">Edit Character — {$page.params.id}</h1>
  <p class="text-sm mb-4">Wallet: <span class="text-cyan-400">{balance}₵</span></p>

  <h2 class="text-lg mb-2">Upgrades Available</h2>
  <div class="grid grid-cols-2 gap-2">
    <button class="btn" on:click={() => purchaseUpgrade('Neural Lace', 2000)}>Neural Lace — 2000₵</button>
    <button class="btn" on:click={() => purchaseUpgrade('Reflex Enhancer', 1500)}>Reflex Enhancer — 1500₵</button>
    <button class="btn" on:click={() => purchaseUpgrade('Ghost Program', 1000)}>Ghost Program — 1000₵</button>
  </div>
</div>

<style>
  .btn {
    border: 1px solid cyan;
    background: rgba(0,255,255,0.1);
    padding: 0.5rem;
    text-transform: uppercase;
    transition: all 0.2s;
  }
  .btn:hover {
    background: cyan;
    color: black;
  }
</style>
