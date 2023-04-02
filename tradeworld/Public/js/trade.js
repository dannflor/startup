import fadeAway from "./fadeAway.js";
import {populateResources, updateResources} from "./populateResources.js";

class Trade {
  constructor(trade) {
    this.id = trade.id;
    this.seller = trade.seller;
    this.message = trade.message;
    this.offer = trade.offer;
    this.ask = trade.ask;
  }
}

loadTrades();

async function loadTrades() {
  const tradeList = document.getElementById("tradeList");
  const trades = await fetch("/trade/all").then((res) => res.json());
  trades.map(trade => new Trade(trade));
  /*
  #for(trade in trades):
    <li id="cell#(trade.id)" class="mb-4 max-h-36 min-h-[5rem] sm:w-[32rem] w-[21.5rem] border-2 border-primary hover:border-primary-focus rounded-xl flex p-2 flex-row">
      <input type="checkbox" class="checkbox hover:checkbox-accent sm:checkbox-md checkbox-sm flex my-auto sm:ml-4 ml-2" onclick="fadeAway('cell#(trade.id)')"/> 
      <div class="my-auto flex-col ml-4">
        <div class="flex-row flex">
          <div class="text-secondary font-serif font-bold sm:text-xl text-sm">
            #(trade.seller)
          </div>
          <div class="sm:text-base text-xs font-black text-accent my-auto sm:ml-5 ml-2 sm:mr-2 mr-0.5">
            OFFER:
          </div>
          <div class="sm:text-base text-xs my-auto">
            #(trade.offer.count) #(trade.offer.name)
          </div>
          <div class="sm:text-base text-xs font-black my-auto text-info sm:ml-5 ml-2 sm:mr-2 mr-0.5">
            ASK:
          </div>
          <div class="sm:text-base text-xs my-auto">
            #(trade.ask.count) #(trade.ask.name)
          </div>
        </div>
        <div class="divider !my-0 mr-4 !h-2 sm:w-[27rem] w-[17rem]"></div> 
        <div class="sm:text-base text-xs sm:mr-2 mr-0.5">
          #(trade.message)
        </div>
      </div>
    </li>
  #endfor
  */
  trades.forEach(trade => {
    const li = document.createElement("li");
    li.setAttribute("id", "cell" + trade.id);
    li.setAttribute("class", "mb-4 max-h-36 min-h-[5rem] sm:w-[32rem] w-[21.5rem] border-2 border-primary hover:border-primary-focus rounded-xl flex p-2 flex-row");
    const input = document.createElement("input");
    input.setAttribute("type", "checkbox");
    input.setAttribute("class", "checkbox hover:checkbox-accent sm:checkbox-md checkbox-sm flex my-auto sm:ml-4 ml-2");
    input.onclick = () => acceptTrade(trade.id);
    const div = document.createElement("div");
    div.setAttribute("class", "my-auto flex-col ml-4");
    const div1 = document.createElement("div");
    div1.setAttribute("class", "flex-row flex");
    const div2 = document.createElement("div");
    div2.setAttribute("class", "text-secondary font-serif font-bold sm:text-xl text-sm");
    div2.textContent = trade.seller;
    const div3 = document.createElement("div");
    div3.setAttribute("class", "sm:text-base text-xs font-black text-accent my-auto sm:ml-5 ml-2 sm:mr-2 mr-0.5");
    div3.textContent = "OFFER:";
    const div4 = document.createElement("div");
    div4.setAttribute("class", "sm:text-base text-xs my-auto");
    div4.textContent = trade.offer.count + " " + trade.offer.name;
    const div5 = document.createElement("div");
    div5.setAttribute("class", "sm:text-base text-xs font-black my-auto text-info sm:ml-5 ml-2 sm:mr-2 mr-0.5");
    div5.textContent = "ASK:";
    const div6 = document.createElement("div");
    div6.setAttribute("class", "sm:text-base text-xs my-auto");
    div6.textContent = trade.ask.count + " " + trade.ask.name;
    const div7 = document.createElement("div");
    div7.setAttribute("class", "divider !my-0 mr-4 !h-2 sm:w-[27rem] w-[17rem]");
    const div8 = document.createElement("div");
    div8.setAttribute("class", "sm:text-base text-xs sm:mr-2 mr-0.5");
    div8.textContent = trade.message;
    div1.appendChild(div2);
    div1.appendChild(div3);
    div1.appendChild(div4);
    div1.appendChild(div5);
    div1.appendChild(div6);
    div.appendChild(div1);
    div.appendChild(div7);
    div.appendChild(div8);
    li.appendChild(input);
    li.appendChild(div);
    tradeList.appendChild(li);
  });
}

async function acceptTrade(tradeId) {
  fadeAway("cell" + tradeId);
  await fetch("/trade/accept/" + tradeId, {
    method: "POST"
  });
}

await populateResources();