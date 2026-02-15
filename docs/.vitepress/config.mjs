import { defineConfig } from 'vitepress'

export default defineConfig({
    title: 'CuteSignal',
    base: '/CuteSignal/',
    description: 'Predictable and low-allocation signals for Luau.',
    themeConfig: {
        nav: [
            { text: 'Guide', link: '/guide/what-is-cutesignal' },
            { text: 'Reference', link: '/classes/signal' },
            { text: 'Benchmark', link: '/guide/performance' }
        ],

        sidebar: {
            '/guide/': [
                {
                    text: 'Guide',
                    items: [
                        { text: 'Overview', link: '/guide/what-is-cutesignal' },
                        { text: 'Features', link: '/guide/features' },
                        { text: 'Performance', link: '/guide/performance' }
                    ]
                }
            ],
            '/classes/': [
                {
                    text: 'Reference',
                    items: [
                        { text: 'Signal', link: '/classes/signal' },
                        { text: 'Connection', link: '/classes/connection' }
                    ]
                }
            ]
        },

        socialLinks: [
            { icon: 'github', link: 'https://github.com/00202210/CuteSignal' }
        ],

        footer: {
            message: 'CuteSignal documentation',
            copyright: 'MIT License'
        }
    }
})
