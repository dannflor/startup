

export async function populateResources() {
  const resources = await fetch('/resources').then(res => res.json());
  const resourceYields = await fetch('/resources/yields').then(res => res.json());
  const resourceDiv = document.getElementById('resources');
  const scoreDiv = document.getElementById('scoreDiv');
  document.getElementById('score').textContent = await fetch('/score').then(res => res.text());
  let i = 0;
  resources.forEach(resource => {
    const div = document.createElement('div');
    div.setAttribute('class', 'flex-1 flex md:space-x-2 bg-base-100 py-3 rounded-lg mx-1 my-1 px-1 tooltip tooltip-bottom');
    div.setAttribute('data-tip', '+' + resourceYields[i].count + ' per hour');
    const innerDiv = document.createElement('div');
    innerDiv.setAttribute('class', 'mx-auto md:flex-row md:flex md:text-base text-xs');
    const name = document.createElement('div');
    name.setAttribute('class', 'text-info font-bold md:mr-1 text-center md:text-left');
    name.textContent = resource.name + ':';
    const count = document.createElement('div');
    count.setAttribute('class', 'text-neutral-content text-center md:text-left');
    count.setAttribute('id', 'resource' + resource.name);
    count.textContent = resource.count;
    innerDiv.appendChild(name);
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