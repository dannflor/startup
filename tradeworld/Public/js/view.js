import getNeighbors from "./getNeighbors.js";
import {populateResources} from "./populateResources.js";

class Building {
  constructor(name, cost, terrain) {
    this.name = name;
    this.cost = cost;
    this.terrain = terrain;
  }
}
const gridElement = document.getElementById('gameGrid');
// Get user query parameter
const urlParams = new URLSearchParams(window.location.search);
const user = urlParams.get('user');
console.log(user);
document.getElementById('usernameTitle').innerText = user;

fetch('/grid/' + user).then(res =>
  res.json().then(data => {
    //Parse json into Building objects
    const cells = data.map(cell => new Building(cell.name, cell.cost, cell.terrain));
    for (let i = 0; i < cells.length; i++) {
      const cell = cells[i];

      let gridCell = document.createElement('label');
      gridCell.setAttribute('for', 'grid-cell-modal');
      //randomNum between 1 and 3
      const randomNum = Math.floor(Math.random() * 3) + 1;
      gridCell.style.setProperty('--ground-image', "url('/img/building/Ground" + randomNum + ".png')");
     
      let img = document.createElement('img');
      img.setAttribute('src', '/img/building/' + pictureForBuilding(cell.name));
      img.setAttribute('class', '');
      img.setAttribute('style', 'image-rendering: crisp-edges; image-rendering: pixelated;');
      gridCell.appendChild(img);
      gridElement.appendChild(gridCell);
      cell.index = i;
      cell.neighbors = getNeighbors(i);

      if (cell.terrain === 'none' && cell.name !== '') {
        console.log(cell);
        gridCell.onclick = () => { editBuildMenu(cell, gridCell) };
      }
      else {
        gridCell.setAttribute('for', '');
        // console.log("terrain clicked");
      }
    }
  })
);
await populateResources('/user/' + user);

/**
 * Building prompt behaves differently depending on
 * whether or not the clicked space has a building.
 */
async function editBuildMenu(building, element) {
  // clearModal();
  const buildMenuTitle = document.getElementById('modalMenuTitle');
  const buildMenuImage = document.getElementById('modalMenuPicture');
  const buildingTitle = document.getElementById('buildingTitle');
  const cost = document.getElementById('buildingCost');
  const costValue = document.getElementById('cost');

  if (building.name === "") {
    buildMenuImage.style.visibility = 'visible';
  }
  else {
    let ind = building.index;
    building = await fetch('/building/' + building.name).then(res => res.json());
    building.index = ind;
    buildMenuTitle.innerText = building.name;
    buildingTitle.style.display = 'none';
    cost.textContent = 'Value:';
    while (costValue.firstChild) {
      costValue.removeChild(costValue.firstChild);
    }

    for (let i = 0; i < building.cost.length; i++) {
      const costImageContainer = document.createElement('div');
      costImageContainer.setAttribute('class', 'w-6 ml-1');
      const costImage = document.createElement('img');
      costImage.setAttribute('src', '/img/icon/' + building.cost[i].name.toLowerCase() + '.png');
      costImage.setAttribute('class', 'w-full h-auto block');
      costImage.setAttribute('style', 'image-rendering: crisp-edges; image-rendering: pixelated;');
      costImageContainer.appendChild(costImage);
      costValue.appendChild(costImageContainer);
      const costText = document.createElement('span');
      costText.innerText = building.cost[i].count;
      costText.setAttribute('class', 'ml-1');
      costValue.appendChild(costText);
    }
    showBuildingEffects(building);
    buildMenuImage.setAttribute('src', '/img/building/' + pictureForBuilding(building.name));
  }
}

async function showBuildingEffects(building) {
  // Delete all children of id produces
  while (produces.firstChild) {
    produces.removeChild(produces.firstChild);
  }
  const metadata = await fetch('/building/' + building.name + '/metadata').then(res => res.json());
  if (building.index !== undefined) {
    console.log(building.index)
    const myYield = await fetch('/building/yield/' + building.index + "?name=" + user).then(res => res.json());
    metadata.yield = myYield;
  }
  for (let i = 0; i < metadata.yield.length; i++) {
    const yieldDiv = document.createElement('div');
    yieldDiv.setAttribute('class', 'flex flex-row ml-2');
    const yieldImgContainer = document.createElement('div');
    yieldImgContainer.setAttribute('class', 'w-6');
    const yieldImg = document.createElement('img');
    yieldImg.setAttribute('class', 'w-full h-auto block');
    yieldImg.setAttribute('src', '/img/icon/' + metadata.yield[i].name.toLowerCase() + '.png');
    yieldImg.setAttribute('style', 'image-rendering: pixelated; image-rendering: crisp-edges;');
    yieldImgContainer.appendChild(yieldImg);
    yieldDiv.appendChild(yieldImgContainer);
    const yieldText = document.createElement('div');
    yieldText.setAttribute('class', 'ml-1 my-auto');
    yieldText.innerText = metadata.yield[i].count;
    yieldDiv.appendChild(yieldText);
    document.getElementById('produces').appendChild(yieldDiv);
  }
  if (metadata.yield.length === 0) {
    const noneDiv = document.createElement('div');
    noneDiv.innerText = 'None';
    document.getElementById('produces').appendChild(noneDiv);
  }
  document.getElementById('bonuses').innerText = metadata.bonusDescription;
}

function pictureForBuilding(building) {
  // Remove spaces and append .png
  return building === '' ? 'NoHouse.png' : building.replace(/\s/g, '') + '.png';
}
