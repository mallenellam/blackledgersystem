import { writable } from 'svelte/store';

export const user = writable(null);
export const selectedCharacter = writable(null);
export const crew = writable(null);
export const activeJob = writable(null);
