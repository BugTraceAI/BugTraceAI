import { defineConfig } from 'astro/config';
import starlight from '@astrojs/starlight';

export default defineConfig({
	// site: 'https://bugtraceai.github.io',
	base: '/BugTraceAI',
	integrations: [
		starlight({
			title: 'BugTraceAI Docs',
			logo: {
				src: './src/assets/logo.svg',
			},
			social: {
				github: 'https://github.com/BugTraceAI/BugTraceAI',
			},
			sidebar: [
				{
					label: 'Getting Started',
					items: [
						{ label: 'Overview', link: '/overview' },
						{ label: 'Getting Started', link: '/getting-started' },
					],
				},
				{
					label: 'Architecture',
					items: [
						{ label: 'System Architecture', link: '/architecture' },
						{ label: 'Dual Database System', link: '/dual-database-system' },
						{ label: 'API Reference', link: '/api-reference' },
						{ label: 'WebSocket Events', link: '/websocket-events' },
					],
				},
				{
					label: 'BugTraceAI-CLI',
					items: [
						{ label: 'CLI Scanner', link: '/bugtraceai-cli' },
						{ label: 'Scanning Pipeline', link: '/scanning-pipeline' },
						{ label: 'Specialist Agents', link: '/specialist-agents' },
						{ label: 'Queue and Event System', link: '/queue-and-event-system' },
						{ label: 'Validation System', link: '/validation-system' },
						{ label: 'Report Generation', link: '/report-generation' },
						{ label: 'Configuration', link: '/configuration' },
					],
				},
				{
					label: 'BugStore',
					items: [
						{ label: 'About BugStore', link: '/bugstore' },
					],
				},
				{
					label: 'BugTraceAI-WEB',
					items: [
						{ label: 'Web Dashboard', link: '/bugtraceai-web' },
						{ label: 'Security Toolkit', link: '/security-toolkit' },
						{ label: 'Real-time Monitoring', link: '/real-time-scan-monitoring' },
					],
				},
				{
					label: 'BugTraceAI-Launcher',
					items: [
						{ label: 'Launcher', link: '/bugtraceai-launcher' },
						{ label: 'Deployment Modes', link: '/deployment-modes' },
						{ label: 'AI Integration', link: '/ai-assistant-integration' },
					],
				},
				{
					label: 'Policies',
					items: [
						{ label: 'Ethics', link: '/ethics-policy' },
						{ label: 'Privacy', link: '/privacy-policy' },
						{ label: 'Terms of Service', link: '/terms-of-service' },
						{ label: 'Responsible Disclosure', link: '/responsible-disclosure' },
					],
				},
			],
			customCss: [
				'./src/styles/custom.css',
			],
		}),
	],
});
