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
import 'package:flutter/cupertino.dart';
import 'node_controller.dart';
import '../node/tree_node.dart';

/// Controls the ListTreeView.
class TreeViewController extends ChangeNotifier {
  TreeViewController();

  NodeController _rootController;

  dynamic rootDataNode;
  List<dynamic> data;


  void treeData(List data) {
    assert(data != null, 'The data should not be empty');
    this.data = data;
    notifyListeners();

  }

  /// Gets the data associated with each item
  dynamic dataForTreeNode(TreeNodeItem nodeItem) {
    NodeData nodeData = nodeItem.parent;
    if (nodeData == null) {
      return data[nodeItem.index];
    }
    return nodeData.children[nodeItem.index];
  }

  ///
  int itemChildrenLength(dynamic item) {
    if (item == null) {
      return data.length;
    }
    NodeData nodeData = item;
    return nodeData.children.length;
  }

  ///Gets the number of visible children of the ListTreeView
  int numberOfVisibleChild() {
    return this.rootController.numberOfVisibleDescendants();
  }

  ///Get the controller for the root node. If null will be initialized according to the data
  NodeController get rootController {
    if (_rootController == null) {
      _rootController = NodeController(
          parent: _rootController,
          expandCallback: (dynamic item) {
            return true;
          });
      int num = data.length;

      List<int> indexes = [];
      for (int i = 0; i < num; i++) {
        indexes.add(i);
      }
      var controllers = createNodeController(_rootController, indexes);
      _rootController.insertChildControllers(controllers, indexes);
    }
    return _rootController;
  }

  /// Click item to expand or contract or collapse
  /// [index] The index of the clicked item
  TreeNode expandOrCollapse(int index) {
    var treeNode = treeNodeOfIndex(index);
    if (treeNode.expanded) {
      collapseItem(treeNode);
    } else {
      expandItem(treeNode);
    }

    ///notify refresh ListTreeView
    notifyListeners();
    return treeNode;
  }

  bool isExpanded(dynamic item) {
    int index = indexOfItem(item);
    return treeNodeOfIndex(index).expanded;
  }

  /// Begin collapse
  void collapseItem(TreeNode treeNode) {
    NodeController controller = _rootController.controllerOfItem(treeNode.item);
    controller.collapseAndCollapseChildren(true);
  }

  /// Begin expand
  void expandItem(TreeNode treeNode) {
//    NodeController parentController = _rootController.controllerOfItem(treeNode.item);
    List items = [treeNode.item];
    while (items.length > 0) {
      var currentItem = items.first;
      items.remove(currentItem);
      NodeController controller = _rootController.controllerOfItem(currentItem);
      List oldChildItems = [];
      for (NodeController controller in controller.childControllers) {
        oldChildItems.add(controller);
      }
      int numberOfChildren = itemChildrenLength(currentItem);
      List<int> indexes = [];
      for (int i = 0; i < numberOfChildren; i++) {
        indexes.add(i);
      }
      var currentChildControllers = createNodeController(controller, indexes);
      List<NodeController> childControllersToInsert = [];
      List<int> indexesForInsertions = [];
      List<NodeController> childControllersToRemove = [];
      List<int> indexesForDeletions = [];
      for (NodeController loopNodeController in currentChildControllers) {
        if (!controller.childControllers.contains(loopNodeController) &&
            !oldChildItems.contains(controller.treeNode.item)) {
          childControllersToInsert.add(loopNodeController);
          int index = currentChildControllers.indexOf(loopNodeController);
          assert(index != -1);
          indexesForInsertions.add(index);
        }
      }

      for (NodeController loopNodeController in controller.childControllers) {
        if (!currentChildControllers.contains(loopNodeController) &&
            !childControllersToInsert.contains(loopNodeController)) {
          childControllersToRemove.add(loopNodeController);
          int index = controller.childControllers.indexOf(loopNodeController);
          assert(index != -1);
          indexesForDeletions.add(index);
        }
      }

      controller.removeChildControllers(indexesForDeletions);
      controller.insertChildControllers(
          childControllersToInsert, indexesForInsertions);
      bool expandChildren = false;
      if (expandChildren) {
        for (NodeController nodeController in controller.childControllers) {
          items.add(nodeController.treeNode.item);
        }
      }
      controller.expandAndExpandChildren(false);
      notifyListeners();
    }
  }

  /// Insert a node in the head
  /// [parent] The parent node
  /// [newNode] The node will be insert
  /// [closeCanInsert] Can insert when parent closed
  void insertAtFront(NodeData parent, NodeData newNode,
      {bool closeCanInsert = false}) {
    if (!closeCanInsert) {
      if (parent != null && !isExpanded(parent)) {
        return;
      }
    }
    parent.children.insert(0, newNode);
    _insertItemAtIndex(0, parent);
    notifyListeners();
  }

