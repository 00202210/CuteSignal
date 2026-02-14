import { defineConfig } from 'vitepress'

// https://vitepress.dev/reference/site-config
export default defineConfig({
    title: 'CuteSignal',
    base: '/CuteSignal/',
    description: 'A pure Luau signal implementation.',
    themeConfig: {
        // https://vitepress.dev/reference/default-theme-config
        nav: [
            { text: 'Guide', link: '/guide/what-is-cutesignal' },
            { text: 'API Reference', link: '/classes/signal' }
        ],

        sidebar: {
            '/guide/': [
                {
                    text: 'Introduction',
                    items: [
                        { text: 'What is CuteSignal?', link: '/guide/what-is-cutesignal' },
                        { text: 'Features', link: '/guide/features' },
                        { text: 'Performance', link: '/guide/performance' }
                    ]
                }
            ],
            '/classes/': [
                {
                    text: 'Classes',
                    items: [
                        { text: 'Signal', link: '/classes/signal' },
                        { text: 'Connection', link: '/classes/connection' }
                    ]
                }
            ]
        },

        socialLinks: [
            { icon: 'github', link: 'https://github.com/00202210/CuteSignal' }
        ]
    }
})
