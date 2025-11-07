<script>
  export let c;
  import { createEventDispatcher } from 'svelte';
  const dispatch = createEventDispatcher();
</script>

<div class="border border-cyan-500 p-4 hover:bg-cyan-900/20 cursor-pointer"
     on:click={() => dispatch('select')}>
  <h2 class="text-xl font-bold">{c.name}</h2>
  <p>{c.persona}</p>
  <p class="opacity-60">CONTROL {c.control_die}</p>
</div>
