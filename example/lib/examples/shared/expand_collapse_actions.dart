import 'package:flutter/material.dart';
import 'package:list_treeview/list_treeview.dart';

/// AppBar actions with "expand all" / "collapse all" buttons, shared by every
/// example so the behaviour stays consistent.
///
/// Note: [TreeViewController.expandAll] only expands nodes whose children are
/// already loaded. Lazily-loaded nodes that have not been loaded yet are
/// skipped.
List<Widget> expandCollapseActions(TreeViewController controller) {
  return <Widget>[
    IconButton(
      tooltip: 'Expand all',
      icon: const Icon(Icons.unfold_more),
      onPressed: () => controller.expandAll(),
    ),
    IconButton(
      tooltip: 'Collapse all',
      icon: const Icon(Icons.unfold_less),
      onPressed: () => controller.collapseAll(),
    ),
  ];
}
