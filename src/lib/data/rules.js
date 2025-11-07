export const RULES = {
  attributes: {
    title: 'Attributes & Dice',
    body: `Each attribute represents one of your core capacities.

Body — Strength, endurance, resilience.
Mind — Analysis, planning, logic.
Soul — Willpower, empathy, drive.

Assign one to d10, one to d8, and one to d6.`
  },
  secondary: {
    title: 'Secondary Attributes',
    body: `Secondary attributes represent your finer tuned capabilities.
Assign two d6, one d8, one d10, and one d12 across five attributes.`
  },
  skills: {
    title: 'Skills',
    body: `Choose 5 skills: 3 at d6 and 2 at d8. Skills determine how you apply your attributes to specialized actions.`
  },
  wallet: {
    title: 'Wallet',
    body: `Your starting wallet is calculated as (d10 + d12) × 100₳, based on your top two secondary attributes.`
  }
};
