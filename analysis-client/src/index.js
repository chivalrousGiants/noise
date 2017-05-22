import Node from './Node';
import ChildNode from './ChildNode';

const PRESENTATION_MODE = true;

const width = PRESENTATION_MODE ? 1280 : window.innerWidth;
const height = PRESENTATION_MODE ? 720 : window.innerHeight;
const pixelRatio = PRESENTATION_MODE ? 1 : window.devicePixelRatio;

const ROOT_SPACING = 600;
const NODE_SPREAD = 1500;
const CHILDREN_CONNECT_BOUND = 0.05 * width;
const ATTRACTOR_START_BOUND = 0.2 * width;
const ATTRACTOR_FINISH_BOUND = 0.7 * width;


const canvas = document.querySelector('#canvas');

canvas.width = width * pixelRatio;
canvas.height = height * pixelRatio;
canvas.style.width = `${Math.floor(width)}px`;
canvas.style.height = `${Math.floor(height)}px`;

const context = canvas.getContext('2d');
context.scale(pixelRatio, pixelRatio);
context.textAlign = 'center'; 

const topWords = [
  'National Dog Day',
  'Paris',
  'Hillary',
  'Hack Reactor',
  'HannahB',
  'Supreme Court',
  'Trump',
  'Ryan',
  'North Korea',
  'Aaliyah',
  'MDLC',
  'Warriors',
  'Triggered',
  'Julius Buckley',
  'Agar.io',
  'Flights',
  'Jae',
  'Speed Test',
  'Brexit',
];

const rootNodes = generateFakeData();

function generateFakeData() {
  const NUM_ROOTS = 30;
  const NUM_CHILDREN = 60;

  return [...Array(NUM_ROOTS)].map((_, i) => {
    const id = String(i);
    const str = topWords[i % (topWords.length - 1)];
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

      .force('childLink', d3.forceLink().id(function(d) { return d.id; }).distance(200).strength(0.04))
      .force('siblingLink', d3.forceLink().id(function(d) { return d.id; }).distance(60).strength(0.0008))
      .force('charge', d3.forceManyBody().strength(-18).distanceMax(80))
      .force('flowX', d3.forceX(3000).strength(0.0002))
      .force('keepInside', d3.forceY(height / 2).strength(0.0001))
    
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
  const link = { 'source': `${sourceID}`, 'target': `${targetID}`, value: 1 };
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
      }
      if (node.childLinks.length === node.children.length) {
        node.collapsed = true;
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
    .on('start', dragstarted)
    .on('drag', dragged)
    .on('end', dragended));

function ticked() {
  context.clearRect(0, 0, width * pixelRatio, height * pixelRatio);

  rootNodes.forEach(node => node.siblingLinks.forEach(drawSiblingLink));

  rootNodes.forEach(node => node.childLinks.forEach(drawChildLink));

  rootNodes.forEach(node => { drawNode(node); node.children.forEach(drawNode) });
  context.fill();

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

function drawSiblingLink(d) {
  context.beginPath();
  context.moveTo(d.source.x, d.source.y);
  context.lineTo(d.target.x, d.target.y);
  context.strokeStyle = '#373737';
  context.stroke();
}

function drawChildLink(d) {
  context.beginPath();
  context.moveTo(d.source.x, d.source.y);
  context.lineTo(d.target.x, d.target.y);
  // if (d.source.collapsed) debugger;
  context.strokeStyle = d.source.collapsed ? '#222' : '#aaa';
  context.stroke();
}

function drawNode(d) {
  context.moveTo(d.x, d.y);
  // context.arc(d.x, d.y, 3, 0, 2 * Math.PI);

  // If is child
  if (d.parent) {
    if (!d.parent.collapsed) {
      context.font = '16px MyriadPro-Light';
      context.fillStyle = '#aaa';
      context.fillText(d.str, d.x, d.y + 10);  // TEXT
    } else {
      context.font = '16px MyriadPro-Light';
      context.fillStyle = '#555';
      context.fillText(d.str, d.x, d.y + 10);  // TEXT
    }
  } else { // Is parent`
    if (d.collapsed) {
      context.font = '24px MyriadPro-Light';
      context.fillStyle = '#aaa';
      context.fillText(d.str, d.x, d.y + 13);  // TEXT
    }
  }
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
