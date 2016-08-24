var width = window.innerWidth;
var height = window.innerHeight;

var canvas = document.querySelector("#canvas");
canvas.width = width * 2;
canvas.height = height * 2;
canvas.style.width = `${Math.floor(width)}px`;
canvas.style.height = `${Math.floor(height)}px`;
var context = canvas.getContext("2d");
var ratio = window.devicePixelRatio;
context.scale(ratio, ratio);

var simulation = d3.forceSimulation()
  .alphaTarget(1)
  .force("link", d3.forceLink().id(function(d) { return d.id; }).distance(150).strength(0.4))
  .force("charge", d3.forceManyBody().strength(-1))
  .force("flowX", d3.forceX(3000).strength(0.0002))


// Fake data
graph = {};
graph.nodes = [...Array(30)].map((_, i) => {
  const obj = {};
  obj.id = String(i);
  obj.str = `v${i}`;
  // obj.x = width / 2;
  // obj.y = height / 2;

  obj.children = [...Array(30)].map((_, j) => {
    const childObj = {};
    childObj.id = `${obj.id}_${j}`;
    childObj.str = chance.string().slice(0, 5);
    // childObj.x = Math.random() * width;
    // childObj.y = Math.random() * height;
    return childObj;
  });
  return obj;
});

graph.links = [

];

// console.dir(graph);
// debugger;

let currentNode = 0;
let currentChild = 0;
const interval = setInterval(() => {
  if (currentChild === 30) {
    currentChild = 0;
    currentNode++;
  }
  if (currentNode === 30) {
    clearInterval(interval);
    return;
  }
  
  graph.links.push({"source": `${currentNode}`, "target": `${currentNode}_${currentChild}`, value: 1});

  simulation.force("link")
    .links(graph.links);

  currentChild++;
}, 0);

const allNodes = graph.nodes.slice();
graph.nodes.forEach(node => node.children.forEach(child => allNodes.push(child)));

simulation
  .nodes(allNodes)
  .on("tick", ticked);

simulation.force("link")
  .links(graph.links);

d3.select(canvas)
  .call(d3.drag()
    .container(canvas)
    .subject(dragsubject)
    .on("start", dragstarted)
    .on("drag", dragged)
    .on("end", dragended));


function ticked() {
  context.clearRect(0, 0, width * 2, height * 2);

  context.beginPath();
  graph.links.forEach(drawLink);
  context.strokeStyle = "#555";
  context.stroke();

  context.beginPath();
  allNodes.forEach(drawNode);
  context.fill();
  // context.strokeStyle = "#fff";
  // context.stroke();
}

function dragsubject() {
  return simulation.find(d3.event.x, d3.event.y, 50);
}

//////////////////////////////////////////////

function drawLink(d) {
  context.moveTo(d.source.x, d.source.y);
  context.lineTo(d.target.x, d.target.y);
}

function drawNode(d) {
  context.moveTo(d.x + 3, d.y);
  context.arc(d.x, d.y, 3, 0, 2 * Math.PI);
  context.font = "16px Helvetica Neue";
  context.fillStyle = '#aaa';
  context.fillText(d.str, d.x + 10, d.y + 5);  // TEXT
}

function dragstarted() {
  d3.event.subject.fx = d3.event.subject.x;
  d3.event.subject.fy = d3.event.subject.y;
}

function dragged() {
  d3.event.subject.fx = d3.event.x;
  d3.event.subject.fy = d3.event.y;
}

function dragended() {
  d3.event.subject.fx = null;
  d3.event.subject.fy = null;
}
