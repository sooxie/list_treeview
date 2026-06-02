import 'package:flutter/material.dart';
import 'package:list_treeview/list_treeview.dart';

import 'shared/expand_collapse_actions.dart';
import 'shared/example_theme.dart';
import 'shared/sample_data.dart';
import 'shared/tree_node_data.dart';
import 'shared/tree_node_tile.dart';

/// Basic tree display plus "expand all" / "collapse all".
class BasicExample extends StatefulWidget {
  const BasicExample({Key? key}) : super(key: key);

  @override
  State<BasicExample> createState() => _BasicExampleState();
}

class _BasicExampleState extends State<BasicExample> {
  final TreeViewController _controller = TreeViewController();

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

  /// A node is a leaf when it has no children and is not a lazy branch.
  bool _isLeaf(TreeNodeData node) => node.children.isEmpty && !node.lazy;

  /// Builds the full information of a tapped leaf node and shows it in a dialog.
  void _onTap(NodeData data) {
    final node = data as TreeNodeData;
    if (!_isLeaf(node)) return;

    final info = 'label:         ${node.label}\n'
        'level:         ${node.level}\n'
        'index:         ${node.index}\n'
        'indexInParent: ${node.indexInParent}\n'
        'isExpand:      ${node.isExpand}\n'
        'isSelected:    ${node.isSelected}\n'
        'lazy:          ${node.lazy}\n'
        'color:         ${node.color}\n'
        'children:      ${node.children.length}';

    debugPrint('Leaf node tapped:\n$info');

    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(node.label ?? 'Node info'),
          content: Text(
            info,
            style: const TextStyle(
              fontSize: 13,
              height: 1.4,
              fontFamily: 'monospace',
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ExampleScaffold(
      title: 'Basic & Expand All',
      subtitle:
          'Browse a nested file tree and use the toolbar actions to expand or collapse every loaded branch.',
      actions: expandCollapseActions(_controller),
      child: ListTreeView(
        controller: _controller,
        onTap: _onTap,
        itemBuilder: (BuildContext context, NodeData data) {
          return TreeNodeTile(node: data as TreeNodeData);
        },
      ),
    );
  }
}
