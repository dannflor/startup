import fadeAway from "./fadeAway";

class Tech {
  constructor(tech) {
    this.id = tech.id;
    this.name = tech.title;
    this.description = tech.description;
    this.price = tech.price;
  }
}

async function loadTechList() {
  const techList = document.getElementById("techList");
  const techs = await fetch("/tech/unresearched").then((res) => res.json());
  techs.map(tech => new Tech(tech));
  techs.forEach(tech => {
    
  });
}

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