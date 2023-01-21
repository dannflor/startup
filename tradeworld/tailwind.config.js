/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ["./Resources/**/*.{html,js,leaf}"],
  theme: {
    extend: {},
  },
  plugins: [
	require("daisyui")
  ],
}
