import Node from './Node';
import ChildNode from './ChildNode';

const PRESENTATION_MODE = true;

const width = PRESENTATION_MODE ? 1280 : window.innerWidth;
const height = PRESENTATION_MODE ? 720 : window.innerHeight;
const pixelRatio = PRESENTATION_MODE ? 1 : window.devicePixelRatio;

const ROOT_SPACING = 800;
const NODE_SPREAD = 1000;
const CHILDREN_CONNECT_BOUND = 0.05 * width;
const ATTRACTOR_START_BOUND = 0.4 * width;
const ATTRACTOR_FINISH_BOUND = 0.7 * width;


const canvas = document.querySelector("#canvas");
canvas.width = width * pixelRatio;
canvas.height = height * pixelRatio;
canvas.style.width = `${Math.floor(width)}px`;
canvas.style.height = `${Math.floor(height)}px`;
const context = canvas.getContext("2d", {alpha: false});
context.scale(pixelRatio, pixelRatio);


const rootNodes = generateFakeData();

function generateFakeData() {
  const NUM_ROOTS = 30;
  const NUM_CHILDREN = 80;

  return [...Array(NUM_ROOTS)].map((_, i) => {
    const id = String(i);
    const str = `v${i}`;
    const x = 0 - (i * ROOT_SPACING) - NODE_SPREAD;
    const y = height / 2;
    const node = new Node(id, str, x, y);

    [...Array(NUM_CHILDREN)].forEach((_, j) => {
      const id = `${node.id}_${j}`;
      const str = chance.string().slice(0, 5);
      const x = 0 - (i * ROOT_SPACING) - NODE_SPREAD * Math.random();
      const y = height * Math.random();
      const child = new ChildNode(id, str, x, y, node);
      node.addChild(child);
    });

    node.simulation = d3.forceSimulation(node.children.concat(node))
      .alphaTarget(1)
      .force("childLink", d3.forceLink().id(function(d) { return d.id; }).distance(200).strength(0.04))
      .force("siblingLink", d3.forceLink().id(function(d) { return d.id; }).distance(60).strength(0.0008))
      .force("charge", d3.forceManyBody().strength(-18).distanceMax(80))
      .force("flowX", d3.forceX(3000).strength(0.0004))
      .force("keepInside", d3.forceY(width / 4).strength(0.0001))
    
    return node;
  });
}

// function updateNodes() {
//   Add/remove nodes as needed here
// }
// updateNodes();

function updateLinks() {
  rootNodes.forEach(node => {
    if (node.childLinks.length !== node.children.length) {
      node.simulation
        .force('childLink')
        .links(node.childLinks);
    } else {
      // All children found, contract node
      node.simulation
        .force('childLink')
        .links(node.childLinks)
        .strength(0.3)
        .distance(60);
    }

    node.simulation
      .force('siblingLink')
      .links(node.siblingLinks);
  });
}

function addChildLink(sourceID, targetID) {
  const link = { "source": `${sourceID}`, "target": `${targetID}`, value: 1 };
  rootNodes[sourceID].childLinks.push(link);
}

function updateLayout() {
  rootNodes.forEach(node => {
    if (node.siblingLinks.length < node.children.length && node.x > CHILDREN_CONNECT_BOUND) {
      node.addNextSiblingLink();
    } else if (node.siblingLinks.length === node.children.length) {
      const nextChild = node.childLinks.length;
      if (nextChild < node.children.length && Math.random() < 0.5) {
        node.children[nextChild].isLinked = true;
        addChildLink(node.id, node.children[nextChild].id);
      } else if (node.linkCount === node.children.length) {
        
      }
    }
  });
  updateLinks();
}
setInterval(updateLayout, 20);

d3.select(canvas)
  .call(d3.drag()
    .container(canvas)
    .subject(dragsubject)
    .on("start", dragstarted)
    .on("drag", dragged)
    .on("end", dragended));

function ticked() {
  context.clearRect(0, 0, width * pixelRatio, height * pixelRatio);

  context.beginPath();
  rootNodes.forEach(node => node.siblingLinks.forEach(drawLink));
  context.strokeStyle = "#333";
  context.stroke();

  context.beginPath();
  rootNodes.forEach(node => node.childLinks.forEach(drawLink));
  context.strokeStyle = "#aaa";
  context.stroke();

  context.beginPath();
  rootNodes.forEach(node => { drawNode(node); node.children.forEach(drawNode) });
  context.fill();
  // context.strokeStyle = "#fff";
  // context.stroke();
  window.requestAnimationFrame(ticked);
}

window.requestAnimationFrame(ticked);

function dragsubject() {
  for (let node of rootNodes) {
    const foundNode = node.simulation.find(d3.event.x, d3.event.y, 50);
    if (foundNode) return foundNode;
  }
}

//////////////////////////////////////////////

function drawLink(d) {
  context.moveTo(d.source.x, d.source.y);
  context.lineTo(d.target.x, d.target.y);
}

function drawNode(d) {
  context.moveTo(d.x, d.y);
  context.arc(d.x, d.y, 3, 0, 2 * Math.PI);
  context.font = "16px MyriadPro-Regular";
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
