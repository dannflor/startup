import getNeighbors from "./getNeighbors.js";
import {populateResources, updateResources} from "./populateResources.js";

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
const res = fetch('/grid/' + user).then(res =>
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

      if (cell.terrain === 'none') {
        gridCell.onclick = () => { editBuildMenu(cell, gridCell) };
      }
      else {
        gridCell.setAttribute('for', '');
        // console.log("terrain clicked");
      }
    }
  })
);
await populateResources();

/**
 * Building prompt behaves differently depending on
 * whether or not the clicked space has a building.
 */
async function editBuildMenu(building, element) {
  // clearModal();
  const buildMenu = document.getElementById('modalMenu');
  const buildMenuBody = document.getElementById('modalMenuBody');
  const buildMenuTitle = document.getElementById('modalMenuTitle');
  const buildMenuImage = document.getElementById('modalMenuPicture');
  const buildingTitle = document.getElementById('buildingTitle');
  const cost = document.getElementById('buildingCost');
  const costValue = document.getElementById('cost');

  if (building.name === "") {
    buildMenuImage.style.visibility = 'visible';
    buildMenuTitle.innerText = "Build";
    buildingTitle.style.display = 'inline';
    // buildMenuBody.style.display = 'block';
    // Clear options from selector
  }
  else {
    let ind = building.index;
    building = await fetch('/building/' + building.name).then(res => res.json());
    building.index = ind;
    buildMenuTitle.innerText = building.name;
    buildingTitle.style.display = 'none';
    cost.textContent = 'Value:';
    let valueText = '';
    for (let i = 0; i < building.cost.length; i++) {
      if (building.cost[i].count == 0) { continue; }
      valueText += building.cost[i].count + ' ' + building.cost[i].name.toLowerCase() + ', ';
    }
    costValue.innerText = valueText.slice(0, -2);
    showBuildingEffects(building);
    buildMenuImage.setAttribute('src', '/img/building/' + pictureForBuilding(building.name));
  }
}

async function showBuildingEffects(building) {
  const metadata = await fetch('/building/' + building.name + '/metadata').then(res => res.json());
  if (building.index !== undefined) {
    console.log(building.index)
    const myYield = await fetch('/building/yield/' + building.index).then(res => res.json());
    metadata.yield = myYield;
  }
  let production = "";
  for (let i = 0; i < metadata.yield.length; i++) {
    production += metadata.yield[i].count + ' ' + metadata.yield[i].name.toLowerCase() + '\n';
  }
  production = production.slice(0, -1);
  if (production === "") {
    production = "Nothing";
  }
  else {
    production += ' per hour';
  }
  document.getElementById('produces').innerText = production;
  document.getElementById('bonuses').innerText = metadata.bonusDescription;
}

function pictureForBuilding(building) {
  // Remove spaces and append .png
  return building === '' ? 'NoHouse.png' : building.replace(/\s/g, '') + '.png';
}

async function buildBuilding(building, index, element) {
  // alert if not enough resources
  const resources = await fetch('/resources').then(res => res.json());
  console.log(building.cost);
  for (let i = 0; i < building.cost.length; i++) {
    // console.log(resources[i].count + ' ' + resources[i].name + ' ' + building.cost[i].count + ' ' + building.cost[i].name)
    for (let j = 0; j < resources.length; j++) {
      if (building.cost[i].name === resources[j].name) {
        if (building.cost[i].count > resources[j].count) {
          alert('Not enough resources!');
          return;
        }
      }
    }
  }
  console.log('building ' + building.name + ' at ' + index);
  const buildingData = {
    buildingName: building.name,
    index: index
  }
  await fetch('/building/build', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json'
    },
    body: JSON.stringify(buildingData)
  })

  // Get img child of element
  let img = element.children[0];
  img.setAttribute('src', '/img/building/' + pictureForBuilding(building.name));
  
  building.index = index;
  element.onclick = () => { editBuildMenu(building, element) };
  setTimeout(async () => {
    await updateResources();
  }, 2000);
}

async function destroyBuilding(building, index, element) {
  building = await fetch('/building/' + building.name).then(res => res.json());
  console.log('destroying ' + building.name + ' at ' + index);
  const buildingData = {
    buildingName: building.name,
    index: index
  }
  await fetch('/building/destroy', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json'
    },
    body: JSON.stringify(buildingData)
  })

  // Get img child of element
  let img = element.children[0];
  img.setAttribute('src', '/img/building/' + pictureForBuilding(''));

  let newBuilding = new Building('', 0, false);
  newBuilding.index = index;
  element.onclick = () => { editBuildMenu(newBuilding, element) };
  setTimeout(async () => {
    await updateResources();
  }, 2000);
}
