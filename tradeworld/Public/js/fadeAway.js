function fadeAway(id) {
  console.log("Function started");
  let element = document.getElementById(id);
  element.classList.add("animate-fadeAway");
  element.addEventListener("animationend", function() {
    setTimeout(function() {
      element.classList.add("hidden");
    }, 200);
  });
}