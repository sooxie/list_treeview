import 'package:flutter/material.dart';
import 'package:list_treeview/list_treeview.dart';

import 'shared/expand_collapse_actions.dart';
import 'shared/sample_data.dart';
import 'shared/tree_node_data.dart';
import 'shared/tree_node_tile.dart';

/// Demonstrates inserting and removing nodes.
///
/// - Tap the "+" button on a row to append a child node.
/// - Tap the delete button on a row to remove that node (and its subtree).
class InsertRemoveExample extends StatefulWidget {
  const InsertRemoveExample({Key? key}) : super(key: key);

  @override
  State<InsertRemoveExample> createState() => _InsertRemoveExampleState();
}

class _InsertRemoveExampleState extends State<InsertRemoveExample> {
  final TreeViewController _controller = TreeViewController();
  int _counter = 0;

  @override
  void initState() {
    super.initState();
    _controller.treeData(buildSampleData());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addChild(TreeNodeData parent) {
    final newNode = TreeNodeData(label: 'New node ${++_counter}');

    /// closeCanInsert lets us add a child even when the parent is collapsed.
    _controller.insertAtRear(parent, newNode, closeCanInsert: true);

    /// Make sure the new child is visible.
    if (!_controller.isExpanded(parent)) {
      final index = _controller.indexOfItem(parent);
      if (index != -1) {
        _controller.expandOrCollapse(index);
      }
    }
  }

  void _remove(TreeNodeData node) {
    _controller.removeItem(node);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Insert & Remove'),
        actions: expandCollapseActions(_controller),
      ),
      body: ListTreeView(
        controller: _controller,
        itemBuilder: (BuildContext context, NodeData data) {
          final node = data as TreeNodeData;
          return TreeNodeTile(
            node: node,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.add, size: 20),
                  tooltip: 'Add child',
                  onPressed: () => _addChild(node),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20),
                  tooltip: 'Remove node',
                  onPressed: () => _remove(node),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
