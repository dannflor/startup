class Building {
  constructor(cell) {
    this.name = cell.name;
    this.img = cell.img;
    this.cost = cell.cost;
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
      img.setAttribute('src', cell.img);
      img.setAttribute('class', '');
      img.setAttribute('style', 'image-rendering: crisp-edges; image-rendering: pixelated;');
      gridCell.appendChild(img);
      gridElement.appendChild(gridCell);

      gridCell.onclick = () => { editBuildMenu(cell) };
    }
  })
);

/**
 * Building prompt behaves differently depending on
 * whether or not the clicked space has a building.
 */
function editBuildMenu(building) {
  const buildMenu = document.getElementById('buildMenu');
  const buildMenuTitle = document.getElementById('buildMenuTitle');

  //TODO: Modify this to instead build the buildMenu from the ground up
  //using appendChild and innerHTML. The two menus will be totally different.
  if (building.name === "") {
    // console.log("no building");
    buildMenuTitle.innerText = "Build";
  }
  else {
    // console.log(building.name);
    buildMenuTitle.innerText = building.name;
  }
}