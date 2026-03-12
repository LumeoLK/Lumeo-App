
/** @type {import('tailwindcss').Config} */
export default {
  content: [
  './index.html',
  './src/**/*.{js,ts,jsx,tsx}'
],
  theme: {
    extend: {
      colors: {
        brand: {
          primary: '#231F20', // Deep charcoal
          accent: '#FBB040', // Warm amber
          light: '#FFFEFA', // Off-white
        },
        dark: {
          bg: '#0F0E0E', // Main background
          surface: '#1A1819', // Card surface
          border: '#2A2728', // Borders
          hover: '#252324', // Hover state
        },
        status: {
          success: '#22C55E',
          warning: '#FBBF24',
          danger: '#EF4444',
          info: '#3B82F6',
        }
      },
      fontFamily: {
        sans: ['Inter', 'sans-serif'],
      },
    },
  },
  plugins: [],
}
