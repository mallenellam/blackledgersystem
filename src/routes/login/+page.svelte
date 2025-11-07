<script lang="ts">
  import { supabase } from '$lib/supabaseClient';
  import NeonLogo from '$lib/components/NeonLogo.svelte';

  async function signIn(provider: 'google' | 'github' | 'twitch') {
    await supabase.auth.signInWithOAuth({ provider });
  }
</script>

<div class="min-h-screen flex flex-col items-center justify-center bg-black text-cyan-300">
  <NeonLogo />
  <p class="text-sm mb-8 opacity-70">The ledger remembers.</p>

  <div class="flex flex-col gap-3 w-64">
    <button class="btn" on:click={() => signIn('google')}>Sign in with Google</button>
    <button class="btn" on:click={() => signIn('github')}>Sign in with GitHub</button>
    <button class="btn" on:click={() => signIn('twitch')}>Sign in with Twitch</button>
  </div>
</div>

<style>
  .btn {
    background: rgba(0, 255, 255, 0.1);
    border: 1px solid cyan;
    padding: 0.75rem;
    text-transform: uppercase;
    font-weight: 600;
    transition: all 0.2s;
  }
  .btn:hover {
    background: cyan;
    color: black;
  }
</style>
