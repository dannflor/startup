export default function fadeAway(id) {
  let element = document.getElementById(id);
  element.classList.add("animate-fadeAway");
  element.addEventListener("animationend", function() {
    setTimeout(function() {
      element.classList.add("hidden");
    }, 300);
  });
}