class Node {
  constructor(id, str, x, y) {
    this.id = id;
    this.str = str;
    this.x = x;
    this.y = y;
    this.children = [];
    this.childLinks = [];
    this.siblingLinks = [];
  }
  
  addChild(child) {
    this.children.push(child);
  }

  addNextSiblingLink() {
    const nextIndex = this.siblingLinks.length;
    const targetIndex = nextIndex + 1 === this.children.length ? 0 : nextIndex + 1;
    const link = { "source": `${this.children[nextIndex].id}`, "target": `${this.children[targetIndex].id}`, value: 1 };
    this.siblingLinks.push(link);
  }
}

export default Node;
