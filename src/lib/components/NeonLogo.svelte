<script>
  export let size = 64;
</script>

<svg
  width={size}
  height={size}
  viewBox="0 0 100 100"
  fill="none"
  xmlns="http://www.w3.org/2000/svg"
>
  <circle cx="50" cy="50" r="48" stroke="#ff3ea5" stroke-width="4" />
  <text x="50%" y="55%" text-anchor="middle" fill="#00fff7" font-size="32" font-family="monospace">N</text>
</svg>

<style>
  svg {
    filter: drop-shadow(0 0 8px #ff3ea5);
  }
</style>
