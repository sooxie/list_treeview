import 'package:flutter/material.dart';
import 'tree_node_data.dart';

/// A reusable row for a tree node: indentation + expand/leaf icon + label.
///
/// [node.level] and [node.isExpand] are populated by `ListTreeView` while
/// building each row, so this widget can render the correct indent and icon.
class TreeNodeTile extends StatelessWidget {
  const TreeNodeTile({
    Key? key,
    required this.node,
    this.trailing,
  }) : super(key: key);

  final TreeNodeData node;

  /// Optional widget shown at the end of the row (e.g. add / select button).
  final Widget? trailing;

  bool get _hasChildren =>
      node.children.isNotEmpty || (node.lazy && !node.loaded);

  @override
  Widget build(BuildContext context) {
    final IconData leadingIcon = _hasChildren
        ? (node.isExpand
            ? Icons.keyboard_arrow_down
            : Icons.keyboard_arrow_right)
        : Icons.insert_drive_file_outlined;

    return Container(
      height: 50,
      padding: EdgeInsets.only(left: 16 + node.level * 20.0, right: 8),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(width: 0.5, color: Colors.black12),
        ),
      ),
      child: Row(
        children: <Widget>[
          Icon(leadingIcon, size: 20, color: Colors.blueGrey),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              node.label ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 15),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
