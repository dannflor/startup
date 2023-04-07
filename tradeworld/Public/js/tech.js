import fadeAway from "./fadeAway.js";
import fadeIn from "./fadeIn.js";
import setUsername from "./setUsername.js";
import {populateResources, updateResources} from "./populateResources.js";

await setUsername();

class Tech {
  constructor(tech) {
    this.id = tech.id;
    this.title = tech.title;
    this.description = tech.description;
    this.price = tech.price[0].count + " " + tech.price[0].name;
  }
}

loadTechList();

async function loadTechList() {
  const techList = document.getElementById("techList");
  let techs = await fetch("/tech/unresearched").then((res) => res.json());
  // clear out all children of techList
  while (techList.firstChild) {
    techList.removeChild(techList.firstChild);
  }
  techs = techs.map(tech => new Tech(tech));
  console.log(techs);
  /*
  #for(tech in techs):
    <li id="cell#(tech.id)" class="mb-4 max-h-36 min-h-[5rem] sm:w-[32rem] w-[21.5rem] border-2 border-primary hover:border-primary-focus rounded-xl flex p-2 flex-row">
      <input type="checkbox" class="checkbox hover:checkbox-accent sm:checkbox-md checkbox-sm flex my-auto sm:ml-4 ml-2" onclick="fadeAway('cell#(tech.id)')"/> 
      <div class="my-auto flex-col ml-4">
        <div class="flex-row flex">
          <div class="text-secondary font-serif font-bold sm:text-xl text-md">
            #(tech.title)
          </div>
          <div class="sm:text-base text-sm font-black my-auto text-info sm:ml-5 ml-2 sm:mr-2 mr-0.5">
            COST:
          </div>
          <div class="sm:text-base text-xs my-auto">
            #(tech.price)
          </div>
        </div>
        <div class="divider !my-0 mr-4 !h-2 sm:w-[27rem] w-[17rem]"></div> 
        <div class="sm:text-base text-xs sm:mr-2 mr-0.5">
          #(tech.description)
        </div>
      </div>
    </li>
  #endfor
  */
  techs.forEach(tech => {
    const li = document.createElement("li");
    li.setAttribute("id", "cell" + tech.id);
    li.setAttribute("class", "mb-4 max-h-36 min-h-[5rem] sm:w-[32rem] w-[21.5rem] border-2 border-primary hover:border-primary-focus rounded-xl flex p-2 flex-row");
    const input = document.createElement("input");
    input.setAttribute("type", "checkbox");
    input.setAttribute("class", "checkbox hover:checkbox-accent sm:checkbox-md checkbox-sm flex my-auto sm:ml-4 ml-2");
    input.onclick = () => researchTech(tech, input);
    const div = document.createElement("div");
    div.setAttribute("class", "my-auto flex-col ml-4");
    const div2 = document.createElement("div");
    div2.setAttribute("class", "flex-row flex");
    const div3 = document.createElement("div");
    div3.setAttribute("class", "text-secondary font-serif font-bold sm:text-xl text-md");
    div3.innerText = tech.title;
    const div4 = document.createElement("div");
    div4.setAttribute("class", "sm:text-base text-sm font-black my-auto text-info sm:ml-5 ml-2 sm:mr-2 mr-0.5");
    div4.innerText = "COST:";
    const div5 = document.createElement("div");
    div5.setAttribute("class", "sm:text-base text-xs my-auto");
    div5.innerText = tech.price;
    const div6 = document.createElement("div");
    div6.setAttribute("class", "divider !my-0 mr-4 !h-2 sm:w-[27rem] w-[17rem]");
    const div7 = document.createElement("div");
    div7.setAttribute("class", "sm:text-base text-xs sm:mr-2 mr-0.5");
    div7.innerText = tech.description;
    div2.appendChild(div3);
    div2.appendChild(div4);
    div2.appendChild(div5);
    div.appendChild(div2);
    div.appendChild(div6);
    div.appendChild(div7);
    li.appendChild(input);
    li.appendChild(div);
    techList.appendChild(li);
    fadeIn("cell" + tech.id);
  });
}

async function researchTech(tech, input) {
  let res = await fetch("/tech/researchable/" + tech.id);
  res = await res.json();
  if (!res) {
    input.checked = false;
    alert("You don't have enough resources to research this technology!");
    return;
  }
  await fetch("/tech/research/" + tech.id, {
    method: "POST"
  });
  fadeAway("cell" + tech.id);
  setTimeout(async () => {
    await updateResources();
    loadTechList();
  }, 2000);
}

await populateResources();