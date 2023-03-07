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
    // Clear options from selector
    while (select.firstChild) {
      select.removeChild(select.firstChild);
    }
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
      buildingTitle.innerText = selectedBuilding.name;
      
      let costText = '';
      for (let i = 0; i < selectedBuilding.cost.length; i++) {
        costText += selectedBuilding.cost[i].count + ' ' + selectedBuilding.cost[i].name.toLowerCase() + ', ';
      }
      costValue.innerText = costText.slice(0, -2);
      buildMenuImage.setAttribute('src', '/img/' + pictureForBuilding(selectedBuilding.name));
      showBuildingEffects(selectedBuilding);
    }
    select.style.display = 'block';
  
    cost.innerText = 'Cost: ';

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
    select.style.display = 'none';
    buildMenuTitle.innerText = building.name;
    buildingTitle.style.display = 'none';
    cost.textContent = 'Value:';
    let valueText = '';
    for (let i = 0; i < building.cost.length; i++) {
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
    buildMenuImage.setAttribute('src', '/img/' + pictureForBuilding(building.name));
  }
}

function showBuildingEffects(building) {
  document.getElementById('produces').innerText = 'Production for ' + building.name;
  document.getElementById('bonuses').innerText = 'Bonuses for ' + building.name;
}

function pictureForBuilding(building) {
  // Remove spaces and append .png
  return building === '' ? 'NoHouse.png' : building.replace(/\s/g, '') + '.png';
}