/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ["./Resources/**/*.{html,js,leaf}", "./Public/js/*.js"],
  theme: {
    extend: {
      animation: {
        fadeAway: "fadeAway 0.5s ease-in both",
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
