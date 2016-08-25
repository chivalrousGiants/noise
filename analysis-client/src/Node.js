class Node {
  constructor(id, str, x, y) {
    this.id = id;
    this.str = str;
    this.x = x;
    this.y = y;
    this.linkCount = 0;
    this.children = [];
  }
  
  addChild(child) {
    this.children.push(child);
  }

  connectChildren(addSiblingLinks) {
    const length = this.children.length;
    this.children.forEach((child, i) => {
      const nextIndex = i + 1 !== length ? i + 1 : 0;
      addSiblingLinks(this.children[i].id, this.children[nextIndex].id);
    });
  }
}

export default Node;
