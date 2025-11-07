import { writable } from 'svelte/store';

// Toggle to false when Supabase auth works again
export const devMode = false;

// A writable store that mimics Supabase's session object
export const session = writable(
  devMode
    ? { user: { id: 'debug-user-id-001', email: 'runner@blackledger.dev' } }
    : null
);

// Helper: set or clear session
export function setSession(newSession) {
  session.set(newSession);
}

export function clearSession() {
  session.set(null);
}
