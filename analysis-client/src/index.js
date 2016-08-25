import Node from './Node';
import ChildNode from './ChildNode';

const PRESENTATION_MODE = false;

const width = PRESENTATION_MODE ? 1280 : window.innerWidth;
const height = PRESENTATION_MODE ? 720 : window.innerHeight;
const pixelRatio = PRESENTATION_MODE ? 1 : window.devicePixelRatio;

const ROOT_SPACING = 200;
const NODE_SPREAD = 800;
const ATTRACTOR_START_BOUND = 0.05 * width;
const ATTRACTOR_FINISH_BOUND = 0.4 * width;


const canvas = document.querySelector("#canvas");
canvas.width = width * pixelRatio;
canvas.height = height * pixelRatio;
canvas.style.width = `${Math.floor(width)}px`;
canvas.style.height = `${Math.floor(height)}px`;
const context = canvas.getContext("2d");
context.scale(pixelRatio, pixelRatio);

const simulation = d3.forceSimulation()
  .alphaTarget(1)
  .force("childLink", d3.forceLink().id(function(d) { return d.id; }).distance(200).strength(0.4))
  .force("siblingLink", d3.forceLink().id(function(d) { return d.id; }).distance(60).strength(0.001))
  .force("charge", d3.forceManyBody().strength(-1))
  .force("flowX", d3.forceX(3000).strength(0.0001))
  .force("keepInside", d3.forceY(width / 4).strength(0.0007))

const rootNodes = generateFakeData();
let allNodes = [];
let childLinks = [];
let siblingLinks = [];

function generateFakeData() {
  const NUM_ROOTS = 10;
  const NUM_CHILDREN = 30;

  return [...Array(NUM_ROOTS)].map((_, i) => {
    const node = new Node(String(i), `v${i}`, 0 - (i * ROOT_SPACING) - NODE_SPREAD * 0.5, height / 2);

    [...Array(NUM_CHILDREN)].forEach((_, j) => {
      const id = `${node.id}_${j}`;
      const str = chance.string().slice(0, 5);
      const x = 0 - (i * ROOT_SPACING) - NODE_SPREAD * Math.random();
      const y = height * Math.random();
      const child = new ChildNode(id, str, x, y, node);
      node.addChild(child);
    });

    return node;
  });
}

function updateNodes() {
  allNodes = rootNodes.reduce((all, node) => all.concat(node.children), rootNodes);
  simulation
    .nodes(allNodes)
    .on("tick", ticked);
}
updateNodes();

function updateLinks() {
  simulation.force("childLink")
    .links(childLinks);
  simulation.force("siblingLink")
    .links(siblingLinks);
}

function addChildLink(sourceID, targetID) {
  childLinks.push({ "source": `${sourceID}`, "target": `${targetID}`, value: 1 });
}

function addSiblingLinks(sourceID, targetID) {
  siblingLinks.push({ "source": `${sourceID}`, "target": `${targetID}`, value: 1 });
}

function updateLayout() {
  rootNodes.forEach(node => {
    if (node.x > ATTRACTOR_START_BOUND) {
      if (node.linkCount < node.children.length && Math.random() < 0.5) {
        addChildLink(node.id, node.children[node.linkCount].id);
        node.children[node.linkCount].isLinked = true;
        node.linkCount++;
      } else if (node.lintCount === node.children.length) {
        // collapse node

      }
    }
  });
  updateLinks();
}
setInterval(updateLayout, 100);

rootNodes.forEach(node => {
  node.connectChildren(addSiblingLinks);
});

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
  siblingLinks.forEach(drawLink);
  context.strokeStyle = "#333";
  context.stroke();

  context.beginPath();
  childLinks.forEach(drawLink);
  context.strokeStyle = "#aaa";
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
  context.moveTo(d.x, d.y);
  context.arc(d.x, d.y, 3, 0, 2 * Math.PI);
  context.font = "16px Helvetica Neue";
  context.fillStyle = '#aaa';
  context.fillText(d.str, d.x - 25, d.y + 10);  // TEXT
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
