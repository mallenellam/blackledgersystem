import { writable } from 'svelte/store';

export const rolls = writable([]);
export const body = writable('d8');
export const mind = writable('d10');
export const stress = writable(2);
