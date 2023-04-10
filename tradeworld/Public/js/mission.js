import {populateResources, updateResources} from "./populateResources.js";

populateResources();

document.getElementById('contributeButton').onclick = contributeRes;

function contributeRes() {
    const resource = document.getElementById("contributeResource").value;
    const count = document.getElementById("contributeCount").value;
    // POST to the server
    // If it returns a 400, the user doesn't have enough resources
    // Alert the user and return
    const newCount = fetch("/mission/contribute/" + resource + "/" + count, { method: "POST" })
      .then(response => {
        if (response.status === 400) {
          alert("You don't have enough " + resource + " to contribute that much!");
          return;
        }
        return response.text()
      })
      .then(data => {
        console.log(data);
        // Update the progress bar
        const progress = document.getElementById("progress");
        progress.value = data;
        // Update the current resource count
        const currentRes = document.getElementById("currentRes");
        currentRes.innerHTML = data;
        updateResources();
      }
    );
  }