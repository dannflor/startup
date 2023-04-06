export default function fadeIn(id) {
  let element = document.getElementById(id);
  element.classList.add("animate-fadeIn");
  element.classList.remove("hidden");
  }