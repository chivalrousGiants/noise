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

  addParentLinkIfPastXLimit() {
    
  }
}

export default Node;
