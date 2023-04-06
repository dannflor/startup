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
const res = fetch('/grid').then(res =>
  res.json().then(data => {
    //Parse json into Building objects
    const cells = data.map(cell => new Building(cell.name, cell.cost, cell.terrain));
    for (let i = 0; i < cells.length; i++) {
      const cell = cells[i];

      let gridCell = document.createElement('label');
      gridCell.setAttribute('for', 'grid-cell-modal');
      //randomNum between 1 and 3
      const randomNum = Math.floor(Math.random() * 3) + 1;
      gridCell.style.setProperty('--ground-image', "url('/img/Ground" + randomNum + ".png')");
     
      let img = document.createElement('img');
      img.setAttribute('src', '/img/' + pictureForBuilding(cell.name));
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
  const select = document.getElementById('buildingSelector');
  const buildingTitle = document.getElementById('buildingTitle');
  const cost = document.getElementById('buildingCost');
  const costValue = document.getElementById('cost');

  if (building.name === "") {
    buildMenuImage.style.visibility = 'visible';
    buildMenuTitle.innerText = "Build";
    buildingTitle.style.display = 'inline';
    // buildMenuBody.style.display = 'block';
    // Clear options from selector
    while (select.firstChild) {
      select.removeChild(select.firstChild);
    }
    let buildings = await fetch('/building').then(res => res.json());
    buildings = buildings.map(building => new Building(building.name, building.cost, building.terrain));
    let optionsTitle = document.createElement('option');
    optionsTitle.innerText = "Select a building";
    optionsTitle.setAttribute('disabled', '');

    let buttonDiv = document.createElement('div');
    buttonDiv.setAttribute('class', 'justify-end justify-items-end flex');
    let buildButton = document.createElement('a');
    buildButton.setAttribute('class', 'btn btn-primary w-24 mt-4');
    buildButton.innerText = 'Build';
    let cancelButton = document.createElement('label');
    cancelButton.setAttribute('for', 'grid-cell-modal');
    cancelButton.setAttribute('class', 'btn btn-secondary w-24 mt-4 ml-4 mr-auto');
    cancelButton.innerText = 'Cancel';
    buttonDiv.appendChild(buildButton);
    buttonDiv.appendChild(cancelButton);
    if (buildMenu.children.length > 2) {
      buildMenu.removeChild(buildMenu.lastChild);
    }
    buildMenu.appendChild(buttonDiv);

    select.appendChild(optionsTitle);
    for (let i = 0; i < buildings.length; i++) {
      let option = document.createElement('option');
      option.innerText = buildings[i].name;
      option.value = buildings[i].name;
      select.appendChild(option);
    }

    // Select second option of select
    select.selectedIndex = 1;
    select.onchange = () => {
      let selectedBuilding = buildings[select.selectedIndex - 1];
      buildingTitle.innerText = selectedBuilding.name;
      
      let costText = '';
      for (let i = 0; i < selectedBuilding.cost.length; i++) {
        if (selectedBuilding.cost[i].count == 0) { continue; }
        costText += selectedBuilding.cost[i].count + ' ' + selectedBuilding.cost[i].name.toLowerCase() + ', ';
      }
      costValue.innerText = costText.slice(0, -2);
      buildMenuImage.setAttribute('src', '/img/' + pictureForBuilding(selectedBuilding.name));
      showBuildingEffects(selectedBuilding);
      buildButton.onclick = () => {
        buildBuilding(selectedBuilding, building.index, element);
        document.getElementById('grid-cell-modal').checked = false;
      }
    }
    select.style.display = 'block';
  
    cost.innerText = 'Cost: ';

    select.onchange();
  }
  else {
    let ind = building.index;
    building = await fetch('/building/' + building.name).then(res => res.json());
    building.index = ind;
    select.style.display = 'none';
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

    let buttonDiv = document.createElement('div');
    buttonDiv.setAttribute('class', 'justify-end justify-items-end flex');
    let destroyButton = document.createElement('a');
    destroyButton.setAttribute('class', 'btn btn-error w-24 mt-4');
    destroyButton.innerText = 'Destroy';
    destroyButton.onclick = () => {
      destroyBuilding(building, building.index, element);
      document.getElementById('grid-cell-modal').checked = false;
    }
    let cancelButton = document.createElement('label');
    cancelButton.setAttribute('for', 'grid-cell-modal');
    cancelButton.setAttribute('class', 'btn btn-secondary w-24 mt-4 ml-4 mr-auto');
    cancelButton.innerText = 'Cancel';
    buttonDiv.appendChild(destroyButton);
    buttonDiv.appendChild(cancelButton);
    if (buildMenu.children.length > 2) {
      buildMenu.removeChild(buildMenu.lastChild);
    }
    buildMenu.appendChild(buttonDiv);
    buildMenuImage.setAttribute('src', '/img/' + pictureForBuilding(building.name));
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
  img.setAttribute('src', '/img/' + pictureForBuilding(building.name));
  
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
  img.setAttribute('src', '/img/' + pictureForBuilding(''));

  let newBuilding = new Building('', 0, false);
  newBuilding.index = index;
  element.onclick = () => { editBuildMenu(newBuilding, element) };
  setTimeout(async () => {
    await updateResources();
  }, 2000);
}
