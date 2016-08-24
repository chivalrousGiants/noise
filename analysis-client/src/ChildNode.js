import Node from './Node';

class ChildNode extends Node {
  constructor(id, str, x = 0, y = 0, parent) {
    super(id, str, x, y);
    this.parent = parent;
    this.isLinked = false;
    this.linkCount = null;
    this.children = null;
  }

  addParentLinkIfPastXLimit(xLimit, addGlobalLink, updateLinks) {
    if (!this.isLinked && this.x > xLimit && Math.random() > 0.8) {
      addGlobalLink(this.parent.id, this.id);
      this.isLinked = true;
    }
  }
}

export default ChildNode;
