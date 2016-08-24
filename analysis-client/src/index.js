import Node from './Node';
import ChildNode from './ChildNode';


const width = window.innerWidth;
const height = window.innerHeight;
const pixelRatio = window.devicePixelRatio;

const canvas = document.querySelector("#canvas");
canvas.width = width * 2;
canvas.height = height * 2;
canvas.style.width = `${Math.floor(width)}px`;
canvas.style.height = `${Math.floor(height)}px`;
const context = canvas.getContext("2d");
context.scale(pixelRatio, pixelRatio);

const simulation = d3.forceSimulation()
  .alphaTarget(1)
  .force("link", d3.forceLink().id(function(d) { return d.id; }).distance(60).strength(0.4))
  .force("charge", d3.forceManyBody().strength(-1))
  .force("flowX", d3.forceX(3000).strength(0.002))

const graph = generateFakeData();
let allNodes = [];
let allLinks = [];

function generateFakeData() {
  const graph = {};

  graph.nodes = [...Array(20)].map((_, i) => {
    const node = new Node(String(i), `v${i}`, width - (i * 600) - 600, height / 2);

    [...Array(60)].forEach((_, j) => {
      const id = `${node.id}_${j}`;
      const str = chance.string().slice(0, 5);
      const x = width - 600 - (i * 600) + Math.random() * 600;
      const y = height / 60 * j;
      const child = new ChildNode(id, str, x, y, node);
      node.addChild(child);
    });

    return node;
  });

  return graph;
}

function updateNodes() {
  allNodes = graph.nodes.reduce((all, node) => all.concat(node.children), graph.nodes);
  simulation
    .nodes(allNodes)
    .on("tick", ticked);
}
updateNodes();

function updateLinks() {
  simulation.force("link")
    .links(allLinks);
}

function addGlobalLink(sourceID, targetID) {
  allLinks.push({ "source": `${sourceID}`, "target": `${targetID}`, value: 1 });
  console.log(allLinks.length);
}

function updateLayout() {
  allNodes.forEach(node => {
    node.addParentLinkIfPastXLimit(500, addGlobalLink, updateLinks);
  });
  updateLinks();
}
setInterval(updateLayout, 100);


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
  allLinks.forEach(drawLink);
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
  context.fillText(d.str, d.x - 25, d.y + 20);  // TEXT
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
