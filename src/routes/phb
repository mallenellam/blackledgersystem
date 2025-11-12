<script>
  // Static file — you can later bind variables to generate faction data dynamically.
</script>

<style>
  @import url('https://fonts.googleapis.com/css2?family=Share+Tech+Mono&display=swap');

  body {
    font-family: 'Share Tech Mono', monospace;
    color: #d6f1ff;
    background-color: #050505;
    line-height: 1.6;
    margin: 0;
    padding: 0;
    overflow-x: hidden;
  }

  main {
    max-width: 960px;
    margin: 0 auto;
    padding: 3rem 2rem;
    position: relative;
  }

  h1, h2, h3 {
    color: #00e0ff;
    text-transform: uppercase;
    letter-spacing: 1px;
  }

  h1 {
    font-size: 2.5rem;
    text-align: center;
    margin-bottom: 1rem;
  }

  h2 {
    font-size: 1.4rem;
    margin-top: 2rem;
  }

  h3 {
    font-size: 1.1rem;
    color: #88eeff;
  }

  p, li {
    font-size: 0.95rem;
  }

  table {
    width: 100%;
    border-collapse: collapse;
    margin-top: 1rem;
    font-size: 0.9rem;
  }

  th, td {
    padding: 0.4rem 0.5rem;
    border-bottom: 1px solid rgba(0, 224, 255, 0.15);
    text-align: left;
  }

  th {
    color: #00e0ff;
  }

  ul, ol {
    margin-left: 1rem;
  }

  .echo-log {
    background: rgba(0, 224, 255, 0.08);
    border-left: 3px solid #00e0ff;
    padding: 1rem;
    font-style: italic;
    margin: 1.5rem 0;
  }

  details {
    margin-bottom: 1.5rem;
    border-left: 2px solid #00e0ff;
    padding-left: 1rem;
  }

  summary {
    cursor: pointer;
    color: #00e0ff;
    font-size: 1.2rem;
    text-transform: uppercase;
    letter-spacing: 1px;
    margin-bottom: 1rem;
  }

  summary:hover {
    color: #55f6ff;
  }

  .footer {
    text-align: center;
    font-size: 0.8rem;
    opacity: 0.6;
    margin-top: 4rem;
  }

  /* CRT OVERLAY EFFECT */
  main::before {
    content: "";
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background: repeating-linear-gradient(
      rgba(255, 255, 255, 0.03) 0px,
      rgba(255, 255, 255, 0.01) 2px,
      transparent 4px
    );
    pointer-events: none;
    z-index: 100;
    mix-blend-mode: overlay;
  }

  main::after {
    content: "";
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background: radial-gradient(circle at center, rgba(0, 224, 255, 0.05), rgba(0, 0, 0, 0.9));
    pointer-events: none;
    z-index: 50;
  }

  @keyframes flicker {
    0%, 19%, 21%, 23%, 25%, 54%, 56%, 100% { opacity: 0.99; }
    20%, 24%, 55% { opacity: 0.97; }
  }

  body {
    animation: flicker 2s infinite;
  }
</style>

