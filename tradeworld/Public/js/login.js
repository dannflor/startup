function loadImage() {
  console.log("Function started");
  fetch(`https://source.unsplash.com/300x300/?nature`).then((response) => {
    console.log(response.url);
    let image = document.getElementById('loginImage');
    let image2 = document.createElement('img');
    image2.setAttribute('src', response.url);
    image2.setAttribute('alt', 'Tradeworld Logo');
    image2.setAttribute('class', 'w-[300px] sm:h-[300px] h-[200px]');
    image.appendChild(image2);
  });
}