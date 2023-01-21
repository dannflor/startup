const mix = require('laravel-mix');
const tailwindcss = require('tailwindcss');

mix.sass('Resources/css/app.scss', 'Public/css/app.css')
      .options({
        processCssUrls: false,
        postCss: [tailwindcss]
    });