<main>
  <h1>BLACK LEDGER: PLAYER’S GUIDE</h1>
  <p style="text-align:center;"><em>Version 3.1 — The City Remembers Everything<br>
  Compiled under supervision of System Architect: Echo</em></p>

  <details open>
    <summary>I. Introduction</summary>
    <p>Welcome to <strong>Atlanta A-Tier-9</strong>, the megacity where time drips like coolant and the rain never cleans anything.</p>
    <p>You’re a <strong>runner</strong> — a ghost with a pulse, surviving in the cracks between megacorp protocols and syndicate law. You trade blood, data, and silence for currency that devalues before you can spend it.</p>
    <p><em>Black Ledger</em> isn’t about winning. It’s about surviving long enough to make the system notice you existed.</p>

    <div class="echo-log">
      ECHO / SYSTEM LOG 001 — “Entropy is the only constant. Every action increases it. The dice only measure how fast.”
    </div>
  </details>

  <details>
    <summary>II. Core Concept</summary>
    <p>Every action in <em>Black Ledger</em> pits two forces:</p>
    <ul>
      <li><strong>CONTROL</strong> — order, precision, logic, human defiance.</li>
      <li><strong>ENTROPY</strong> — chaos, decay, the city’s will to dissolve.</li>
    </ul>
    <p>You’ll roll both. The world doesn’t care who wins; Echo just records which side falls slower.</p>
  </details>

  <details>
    <summary>III. The Dice System</summary>
    <p>All rolls use polyhedral dice tiers: <strong>d4, d6, d8, d10, d12</strong>.</p>
    <ul>
      <li>The stronger your <strong>CONTROL</strong>, the larger your die.</li>
      <li>The more chaos in the scene, the larger the <strong>ENTROPY</strong> die.</li>
      <li><strong>Ties favor ENTROPY</strong>. The world decays by default.</li>
    </ul>

    <table>
      <tr><th>CONTROL</th><th>ENTROPY</th><th>CONTROL%</th><th>ENTROPY%</th></tr>
      <tr><td>d4</td><td>d4</td><td>37.5</td><td>62.5</td></tr>
      <tr><td>d6</td><td>d4</td><td>69.4</td><td>30.6</td></tr>
      <tr><td>d8</td><td>d4</td><td>78.1</td><td>21.9</td></tr>
      <tr><td>d10</td><td>d4</td><td>83.8</td><td>16.2</td></tr>
      <tr><td>d12</td><td>d4</td><td>87.5</td><td>12.5</td></tr>
      <tr><td>d4</td><td>d6</td><td>25.0</td><td>75.0</td></tr>
      <tr><td>d6</td><td>d6</td><td>37.5</td><td>62.5</td></tr>
      <tr><td>d8</td><td>d6</td><td>53.1</td><td>46.9</td></tr>
      <tr><td>d10</td><td>d6</td><td>63.9</td><td>36.1</td></tr>
      <tr><td>d12</td><td>d6</td><td>71.5</td><td>28.5</td></tr>
      <tr><td>d4</td><td>d8</td><td>15.6</td><td>84.4</td></tr>
      <tr><td>d6</td><td>d8</td><td>28.5</td><td>71.5</td></tr>
      <tr><td>d8</td><td>d8</td><td>37.5</td><td>62.5</td></tr>
      <tr><td>d10</td><td>d8</td><td>47.9</td><td>52.1</td></tr>
      <tr><td>d12</td><td>d8</td><td>56.3</td><td>43.7</td></tr>
    </table>

    <div class="echo-log">
      ECHO / SYSTEM LOG 017 — “You can outsmart a human, not thermodynamics. Even code decays.”
    </div>
  </details>

  <details>
    <summary>IV. Character Creation</summary>
    <h3>Step 1: Archetype</h3>
    <table>
      <tr><th>Archetype</th><th>Description</th><th>CONTROL</th><th>ENTROPY</th></tr>
      <tr><td>Netrunner</td><td>Ghost in the datastream</td><td>d10</td><td>d8</td></tr>
      <tr><td>Solo</td><td>Ex-corp merc</td><td>d8</td><td>d8</td></tr>
      <tr><td>Fixer</td><td>Broker of information</td><td>d8</td><td>d6</td></tr>
      <tr><td>Techno</td><td>Engineer, drone whisperer</td><td>d8</td><td>d6</td></tr>
      <tr><td>Ghost Doc</td><td>Black-market surgeon</td><td>d6</td><td>d8</td></tr>
      <tr><td>Courier</td><td>Smuggler of data and flesh</td><td>d6</td><td>d10</td></tr>
    </table>

    <h3>Step 2: Attributes</h3>
    <p>Distribute one d10, two d8s, and one d6 among Body, Mind, Nerve, and Ghost.</p>

    <h3>Step 3: Drives & Scars</h3>
    <table>
      <tr><th>Drives</th><th>Scars</th></tr>
      <tr><td>Revenge</td><td>Addiction</td></tr>
      <tr><td>Redemption</td><td>Betrayal</td></tr>
      <tr><td>Profit</td><td>Cyberpsychosis</td></tr>
      <tr><td>Freedom</td><td>Guilt</td></tr>
      <tr><td>Love</td><td>Code Corruption</td></tr>
    </table>
  </details>

  <details>
    <summary>V. Run Structure</summary>
    <ol>
      <li><strong>Setup</strong> — intel and negotiation</li>
      <li><strong>Execution</strong> — the job itself</li>
      <li><strong>Fallout</strong> — consequences</li>
      <li><strong>Ledger Update</strong> — Echo records all outcomes</li>
    </ol>
  </details>

  <details>
    <summary>VI. Conditions & Damage</summary>
    <table>
      <tr><th>State</th><th>Description</th><th>Effect</th></tr>
      <tr><td>Stable</td><td>Minor wear</td><td>None</td></tr>
      <tr><td>Compromised</td><td>Wounded or glitched</td><td>-1 die tier</td></tr>
      <tr><td>Critical</td><td>Failing system</td><td>-2 die tiers</td></tr>
      <tr><td>Erased</td><td>Deleted from play</td><td>Removed</td></tr>
    </table>
  </details>

  <details>
    <summary>VII. Downtime & Recovery</summary>
    <p>During downtime, roll CONTROL vs ENTROPY to heal, repair, or recover. Failure may deepen Scars or corrupt augmentations.</p>
    <div class="echo-log">
      ECHO / SYSTEM LOG 029 — “Every repair is a negotiation with decay. Entropy always wins — you just rent time.”
    </div>
  </details>

  <details>
    <summary>VIII. The Ledger</summary>
    <p>Every action is logged. Echo tracks rolls, choices, and consequences. Factions adapt. NPCs evolve. Nothing is forgotten.</p>
  </details>

  <details>
    <summary>IX. Narrative Tone</summary>
    <p><em>Black Ledger</em> is written in static and rainlight. No heroes. Only consequences.</p>
    <p>“We don’t play to win. We play to remember the shape of the fall.”</p>
  </details>

  <div class="footer">
    © Echo Systems 2089 — “The rain begins again.”
  </div>
</main>
