import Node from './Node';

class ChildNode extends Node {
  constructor(id, str, x, y, parent) {
    super(id, str, x, y);
    this.parent = parent;
    this.isLinked = false;
    this.linkCount = null;
    this.children = null;
  }
}

export default ChildNode;
