import 'package:flutter/material.dart';
import 'package:list_treeview/list_treeview.dart';

import 'shared/expand_collapse_actions.dart';
import 'shared/example_theme.dart';
import 'shared/sample_data.dart';
import 'shared/tree_node_data.dart';
import 'shared/tree_node_tile.dart';

/// Demonstrates lazy loading: a node's children are fetched the first time it
/// is expanded.
///
/// `toggleNodeOnTap` is disabled so we can intercept the tap, fetch the data,
/// insert the children and only then expand the node.
class AsyncExample extends StatefulWidget {
  const AsyncExample({Key? key}) : super(key: key);

  @override
  State<AsyncExample> createState() => _AsyncExampleState();
}

class _AsyncExampleState extends State<AsyncExample> {
  final TreeViewController _controller = TreeViewController();

  @override
  void initState() {
    super.initState();
    _controller.treeData(buildLazyRoots());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onTap(TreeNodeData node) async {
    /// Leaf nodes do nothing.
    if (!node.lazy && node.children.isEmpty) return;

    final index = _controller.indexOfItem(node);
    if (index == -1) return;

    /// Already loaded (or a normal parent): just toggle expand/collapse.
    if (!node.lazy || node.loaded) {
      _controller.expandOrCollapse(index);
      return;
    }

    /// First expand of a lazy node: fetch children, then insert + expand.
    node.loading = true;
    _controller.rebuild();

    await Future<void>.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    node.loading = false;
    node.loaded = true;
    _controller.insertAllAtFront(
      node,
      buildLazyChildren(node),
      closeCanInsert: true,
    );

    if (!_controller.isExpanded(node)) {
      final newIndex = _controller.indexOfItem(node);
      if (newIndex != -1) {
        _controller.expandOrCollapse(newIndex);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ExampleScaffold(
      title: 'Async Lazy Load',
      subtitle:
          'Lazy branches fetch children on first tap, then behave like normal expanded tree nodes.',

      /// expandAll only expands lazy nodes that have already been loaded;
      /// un-loaded lazy nodes are skipped.
      actions: expandCollapseActions(_controller),
      child: ListTreeView(
        controller: _controller,
        toggleNodeOnTap: false,
        onTap: (NodeData data) => _onTap(data as TreeNodeData),
        itemBuilder: (BuildContext context, NodeData data) {
          final node = data as TreeNodeData;
          return TreeNodeTile(
            node: node,
            trailing: node.loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: kExamplePrimary,
                    ),
                  )
                : null,
          );
        },
      ),
    );
  }
}
