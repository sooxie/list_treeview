import 'package:flutter/material.dart';

import 'example_theme.dart';
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

  IconData get _fileIcon {
    final label = (node.label ?? '').toLowerCase();
    if (label.endsWith('.pdf')) return Icons.picture_as_pdf_outlined;
    if (label.endsWith('.xlsx')) return Icons.table_chart_outlined;
    if (label.endsWith('.docx')) return Icons.description_outlined;
    if (label.endsWith('.txt')) return Icons.notes_outlined;
    if (label.endsWith('.png')) return Icons.image_outlined;
    if (label.endsWith('.mp3')) return Icons.music_note_outlined;
    return Icons.insert_drive_file_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final Color accent = node.color ?? _levelAccent(node.level);
    final Color background = node.isSelected
        ? exampleOpacity(accent, 0.1)
        : node.level == 0
            ? const Color(0xFFFBFCFE)
            : Colors.white;
    final IconData expandIcon = node.isExpand
        ? Icons.keyboard_arrow_down_rounded
        : Icons.keyboard_arrow_right_rounded;
    final IconData leadingIcon =
        _hasChildren ? Icons.folder_outlined : _fileIcon;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Container(
        height: 52,
        padding: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color:
                node.isSelected ? exampleOpacity(accent, 0.34) : kExampleLine,
          ),
        ),
        child: Row(
          children: <Widget>[
            _LevelGuide(level: node.level, color: accent),
            SizedBox(
              width: 30,
              height: 30,
              child: _hasChildren
                  ? Icon(expandIcon, size: 22, color: kExampleMuted)
                  : const SizedBox.shrink(),
            ),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: exampleOpacity(accent, _hasChildren ? 0.12 : 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(leadingIcon, size: 18, color: accent),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    node.label ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: kExampleInk,
                      fontSize: 14.5,
                      fontWeight:
                          _hasChildren ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                  if (_hasChildren || node.lazy)
                    Text(
                      node.lazy && !node.loaded
                          ? 'Tap to load children'
                          : node.isExpand
                              ? 'Expanded'
                              : 'Collapsed',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: kExampleMuted,
                        fontSize: 11,
                        height: 1.1,
                      ),
                    ),
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }

  Color _levelAccent(int level) {
    const colors = <Color>[
      kExamplePrimary,
      kExampleTeal,
      kExampleAmber,
      kExampleRose,
    ];
    return colors[level % colors.length];
  }
}

class _LevelGuide extends StatelessWidget {
  const _LevelGuide({required this.level, required this.color});

  final int level;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 14 + level * 20.0,
      height: double.infinity,
      child: Align(
        alignment: Alignment.centerRight,
        child: level == 0
            ? Container(width: 3, height: 28, color: color)
            : Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: List<Widget>.generate(
                  level,
                  (index) => Container(
                    width: index == level - 1 ? 12 : 20,
                    alignment: Alignment.centerRight,
                    child: Container(
                      width: 1,
                      height: 34,
                      color: index == level - 1
                          ? exampleOpacity(color, 0.38)
                          : kExampleLine,
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
