import Node from './Node';

class ChildNode extends Node {
  constructor(id, str, x = 0, y = 0, parent) {
    super(id, str, x, y);
    this.parent = parent;
    this.linkCount = null;
    this.children = null;
  }

  addParentLinkIfPastXLimit(xLimit, addGlobalLink, updateLinks) {
    if (this.x > xLimit) {
      addGlobalLink(this.parent.id, this.id);
    }
  }
}

export default ChildNode;
