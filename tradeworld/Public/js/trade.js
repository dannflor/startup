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

class ResourceQty {
  constructor(name, count) {
    this.name = name;
    this.count = count;
  }
}

class TradeResponse {
  constructor(trade, type) {
    this.trade = trade;
    this.type = type;
  }
}

WebSocket.prototype.sendJsonBlob = function(data) {
  const string = JSON.stringify({ client: uuid, data: data })
  console.log(string)
  const blob = new Blob([string], {type: "application/json"});
  this.send(blob)
};

function blobToJson(blob) {
  return new Promise((resolve, reject) => {
    let fr = new FileReader();
    fr.onload = () => {
        resolve(JSON.parse(fr.result));
    };
    fr.readAsText(blob);
});
}

function uuidv4() {
  return ([1e7]+-1e3+-4e3+-8e3+-1e11).replace(/[018]/g, c => (c ^ crypto.getRandomValues(new Uint8Array(1))[0] & 15 >> c / 4).toString(16));
}

const uuid = uuidv4()
let socket = null;

let trades = [];
function configureWebSocket() {
  const protocol = window.location.protocol === 'http:' ? 'ws' : 'wss';
  socket = new WebSocket(`${protocol}://${window.location.host}/trade/all`);
  socket.binaryType = 'blob';
  socket.onopen = (event) => {
    console.log('connected');
    socket.sendJsonBlob({connect: true});
  };
  socket.onclose = (event) => {
    console.log('disconnected ' + event.code);
  };
  socket.onmessage = async (event) => {
    // console.log(event.data);
    const msg = await blobToJson(event.data);
    if (msg.type === "addTrades") {
      trades = msg.trades.map(trade => new Trade(trade));
    }
    else if (msg.type === "removeTrades") {
      trades = trades.filter(trade => !msg.trades.includes(trade.id));
    }
    loadTrades(trades);
  };
}

async function loadTrades(trades) {
  const tradeList = document.getElementById("tradeList");
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
    input.onclick = () => acceptTrade(trade);
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

async function acceptTrade(trade) {
  fadeAway("cell" + trade.id);
  socket.sendJsonBlob(new TradeResponse(trade, "acceptTrade"));
  
}

async function sendTrade() {
  let offerSelect = document.getElementById("offerResource");
  let askSelect = document.getElementById("askResource");
  let offerType = offerSelect.options[offerSelect.selectedIndex].text;
  let offerCount = parseInt(document.getElementById("offerCount").value);
  let askType = askSelect.options[askSelect.selectedIndex].text;
  let askCount = parseInt(document.getElementById("askCount").value);
  let message = document.getElementById("tradeMessage").value;
  let username = await fetch("/user/me").then((res) => res.text());
  let trade = {
    id: null,
    seller: username,
    offer: {
      name: offerType,
      count: offerCount
    },
    ask: {
      name: askType,
      count: askCount
    },
    message: message
  }
  console.log("Sending trade");
  socket.sendJsonBlob(new TradeResponse(trade, "addTrade"));
  console.log("Sent trade");
}

await populateResources();

configureWebSocket();

document.getElementById("sendTradeButton").onclick = () => sendTrade();