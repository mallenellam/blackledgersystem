<script>
  import "../app.css"; // ensures global vars + Tailwind styles
</script>

<div class="crt-screen">
  <slot /> <!-- everything inside the terminal lives here -->
  <div class="crt-overlay"></div>
</div>

<style>
.crt-screen {
  position: relative;
  min-height: 100vh;
  background: var(--bg);
  color: var(--fg);
  display: flex;
  flex-direction: column;
  justify-content: flex-start;
  align-items: center;
  padding-top: 2rem;
  overflow: hidden;
}

/* translucent overlay: scanlines + subtle noise */
.crt-overlay {
  pointer-events: none;
  position: absolute;
  inset: 0;
  z-index: 5;
  background:
    repeating-linear-gradient(
      rgba(255,255,255,0.04) 0px,
      rgba(0,0,0,0.1) 2px,
      rgba(0,0,0,0.2) 3px
    ),
    radial-gradient(circle at 50% 50%, rgba(255,255,255,0.03), transparent 70%);
  mix-blend-mode: overlay;
  animation:
    flicker 0.15s infinite,
    glowpulse 3s ease-in-out infinite;
  opacity: 0.6;
  filter: contrast(120%) brightness(1.1);
}

/* tiny random flicker */
@keyframes flicker {
  0%, 19%, 21%, 23%, 25%, 54%, 56%, 100% {
    opacity: 0.6;
  }
  20%, 24%, 55% {
    opacity: 0.4;
  }
}

/* slow breathing glow */
@keyframes glowpulse {
  0%,100% { filter: brightness(1.05) saturate(110%); }
  50%     { filter: brightness(1.2)  saturate(140%); }
}
</style>
