import 'package:flutter/material.dart';
import 'package:list_treeview/list_treeview.dart';

import 'shared/example_theme.dart';
import 'shared/expand_collapse_actions.dart';
import 'shared/sample_data.dart';
import 'shared/tree_node_data.dart';
import 'shared/tree_node_tile.dart';

/// Demonstrates drag-and-drop node moving built on `controller.moveItem`.
///
/// The library only provides the `moveItem` data API — the drag gestures here
/// are plain Flutter `LongPressDraggable` + `DragTarget` widgets in the app
/// layer.
///
/// - Long-press a row and drag it onto another row to move it *into* that node
///   (it becomes the last child).
/// - Dropping a node onto itself or one of its descendants is rejected.
class DragExample extends StatefulWidget {
  const DragExample({Key? key}) : super(key: key);

  @override
  State<DragExample> createState() => _DragExampleState();
}

class _DragExampleState extends State<DragExample> {
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

  void _onDropInto(TreeNodeData target, TreeNodeData dragged) {
    final moved = _controller.moveItem(dragged, target);
    if (!moved) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot move a node into itself or its descendant'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ExampleScaffold(
      title: 'Drag & Drop',
      subtitle:
          'Long-press a row and drag it onto another node to move it there.',
      actions: expandCollapseActions(_controller),
      child: ListTreeView(
        controller: _controller,
        itemBuilder: (BuildContext context, NodeData data) {
          final node = data as TreeNodeData;
          return DragTarget<TreeNodeData>(
            onWillAcceptWithDetails: (details) => details.data != node,
            onAcceptWithDetails: (details) => _onDropInto(node, details.data),
            builder: (context, candidate, rejected) {
              final highlighted = candidate.isNotEmpty;
              return LongPressDraggable<TreeNodeData>(
                data: node,
                feedback: _DragFeedback(label: node.label ?? ''),
                childWhenDragging: Opacity(
                  opacity: 0.4,
                  child: TreeNodeTile(node: node),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: highlighted
                        ? exampleOpacity(kExampleTeal, 0.12)
                        : null,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TreeNodeTile(node: node),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _DragFeedback extends StatelessWidget {
  const _DragFeedback({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: kExamplePrimary,
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 2)),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.drag_indicator, color: Colors.white, size: 18),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
