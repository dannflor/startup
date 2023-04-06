/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ["./Resources/**/*.{html,js,leaf}", "./Public/js/*.js"],
  theme: {
    extend: {
      animation: {
        fadeAway: "fadeAway 0.5s ease-in both",
        fadeIn: "fadeIn 1.2s ease-in cubic-bezier(0.390, 0.575, 0.565, 1.000) both"

      },
      gridTemplateRows: {
        '13': 'repeat(13, minmax(0, 1fr))',
      },
      gridTemplateColumns: {
        '13': 'repeat(13, minmax(0, 1fr))',
      },
      keyframes: {
        fadeAway: {
          "0%": { 
            transform: "translateX(0)",
            opacity: 1 
          },
          "100%": { 
            transform: "translateX(-1000px)",
            opacity: 0 
          },
        },
        fadeIn: {
          "0%" : {
            transform: "translateY(50px)",
            opacity: 0
          },
          "100%": {
            transform: "translateY(0)",
            opacity: 1
          }
        }
      },
      backgroundImage: {
        'backdrop': "url('/img/bg.jpg')"
      },
    },
  },
  plugins: [
	  require("daisyui")
  ],
  daisyui: {
    themes: ["light", "dark", "dracula"],
  },
}
