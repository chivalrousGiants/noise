import Node from './Node';

class ChildNode extends Node {
  constructor(id, str, x = 0, y = 0, parent) {
    super(id, str, x, y);
    this.parent = parent;
    this.linkCount = null;
    this.children = null;
  }
}

export default ChildNode;
