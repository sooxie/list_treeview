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

  NodeController? _rootController;

  dynamic rootDataNode;
  List<dynamic>? data;

  void treeData(List? data) {
    assert(data != null, 'The data should not be empty');
    this.data = data;
    // notifyListeners();
  }

  /// Gets the data associated with each item
  dynamic dataForTreeNode(TreeNodeItem nodeItem) {
    NodeData? nodeData = nodeItem.parent;
    if (nodeData == null) {
      return data![nodeItem.index!];
    }
    return nodeData.children[nodeItem.index!];
  }

  void rebuild() {
    notifyListeners();
  }

  /// TreeNode by index
  TreeNode treeNodeOfIndex(int index) {
    return _rootController!.controllerForIndex(index)!.treeNode;
  }

  /// The level of the specified item
  int levelOfNode(dynamic item) {
    var controller = _rootController!.controllerOfItem(item);
    return controller!.level;
  }

  /// The index of the specified item
  int indexOfItem(dynamic item) {
    return _rootController!.indexOfItem(item);
  }

  /// Insert a node in the head
  /// [parent] The parent node
  /// [newNode] The node will be insert
  /// [closeCanInsert] Can insert when parent closed
  void insertAtFront(NodeData? parent, NodeData newNode,
      {bool closeCanInsert = false}) {
    if (!closeCanInsert) {
      if (parent != null && !isExpanded(parent)) {
        return;
      }
    }
    if (parent == null) {
      data!.insert(0, newNode);
      _insertRootControllerAt(0);
    } else {
      parent.children.insert(0, newNode);
      _insertItemAtIndex(0, parent);
    }
    notifyListeners();
  }

  /// Appends all nodes to the head of parent.
  /// [parent] The parent node
  /// [newNode] The node will be insert
  /// [closeCanInsert] Can insert when parent closed
  void insertAllAtFront(NodeData? parent, List<NodeData> newNodes,
      {bool closeCanInsert = false}) {
    if (!closeCanInsert) {
      if (parent != null && !isExpanded(parent)) {
        return;
      }
    }
    parent!.children.insertAll(0, newNodes);
    _insertAllItemAtIndex(0, parent, newNodes);
    notifyListeners();
  }

  /// Insert a node in the end
  /// [parent] The parent node
  /// [newNode] The node will be insert
  /// [closeCanInsert] Can insert when parent closed
  void insertAtRear(NodeData? parent, NodeData newNode,
      {bool closeCanInsert = false}) {
    if (!closeCanInsert) {
      if (parent != null && !isExpanded(parent)) {
        return;
      }
    }
    if (parent == null) {
      data!.add(newNode);
      _insertRootControllerAt(data!.length - 1);
    } else {
      parent.children.add(newNode);
      _insertItemAtIndex(0, parent, isFront: false);
    }
    notifyListeners();
  }

  ///Inserts a node at position [index] in parent.
  /// The [index] value must be non-negative and no greater than [length].
  void insertAtIndex(int index, dynamic parent, NodeData newNode,
      {bool closeCanInsert = false}) {
    if (parent == null) {
      assert(index <= data!.length);
      if (!closeCanInsert) {
        data!.insert(index, newNode);
        _insertRootControllerAt(index);
        notifyListeners();
      }
      return;
    }
    assert(index <= parent.children.length);
    if (!closeCanInsert) {
      if (!isExpanded(parent)) {
        return;
      }
    }
    parent.children.insert(index, newNode);
    _insertItemAtIndex(index, parent, isIndex: true);
    notifyListeners();
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

  /// Begin collapse
  void collapseItem(TreeNode treeNode) {
    /// - warning
    NodeController controller =
        _rootController!.controllerOfItem(treeNode.item)!;
    controller.collapseAndCollapseChildren(true);
  }

  /// Expand every node in the tree.
  ///
  /// Child controllers are created lazily when a parent expands, so the tree is
  /// walked top-down: only after a parent is expanded do its children get
  /// controllers. Nodes are located by identity ([NodeController.controllerOfItem])
  /// rather than by index, so we never read the per-node index cache while the
  /// tree is being mutated. The cache is reset once at the end so the next
  /// rebuild recomputes every index from a clean state.
  void expandAll() {
    void expand(List<NodeData> nodes) {
      for (final NodeData node in nodes) {
        if (node.children.isEmpty) continue;
        NodeController? controller = _rootController!.controllerOfItem(node);
        if (controller == null) continue;
        if (!controller.treeNode.expanded) {
          expandItem(controller.treeNode);
        }
        expand(node.children);
      }
    }

    expand(data!.cast<NodeData>());
    _resetAllCaches(_rootController!);
    notifyListeners();
  }

  /// Collapse every node in the tree.
  ///
  /// Collapsing a top-level node recursively collapses its descendants, see
  /// [NodeController.collapseAndCollapseChildren]. Nodes are located by identity
  /// and the index cache is reset once at the end (see [expandAll]).
  void collapseAll() {
    for (final NodeData node in data!.cast<NodeData>()) {
      NodeController? controller = _rootController!.controllerOfItem(node);
      if (controller != null && controller.treeNode.expanded) {
        collapseItem(controller.treeNode);
      }
    }
    _resetAllCaches(_rootController!);
    notifyListeners();
  }

  /// Recursively clears the index / visible-count caches on every controller so
  /// the next rebuild recomputes them from scratch.
  void _resetAllCaches(NodeController controller) {
    controller.resetData();
    for (final NodeController child in controller.childControllers) {
      _resetAllCaches(child);
    }
  }

  ///remove
  void removeItem(dynamic item) {
    dynamic temp = parentOfItem(item);
    NodeData? parent = temp;
    int index = 0;
    if (parent == null) {
      index = data!.indexOf(item);
      data!.remove(item);
    } else {
      index = parent.children.indexOf(item);
      parent.children.remove(item);
    }

    removeItemAtIndexes(index, parent);

    notifyListeners();
  }

  int itemChildrenLength(dynamic item) {
    if (item == null) {
      return data!.length;
    }
    NodeData nodeData = item;
    return nodeData.children.length;
  }

  ///select
  void selectItem(dynamic item) {
    assert(item != null, 'Item should not be null');
    NodeData sItem = item;
    sItem.isSelected = !sItem.isSelected;
    notifyListeners();
  }

  void selectAllChild(dynamic item) {
    assert(item != null, 'Item should not be null');
    NodeData sItem = item;
    sItem.isSelected = !sItem.isSelected;
    if (sItem.children.isNotEmpty) {
      _selectAllChild(sItem);
    }
    notifyListeners();
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
      int num = data!.length;

      List<int> indexes = [];
      for (int i = 0; i < num; i++) {
        indexes.add(i);
      }
      var controllers = createNodeController(_rootController!, indexes);
      _rootController!.insertChildControllers(controllers, indexes);
    }
    return _rootController!;
  }

  bool isExpanded(dynamic item) {
    int index = indexOfItem(item);
    return treeNodeOfIndex(index).expanded;
  }

  /// Begin expand
  void expandItem(TreeNode treeNode) {
    List items = [treeNode.item];
    while (items.isNotEmpty) {
      var currentItem = items.first;
      items.remove(currentItem);
      NodeController controller =
          _rootController!.controllerOfItem(currentItem)!;
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
      controller.expandAndExpandChildren(false);
      notifyListeners();
    }
  }

  /// Inserts a new root-level controller at [index] in the root controller's
  /// child list, mirroring a direct insertion into [data].
  void _insertRootControllerAt(int index) {
    var newControllers = createNodeController(rootController, [index]);
    rootController.insertChildControllers(newControllers, [index]);
  }

  void _insertItemAtIndex(int index, dynamic parent,
      {bool isIndex = false, bool isFront = true}) {
    int idx = indexOfItem(parent);
    if (idx == -1) {
      return;
    }
    NodeController parentController =
        _rootController!.controllerOfItem(parent)!;
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

  void _insertAllItemAtIndex(int index, dynamic parent, List<NodeData> newNodes,
      {bool isIndex = false, bool isFront = true}) {
    int idx = indexOfItem(parent);
    if (idx == -1) {
      return;
    }
    NodeController parentController =
        _rootController!.controllerOfItem(parent)!;
    if (isIndex) {
      var newControllers = createNodeController(parentController, [index]);
      parentController.insertNewChildControllers(newControllers[0], index);
    } else {
      if (isFront) {
        List<int> nodes = [];
        for (int i = 0; i < newNodes.length; i++) {
          nodes.add(i);
        }
        var newControllers = createNodeController(parentController, nodes);
        parentController.insertChildControllers(newControllers, nodes);
      } else {
        var newControllers = createNodeController(
            parentController, [parentController.childControllers.length]);
        parentController.addChildController(newControllers);
      }
    }
  }

  ///
  void removeItemAtIndexes(int index, dynamic parent) {
    if (parent != null && !isExpanded(parent)) {
      return;
    }
    NodeController nodeController =
        _rootController!.controllerOfItem(parent)!.childControllers[index];
    dynamic child = nodeController.treeNode.item;
    int idx = _rootController!.lastVisibleDescendantIndexForItem(child);
    if (idx == -1) {
      return;
    }
    NodeController parentController =
        _rootController!.controllerOfItem(parent)!;
    parentController.removeChildControllers([index]);
  }

  void _selectAllChild(NodeData sItem) {
    if (sItem.children.isEmpty) return;
    for (NodeData child in sItem.children) {
      child.isSelected = sItem.isSelected;
      _selectAllChild(child);
    }
  }

  /// Create controllers for each child node
  List<NodeController> createNodeController(
      NodeController parentController, List<int> indexes) {
    List<NodeController> children =
        parentController.childControllers.map((e) => e).toList();
    List<NodeController> newChildren = [];

    indexes.forEach((element) {});

    for (int i in indexes) {
      NodeController? controller;
      NodeController? oldController;
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
            expandCallback: (NodeData? item) {
              bool result = false;
              children.forEach((controller) {
                if (controller.treeNode.item == item) {
                  result = true;
                }
              });
              return result;
            });
      }
      newChildren.add(controller!);
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

  /// Moves [item] to become a child of [newParent] at [index].
  ///
  /// - [newParent] == null moves [item] to the root level.
  /// - [index] is the position in the target child list *after* [item] has
  ///   been removed; null appends to the end. The value is clamped to
  ///   `[0, length]`.
  /// - Returns false without changing anything when the move is invalid:
  ///   [newParent] is [item] itself, a descendant of [item] (would create
  ///   a cycle), or either [item] or [newParent] is not in the tree.
  bool moveItem(NodeData item, NodeData? newParent, {int? index}) {
    if (identical(newParent, item)) {
      return false;
    }
    if (newParent != null && _contains(item, newParent)) {
      return false;
    }
    if (_ancestorChain(item) == null) {
      return false;
    }
    if (newParent != null && _ancestorChain(newParent) == null) {
      return false;
    }

    final List<NodeData> expandedNodes = _expandedInSubtree(item);

    _removeFromTree(item);

    if (newParent != null) {
      _ensureExpandedToParent(newParent);
    }

    final List finalList = newParent == null ? data! : newParent.children;
    int target = index ?? finalList.length;
    if (target < 0) target = 0;
    if (target > finalList.length) target = finalList.length;

    insertAtIndex(target, newParent, item);

    for (final NodeData n in expandedNodes) {
      final NodeController? controller = _rootController?.controllerOfItem(n);
      if (controller != null && !controller.treeNode.expanded) {
        expandItem(controller.treeNode);
      }
    }

    return true;
  }

  /// Removes [item] from the data tree. Items whose parent has never been
  /// expanded have no [NodeController]; [removeItem] would misclassify them as
  /// root nodes and crash, so they get a data-only removal here.
  void _removeFromTree(NodeData item) {
    if (rootController.controllerOfItem(item) != null) {
      removeItem(item);
      return;
    }
    final List<NodeData> chain = _ancestorChain(item)!;
    final NodeData? parent = chain.length > 1 ? chain[chain.length - 2] : null;
    if (parent == null) {
      data!.remove(item);
    } else {
      parent.children.remove(item);
    }
    notifyListeners();
  }

  /// True when [target] is a descendant of [root] in the data tree.
  bool _contains(NodeData root, NodeData target) {
    for (final NodeData child in root.children) {
      if (identical(child, target)) {
        return true;
      }
      if (_contains(child, target)) {
        return true;
      }
    }
    return false;
  }

  /// Pre-order list of nodes in [root]'s subtree (including [root]) that are
  /// currently expanded.
  List<NodeData> _expandedInSubtree(NodeData root) {
    final List<NodeData> result = [];
    void walk(NodeData n) {
      final NodeController? controller = _rootController?.controllerOfItem(n);
      if (controller != null && controller.treeNode.expanded) {
        result.add(n);
      }
      for (final NodeData child in n.children) {
        walk(child);
      }
    }

    walk(root);
    return result;
  }

  /// Returns the data-tree path from a root down to [target] (inclusive),
  /// or null when [target] is not present.
  List<NodeData>? _ancestorChain(NodeData target) {
    final List<NodeData> path = [];
    bool dfs(List nodes) {
      for (final NodeData n in nodes.cast<NodeData>()) {
        path.add(n);
        if (identical(n, target)) {
          return true;
        }
        if (dfs(n.children)) {
          return true;
        }
        path.removeLast();
      }
      return false;
    }

    return dfs(data!) ? List<NodeData>.of(path) : null;
  }

  /// Expands [parent] and every collapsed ancestor above it, top-down, so a
  /// child can be inserted into [parent] and rendered.
  void _ensureExpandedToParent(NodeData parent) {
    final List<NodeData>? chain = _ancestorChain(parent);
    if (chain == null) {
      return;
    }
    for (final NodeData node in chain) {
      final NodeController? controller =
          _rootController?.controllerOfItem(node);
      if (controller == null) {
        continue;
      }
      if (!controller.treeNode.expanded) {
        expandItem(controller.treeNode);
      }
    }
  }

  ///Gets the data information for the parent node
  NodeData? parentOfItem(dynamic item) {
    NodeController? controller = rootController.controllerOfItem(item);
    return controller?.parent?.treeNode.item;
  }
}