  /// Insert a node in the end
  /// [parent] The parent node
  /// [newNode] The node will be insert
  /// [closeCanInsert] Can insert when parent closed
  void insertAtRear(NodeData parent, NodeData newNode,
      {bool closeCanInsert = false}) {
    if (!closeCanInsert) {
      if (parent != null && !isExpanded(parent)) {
        return;
      }
    }
    parent.children.add(newNode);
    _insertItemAtIndex(0, parent, isFront: false);
    notifyListeners();
  }

  ///Inserts a node at position [index] in parent.
  /// The [index] value must be non-negative and no greater than [length].
  void insertAtIndex(int index, dynamic parent, NodeData newNode,
      {bool closeCanInsert = false}) {
    assert(index <= parent.children.length);
    if (!closeCanInsert) {
      if (parent != null && !isExpanded(parent)) {
        return;
      }
    }
    parent.children.insert(index, newNode);
    _insertItemAtIndex(index, parent, isIndex: true);

    notifyListeners();
  }

  ///
  void _insertItemAtIndex(int index, dynamic parent,
      {bool isIndex = false, bool isFront = true}) {
    int idx = indexOfItem(parent);
    if (idx == -1) {
      return;
    }
    NodeController parentController = _rootController.controllerOfItem(parent);
    if (isIndex) {
      var newControllers = createNodeController(parentController, [index]);
      parentController.insertNewChildControllers(newControllers[0], index);
    } else {
      if (isFront) {
        var newControllers = createNodeController(parentController, [0]);
        parentController.insertChildControllers(newControllers, [0]);
      } else {
        var newControllers = createNodeController(
            parentController, [parentController.childControllers.length]);
        parentController.addChildController(newControllers);
      }
    }
  }

  ///remove
  void removeItem(dynamic item) {
    dynamic temp = parentOfItem(item);
    NodeData parent = temp;
    int index = 0;
    if (parent == null) {
      index = data.indexOf(item);
      data.remove(item);
    } else {
      index = parent.children.indexOf(item);
      parent.children.remove(item);
    }

    removeItemAtIndexes(index, parent);

    notifyListeners();
  }

  ///
  void removeItemAtIndexes(int index, dynamic parent) {
    if (parent != null && !isExpanded(parent)) {
      return;
    }
    NodeController nodeController =
        _rootController.controllerOfItem(parent).childControllers[index];
    dynamic child = nodeController.treeNode.item;
    //删除的index
    int idx = _rootController.lastVisibleDescendantIndexForItem(child);
    if (idx == -1) {
      return;
    }
    NodeController parentController = _rootController.controllerOfItem(parent);
    parentController.removeChildControllers([index]);
  }

  /// Create controllers for each child node
  List<NodeController> createNodeController(
      NodeController parentController, List<int> indexes) {
    List<NodeController> children =
        parentController.childControllers.map((e) => e).toList();
    List<NodeController> newChildren = [];

    indexes.forEach((element) {});

    for (int i in indexes) {
      NodeController controller;
      NodeController oldController;
      var lazyItem = TreeNodeItem(
          parent: parentController.treeNode.item, controller: this, index: i);
      parentController.childControllers.forEach((controller) {
        if (controller.treeNode.item == lazyItem.item) {
          oldController = controller;
        }
      });
      if (oldController != null) {
        controller = oldController;
      } else {
        controller = NodeController(
            parent: parentController,
            nodeItem: lazyItem,
            expandCallback: (dynamic item) {
              bool result = false;
              children.forEach((item) {
                if (controller.treeNode.item == item) {
                  result = true;
                }
              });
              return result;
            });
      }
      newChildren.add(controller);
    }
    return newChildren;
  }

  NodeController createNewNodeController(
      NodeController parentController, int index) {
    var lazyItem = TreeNodeItem(
        parent: parentController.treeNode.item, controller: this, index: index);
    NodeController controller = NodeController(
        parent: parentController,
        nodeItem: lazyItem,
        expandCallback: (dynamic item) {
          bool result = false;
          return result;
        });
    return controller;
  }

  ///Gets the data information for the parent node
  dynamic parentOfItem(dynamic item) {
    NodeController controller = _rootController.controllerOfItem(item);
    return controller.parent.treeNode.item;
  }

  /// TreeNode by index
  TreeNode treeNodeOfIndex(int index) {
    return _rootController.controllerForIndex(index).treeNode;
  }

  /// The level of the specified item
  int levelOfNode(dynamic item) {
    var controller = _rootController.controllerOfItem(item);
    return controller.level;
  }

  /// The index of the specified item
  int indexOfItem(dynamic item) {
    return _rootController.indexOfItem(item);
  }
}
