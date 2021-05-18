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
import '../../list_treeview.dart';
import '../tree_define.dart';

class TreeNode<T> {
  TreeNode({this.lazyItem, this.expandCallback});

  bool _expanded = false;
  ExpandCallback? expandCallback;

  final TreeNodeItem? lazyItem;

  NodeData? get item {
    if (lazyItem != null) {
      return lazyItem!.item;
    }
    return null;
  }

  bool get expanded {
    if (expandCallback != null) {
      _expanded = expandCallback!(this.item);
    }
    return _expanded;
  }

  set setExpanded(bool expanded) {
    this.expandCallback = null;
    _expanded = expanded;
  }
}

class TreeNodeItem {
  TreeNodeItem({this.parent, this.index, this.controller});

  final dynamic parent;
  final int? index;
  final TreeViewController? controller;
  NodeData? _item;

  NodeData get item {
    if (_item == null) {
      _item = controller!.dataForTreeNode(this);
    }
    return _item!;
  }
}

///This class contains information about the nodes, such as Index and level, and whether to expand. It also contains other information
class NodeData {
  NodeData() : children = [];
  List<NodeData> children;
  bool isSelected = false;

  /// Index in all nodes
  int index = -1;

  /// Index in parent node
  int indexInParent = -1;
  int level = -1;
  bool isExpand = false;

  addChild(NodeData child) {
    children.add(child);
  }
}
