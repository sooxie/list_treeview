import 'package:flutter/material.dart';
import 'package:list_treeview/list_treeview.dart';

import 'shared/expand_collapse_actions.dart';
import 'shared/example_theme.dart';
import 'shared/sample_data.dart';
import 'shared/tree_node_data.dart';
import 'shared/tree_node_tile.dart';

/// Demonstrates selection.
///
/// - Tap the checkbox to toggle the node and all of its descendants
///   ([TreeViewController.selectAllChild]).
/// - Tap the row body to expand / collapse as usual.
class SelectExample extends StatefulWidget {
  const SelectExample({Key? key}) : super(key: key);

  @override
  State<SelectExample> createState() => _SelectExampleState();
}

class _SelectExampleState extends State<SelectExample> {
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

  @override
  Widget build(BuildContext context) {
    return ExampleScaffold(
      title: 'Selection',
      subtitle:
          'Toggle a branch checkbox to select a node and all of its descendants.',
      actions: expandCollapseActions(_controller),
      child: ListTreeView(
        controller: _controller,
        itemBuilder: (BuildContext context, NodeData data) {
          final node = data as TreeNodeData;
          return TreeNodeTile(
            node: node,
            trailing: IconButton(
              icon: Icon(
                node.isSelected
                    ? Icons.check_box
                    : Icons.check_box_outline_blank,
                size: 22,
                color: node.isSelected ? kExamplePrimary : kExampleMuted,
              ),
              tooltip: 'Select node and children',
              onPressed: () => _controller.selectAllChild(node),
            ),
          );
        },
      ),
    );
  }
}
