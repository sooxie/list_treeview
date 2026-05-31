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

  @override
  Widget build(BuildContext context) {
    return ExampleScaffold(
      title: 'Basic & Expand All',
      subtitle:
          'Browse a nested file tree and use the toolbar actions to expand or collapse every loaded branch.',
      actions: expandCollapseActions(_controller),
      child: ListTreeView(
        controller: _controller,
        itemBuilder: (BuildContext context, NodeData data) {
          return TreeNodeTile(node: data as TreeNodeData);
        },
      ),
    );
  }
}
