import 'package:flutter/material.dart';
import 'package:list_treeview/list_treeview.dart';

import 'shared/expand_collapse_actions.dart';
import 'shared/example_theme.dart';
import 'shared/sample_data.dart';
import 'shared/tree_node_data.dart';
import 'shared/tree_node_tile.dart';

/// Demonstrates inserting and removing nodes.
///
/// - Tap the "+" button on a row to append a child node.
/// - Tap the delete button on a row to remove that node (and its subtree).
/// - Use the toolbar to insert a new root node at the front, rear, or a
///   specific index (demonstrates passing null as parent).
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
    _controller.insertAtRear(parent, newNode, closeCanInsert: true);
    if (!_controller.isExpanded(parent)) {
      final index = _controller.indexOfItem(parent);
      if (index != -1) _controller.expandOrCollapse(index);
    }
  }

  void _remove(TreeNodeData node) {
    _controller.removeItem(node);
  }

  /// Insert a new root node at the front (parent = null).
  void _addRootFront() {
    _controller.insertAtFront(null, TreeNodeData(label: 'Root ${++_counter}'));
  }

  /// Append a new root node at the rear (parent = null).
  void _addRootRear() {
    _controller.insertAtRear(null, TreeNodeData(label: 'Root ${++_counter}'));
  }

  @override
  Widget build(BuildContext context) {
    return ExampleScaffold(
      title: 'Insert & Remove',
      subtitle:
          'Append child nodes from any row, insert root nodes, or remove a node with its subtree.',
      actions: [
        ...expandCollapseActions(_controller),
        IconButton(
          icon: const Icon(Icons.vertical_align_top),
          tooltip: 'Add root at front',
          onPressed: _addRootFront,
        ),
        IconButton(
          icon: const Icon(Icons.vertical_align_bottom),
          tooltip: 'Add root at rear',
          onPressed: _addRootRear,
        ),
      ],
      child: ListTreeView(
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
                  color: kExampleTeal,
                  onPressed: () => _addChild(node),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20),
                  tooltip: 'Remove node',
                  color: kExampleRose,
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
