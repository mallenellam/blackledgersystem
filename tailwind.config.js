import typography from '@tailwindcss/typography';

/** @type {import('tailwindcss').Config} */
export default {
	content: [
		'./src/**/*.{html,js,svelte,ts}',
		'./src/routes/**/*.{svelte,ts}',
		'./src/lib/**/*.{svelte,ts}'
	],
	theme: {
		extend: {
			colors: {
				// Example palette — adjust to your cyberpunk aesthetic
				neon: {
					pink: '#ff3ea5',
					cyan: '#00fff7',
					yellow: '#ffe800'
				},
				bg: {
					dark: '#0d0d0d',
					panel: '#1a1a1a'
				}
			},
			fontFamily: {
				sans: ['Inter', 'system-ui', 'sans-serif'],
				mono: ['JetBrains Mono', 'monospace']
			}
		}
	},
	plugins: [typography]
};
