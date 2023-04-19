

export async function populateResources() {
  const resources = await fetch('/resources').then(res => res.json());
  const resourceYields = await fetch('/resources/yields').then(res => res.json());
  const resourceDiv = document.getElementById('resources');
  const scoreDiv = document.getElementById('scoreDiv');
  document.getElementById('score').textContent = await fetch('/score').then(res => res.text());
  let i = 0;
  resources.forEach(resource => {
    const div = document.createElement('div');
    div.setAttribute('class', 'flex-1 flex md:space-x-2 py-3 rounded-lg mx-1 my-1 px-1 tooltip tooltip-bottom');
    div.setAttribute('data-tip', '+' + resourceYields[i].count + ' per hour');
    const innerDiv = document.createElement('div');
    innerDiv.setAttribute('class', 'mx-auto md:flex-row md:flex text-base');
    const imageContainer = document.createElement('div');
    imageContainer.setAttribute('class', 'w-10');
    const image = document.createElement('img');
    // Set name to lowercase to match image name
    image.setAttribute('src', '/img/icon/' + resource.name.toLowerCase() + '.png');
    image.setAttribute('class', 'w-full h-auto block');
    image.setAttribute('style', 'image-rendering: pixelated; image-rendering: crisp-edges;');
    imageContainer.appendChild(image);
    innerDiv.appendChild(imageContainer);
    const count = document.createElement('div');
    count.setAttribute('class', 'text-info font-bold text-center md:ml-2 md:text-left my-auto');
    count.setAttribute('id', 'resource' + resource.name);
    count.textContent = resource.count;
    innerDiv.appendChild(count);
    div.appendChild(innerDiv);
    resourceDiv.insertBefore(div, scoreDiv);
    i += 1;
  });
}

export async function updateResources() {
  const resources = await fetch('/resources').then(res => res.json());
  const resourceYields = await fetch('/resources/yields').then(res => res.json());
  const resourceDiv = document.getElementById('resources');
  document.getElementById('score').textContent = await fetch('/score').then(res => res.text());
  let i = 0;
  resources.forEach(resource => {
    document.getElementById('resource' + resource.name).textContent = resource.count;
    resourceDiv.children[i].setAttribute('data-tip', '+' + resourceYields[i].count + ' per hour');
    i += 1;
  });
}