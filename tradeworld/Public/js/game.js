import getNeighbors from "./getNeighbors.js";

class Building {
  constructor(cell) {
    this.name = cell.name;
    this.cost = cell.cost;
    this.resource = cell.resource;
  }
}
const gridElement = document.getElementById('gameGrid');
const res = fetch('/grid').then(res => 
  res.json().then(data => {
    //Parse json into Building objects
    const cells = data.map(cell => new Building(cell));
    for (let i = 0; i < cells.length; i++) {
      const cell = cells[i];

      let gridCell = document.createElement('label');
      gridCell.setAttribute('for', 'grid-cell-modal');
     
      let img = document.createElement('img');
      img.setAttribute('src', '/img/' + pictureForBuilding(cell.name));
      img.setAttribute('class', '');
      img.setAttribute('style', 'image-rendering: crisp-edges; image-rendering: pixelated;');
      gridCell.appendChild(img);
      gridElement.appendChild(gridCell);
      cell.index = i;
      cell.neighbors = getNeighbors(i);

      gridCell.onclick = () => { editBuildMenu(cell) };
    }
  })
);

/**
 * Building prompt behaves differently depending on
 * whether or not the clicked space has a building.
 */
async function editBuildMenu(building) {
  clearModal();
  const buildMenu = document.getElementById('modalMenu');
  const buildMenuBody = document.getElementById('modalMenuBody');
  const buildMenuTitle = document.getElementById('modalMenuTitle');
  const buildMenuImage = document.getElementById('modalMenuPicture');

  /*
  <select class="select select-primary w-full max-w-md">
    <option disabled selected>Select a building</option>
    <!-- must dynamically serve the list based on available tech and resources -->
    <option>Shack</option>
    <option>Lumber Camp</option>
    <option>Mine</option>
    <option>Tower</option>
  </select>
  <span class="mt-2 text-3xl font-bold text-secondary">Building Title</span>
  <span class="text-xl mt-2 font-bold text-warning">Cost: </span>
  100 wood, 50 stone
  <span class="mt-2 text-xl font-bold text-info">Produces: </span>
  10 stone/hour
  <span class="mt-2 text-xl font-bold text-success">Bonuses: </span>
  +5 for adjacent quarries
  <br>
  +3 for adjacent blacksmiths
  <div class="justify-end justify-items-end flex">
    <a class="btn btn-primary w-24 mt-4">Build</a>
    <label for="grid-cell-modal" class="btn btn-secondary w-24 mt-4 ml-4 mr-auto" href="/game">Cancel</a>
  </div>
  */

  if (building.name === "") {
    buildMenuImage.style.visibility = 'visible';
    buildMenuTitle.innerText = "Build";
    let select = document.createElement('select');
    select.setAttribute('class', 'select select-primary w-full max-w-md');
    let buildings = await fetch('/building').then(res => res.json());
    buildings = buildings.map(building => new Building(building));
    let optionsTitle = document.createElement('option');
    optionsTitle.innerText = "Select a building";
    optionsTitle.setAttribute('disabled', '');
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
      let name = document.getElementById('buildingTitle');
      name.innerText = selectedBuilding.name;
      let cost = document.getElementById('cost');
      let costText = '';
      for (let i = 0; i < selectedBuilding.cost.length; i++) {
        costText += selectedBuilding.cost[i].count + ' ' + selectedBuilding.cost[i].name.toLowerCase() + ', ';
      }
      cost.innerText = costText.slice(0, -2);

      let image = document.createElement('img');
      image.setAttribute('src', '/img/' + pictureForBuilding(selectedBuilding.name));
      if (buildMenuImage.children.length > 0) {
        buildMenuImage.removeChild(buildMenuImage.lastChild);
      }
      buildMenuImage.appendChild(image);
    }
    buildMenuBody.appendChild(select);
    let buildingTitle = document.createElement('span');
    buildingTitle.setAttribute('class', 'mt-2 text-3xl font-bold text-secondary');
    buildingTitle.setAttribute('id', 'buildingTitle');
    buildMenuBody.appendChild(buildingTitle);
    let cost = document.createElement('span');
    cost.setAttribute('class', 'text-xl mt-2 font-bold text-warning');
    cost.innerText = 'Cost: ';
    let costText = document.createElement('span');
    costText.setAttribute('id', 'cost');
    buildMenuBody.appendChild(cost);
    buildMenuBody.appendChild(costText);
    showBuildingEffects(building, buildMenuBody);

    let buttonDiv = document.createElement('div');
    buttonDiv.setAttribute('class', 'justify-end justify-items-end flex');
    let buildButton = document.createElement('a');
    buildButton.setAttribute('class', 'btn btn-primary w-24 mt-4');
    buildButton.innerText = 'Build';
    buildButton.onclick = () => {
      console.log('building ' + select.value);
    }
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
    select.onchange();
  }
  else {
    buildMenuImage.style.visibility = 'hidden';
    buildMenuTitle.innerText = building.name;
    let cost = document.createElement('span');
    cost.setAttribute('class', 'text-xl mt-2 font-bold text-warning');
    cost.innerText = 'Value: ';
    let costText = document.createElement('span');
    let valueText = '';
    for (let i = 0; i < building.cost.length; i++) {
      valueText += building.cost[i].count + ' ' + building.cost[i].name.toLowerCase() + ', ';
    }
    costText.innerText = valueText.slice(0, -2);
    costText.setAttribute('id', 'cost');
    buildMenuBody.appendChild(cost);
    buildMenuBody.appendChild(costText);
    showBuildingEffects(building, buildMenuBody);

    let buttonDiv = document.createElement('div');
    buttonDiv.setAttribute('class', 'justify-end justify-items-end flex');
    let destroyButton = document.createElement('a');
    destroyButton.setAttribute('class', 'btn btn-error w-24 mt-4');
    destroyButton.innerText = 'Destroy';
    destroyButton.onclick = () => {
      console.log('destroying building ' + building.name);
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
  }
}

function showBuildingEffects(building, buildMenu) {
  let produces = document.createElement('span');
  produces.setAttribute('class', 'mt-2 text-xl font-bold text-info');
  produces.innerText = 'Produces: ';
  buildMenu.appendChild(produces);
  let producesText = document.createElement('span');
  producesText.setAttribute('id', 'produces');
  producesText.innerText = 'Production for ' + building.name;
  buildMenu.appendChild(producesText);
  let bonuses = document.createElement('span');
  bonuses.setAttribute('class', 'mt-2 text-xl font-bold text-success');
  bonuses.innerText = 'Bonuses: ';
  buildMenu.appendChild(bonuses);
  let bonusesText = document.createElement('span');
  bonusesText.setAttribute('id', 'bonuses');
  bonusesText.innerText = 'Bonuses for ' + building.name;
  buildMenu.appendChild(bonusesText);
}

function clearModal() {
  const buildMenuBody = document.getElementById('modalMenuBody');
  while (buildMenuBody.children.length > 0) {
    buildMenuBody.removeChild(buildMenuBody.lastChild);
  }
}

function pictureForBuilding(building) {
  // Remove spaces and append .png
  return building === '' ? 'NoHouse.png' : building.replace(/\s/g, '') + '.png';
}