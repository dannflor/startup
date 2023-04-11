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
document.onkeydown = function (e) {
  if (e.keyCode === 13 || e.key === 'Enter' || e.key === 'Return') {
    login();
  }
};
async function register() {
  let username = document.getElementById('username').value;
  let password = document.getElementById('password').value;
  if (username === '' || password === '') {
    alert('Choose a new username and password, then click register');
    return;
  }
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
    let loginResponse = await fetch('/login', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        username: username,
        password: password
      })
    });
    if (loginResponse.redirected) {
      window.location.href = loginResponse.url;
    }
  } else {
    let failure = await response.json();
    alert(failure.reason);
  }
}

async function login() {
  console.log("login");
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