import getNeighbors from "./getNeighbors.js";

let response = await fetch(`https://source.unsplash.com/300x300/?nature`);
let image = document.getElementById('loginImage');
let image2 = document.createElement('img');
image2.setAttribute('src', response.url);
image2.setAttribute('alt', 'Tradeworld Logo');
image2.setAttribute('class', 'w-[300px] sm:h-[300px] h-[200px]');
image.appendChild(image2);

document.getElementById('registerButton').addEventListener('click', register);
document.getElementById('loginButton').addEventListener('click', login);
async function register() {
  console.log("Hello?");
  let username = document.getElementById('username').value;
  let password = document.getElementById('password').value;
  let response = await fetch('/exists/' + username, {
    method: 'GET'
  });
  //Extract bool from body
  let exists = await response.json();
  console.log(exists);
  if (exists) {
    alert('Username already exists');
  } else {
    let response = await fetch('/register', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        username: username,
        password: password
      })
    });
    if (response.redirected) {
      window.location.href = response.url;
    }
  }
}

async function login() {
  let username = document.getElementById('username').value;
  let password = document.getElementById('password').value;
  let response = await fetch('/login', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({
      username: username,
      password: password
    })
  });
  if (response.redirected) {
    window.location.href = response.url;
  } else {
    alert('Username or password is incorrect');
  }
}