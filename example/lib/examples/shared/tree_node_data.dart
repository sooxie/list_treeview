import 'package:flutter/material.dart';
import 'package:list_treeview/list_treeview.dart';

/// The data class bound to each tree node.
///
/// You must extend [NodeData]. Add whatever properties your UI needs.
class TreeNodeData extends NodeData {
  TreeNodeData({this.label, this.color, this.lazy = false}) : super();

  /// Text shown for the node.
  final String? label;

  /// Optional accent color.
  final Color? color;

  /// Whether this node loads its children asynchronously on first expand.
  final bool lazy;

  /// Async state, only used by the lazy-loading example.
  bool loading = false;
  bool loaded = false;
}
