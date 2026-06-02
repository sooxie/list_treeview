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

  /// Labels of the nodes selected the last time the print button was tapped.
  List<String> _printedNodes = <String>[];

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

  /// Walks the whole tree and returns every node whose checkbox is selected.
  List<TreeNodeData> _collectSelectedNodes() {
    final List<TreeNodeData> selected = <TreeNodeData>[];

    void visit(List<NodeData> nodes) {
      for (final NodeData node in nodes) {
        if (node.isSelected) {
          selected.add(node as TreeNodeData);
        }
        visit(node.children);
      }
    }

    visit((_controller.data ?? const <NodeData>[]).cast<NodeData>());
    return selected;
  }

  /// Collects the selected nodes, prints them to the console and shows their
  /// labels in the panel at the bottom of the page.
  void _printSelectedNodes() {
    final List<TreeNodeData> selected = _collectSelectedNodes();
    final List<String> labels =
        selected.map((node) => node.label ?? '(unnamed)').toList();

    debugPrint('Selected nodes (${labels.length}): ${labels.join(', ')}');

    setState(() {
      _printedNodes = labels;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ExampleScaffold(
      title: 'Selection',
      subtitle:
          'Toggle a branch checkbox to select a node and all of its descendants.',
      actions: expandCollapseActions(_controller),
      child: Column(
        children: <Widget>[
          Expanded(
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
          ),
          _SelectedNodesPanel(
            nodes: _printedNodes,
            onPrint: _printSelectedNodes,
          ),
        ],
      ),
    );
  }
}

/// Bottom panel with a button that prints the selected nodes and lists them.
class _SelectedNodesPanel extends StatelessWidget {
  const _SelectedNodesPanel({
    Key? key,
    required this.nodes,
    required this.onPrint,
  }) : super(key: key);

  final List<String> nodes;
  final VoidCallback onPrint;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: kExampleSurface,
        border: Border(top: BorderSide(color: kExampleLine)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Align(
            alignment: Alignment.centerLeft,
            child: ElevatedButton.icon(
              onPressed: onPrint,
              icon: const Icon(Icons.print, size: 18),
              label: const Text('Print selected nodes'),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            nodes.isEmpty
                ? 'No selected nodes printed yet.'
                : 'Selected (${nodes.length}): ${nodes.join(', ')}',
            style: textTheme.bodyMedium?.copyWith(
              color: nodes.isEmpty ? kExampleMuted : kExampleInk,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}
