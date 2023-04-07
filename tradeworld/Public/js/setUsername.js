export default async function setUsername() {
  const username = await fetch('/user/me').then(res => res.text());
  const usernameDiv = document.getElementById('username');
  usernameDiv.textContent = username;
}