// Copyright (c) 2020 sooxie
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
import '../tree_define.dart';
import '../node/tree_node.dart';

///
class NodeController {
  static final min = -1;

  NodeController({this.parent, this.nodeItem, this.expandCallback})
      : treeNode = TreeNode(lazyItem: nodeItem, expandCallback: expandCallback),
        _index = min,
        _level = min,
        _numberOfVisibleChildren = min,
        _mutableChildControllers = [];

  final NodeController parent;
  final TreeNodeItem nodeItem;
  final TreeNode treeNode;

  final ExpandCallback expandCallback;

  int _index;
  List<NodeController> _mutableChildControllers;

  int _level;
  int _numberOfVisibleChildren;

  List<NodeController> get childControllers => _mutableChildControllers;

  void resetData() {
    _numberOfVisibleChildren = min;
    _index = min;
//    resetNumberOfVisibleChildren();
//    resetIndex();
  }

  /// Gets the index associated with the data
  int indexOfItem(dynamic item) {
    var controller = controllerOfItem(item);
    return (controller != null) ? controller.index : min;
  }

  /// Gets the controller associated with the data
  NodeController controllerOfItem(dynamic item) {
    if (item == treeNode.item) {
      return this;
    }
    for (NodeController controller in childControllers) {
      var result = controller.controllerOfItem(item);
      if (result != null) {
        return result;
      }
    }
    return null;
  }

  ///
  void addChildController(List<NodeController> controllers) {
    if (controllers == null || controllers.length == 0) {
      return;
    }
    _mutableChildControllers.addAll(controllers);
    resetNodesAfterChildAtIndex(min);
  }

  void insertChildControllers(
      List<NodeController> controllers, List<int> indexes) {
    if (controllers == null || controllers.length == 0) {
      return;
    }
    indexes.forEach((index) {
      _mutableChildControllers.insert(index, controllers[index]);
    });

    resetNodesAfterChildAtIndex(min);
  }

  void insertNewChildControllers(NodeController controller, int index) {
    if (controller == null) {
      return;
    }
    _mutableChildControllers.insert(index, controller);

    resetNodesAfterChildAtIndex(min);
  }

  ///Remove
  void removeChildControllers(List<int> indexes) {
    if (indexes.length == 0) {
      return;
    }
    indexes.forEach((index) {
      _mutableChildControllers.removeAt(index);
    });
    resetNodesAfterChildAtIndex(-1);
  }

  void removeChildControllersForParent(dynamic parent, int index) {}

  void resetNodesAfterChildAtIndex(int index) {
    int selfIndex;
    if (parent == null) {
      selfIndex = 0;
    } else {
      selfIndex = parent.childControllers.indexOf(this);
      parent.resetNodesAfterChildAtIndex(selfIndex);
    }

    resetData();

    resetChildNodesAfterChildAtIndex(index);
  }

  void resetChildNodesAfterChildAtIndex(int index) {
    if (!treeNode.expanded) {
      return;
    }

    for (int i = index + 1; i < childControllers.length; i++) {
      NodeController controller = childControllers[i];
      controller.resetData();
      controller.resetChildNodesAfterChildAtIndex(-1);
    }
  }

  /// Collapsing and expanding

  void expandAndExpandChildren(bool expandChildren) {
    for (NodeController controller in childControllers) {
      controller.resetData();
    }

    treeNode.setExpanded = true;
    resetData();

    /// Recursively expand all child nodes
    for (NodeController controller in childControllers) {
      if (controller.treeNode.expanded || expandChildren) {
        controller.expandAndExpandChildren(expandChildren);
      }
    }

    parent.resetNodesAfterChildAtIndex(parent.childControllers.indexOf(this));
  }

  ///collapse
  void collapseAndCollapseChildren(bool collapseChildren) {
    treeNode.setExpanded = false;
    resetData();

    ///collapse children
    if (collapseChildren) {
      for (NodeController controller in childControllers) {
        controller.collapseAndCollapseChildren(collapseChildren);
      }
    }
    parent.resetNodesAfterChildAtIndex(parent.childControllers.indexOf(this));
  }

  /// Collapsing and expanding - end
  int numberOfVisibleDescendants() {
    if (this.treeNode != null && this.treeNode.expanded) {
      int sum = this.childControllers.length;
      this.childControllers.forEach((item) {
        sum += item.numberOfVisibleDescendants();
      });
      _numberOfVisibleChildren = sum;
    } else {
      return 0;
    }
    return _numberOfVisibleChildren;
  }

  NodeController controllerForIndex(int index) {
    if (this.index == index) {
      return this;
    }

    if (!treeNode.expanded) {
      return null;
    }
    for (NodeController controller in childControllers) {
      var result = controller.controllerForIndex(index);
      if (result != null) {
        return result;
      }
    }
    return null;
  }

  int get index {
    if (_index != min) {
      return _index;
    }
    if (parent == null) {
      _index = -1;
    } else if (!parent.treeNode.expanded) {
      _index = -1;
    } else {
      var indexOf = parent.childControllers.indexOf(this);
      if (indexOf != 0) {
        var controller = parent.childControllers[indexOf - 1];
        _index = controller.lastVisibleDescendatIndex + 1;
      } else {
        _index = parent.index + 1;
      }
    }
    return _index;
  }

  int get lastVisibleDescendatIndex {
    return _index + numberOfVisibleDescendants();
  }

  int lastVisibleDescendantIndexForItem(dynamic item) {
    if (this.treeNode.item == item) {
      return this.lastVisibleDescendatIndex;
    }

    for (NodeController nodeController in childControllers) {
      int lastIndex = nodeController.lastVisibleDescendantIndexForItem(item);
      if (lastIndex != -1) {
        return lastIndex;
      }
    }
    return -1;
  }

  /// NodeController's level
  int get level {
    if (treeNode.item == null) {
      return -1;
    }
    if (_level == min) {
      _level = parent.level + 1;
    }
    return _level;
  }

  List<int> get descendantsIndexes {
    int numberOfVisible = numberOfVisibleDescendants();
    int startIndex = _index + 1;
    List<int> indexes = [];
    for (int i = startIndex; i < startIndex + numberOfVisible; i++) {
      indexes.add(i);
    }
    return indexes;
  }
}
