class Node {
  constructor(id, str, x = 0, y = 0) {
    this.id = id;
    this.str = str;
    this.x = x;
    this.y = y;
    this.linkCount = 0;
    this.children = [];
    this.links = [];
  }
  
  addChild(child) {
    this.children.push(child);
  }

  addRandomChildLink() {
    if (this.linkCount < this.children.length) {
      this.links.push({ "source": `${this.id}`, "target": `${this.children[this.linkCount].id}`, value: 1 });
      this.linkCount++;

    } else {
      console.log(`All children of node ${this.id} are already linked.`);
    }
  }
}

export default Node;
