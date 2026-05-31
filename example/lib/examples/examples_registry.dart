import 'package:flutter/material.dart';

import 'async_example.dart';
import 'basic_example.dart';
import 'insert_remove_example.dart';
import 'select_example.dart';

/// One entry in the home list of examples.
class ExampleEntry {
  const ExampleEntry({
    required this.title,
    required this.subtitle,
    required this.builder,
  });

  final String title;
  final String subtitle;
  final Widget Function(BuildContext context) builder;
}

/// Add a new example by appending an entry here.
final List<ExampleEntry> examplesRegistry = <ExampleEntry>[
  ExampleEntry(
    title: 'Basic & Expand All',
    subtitle: 'Basic tree with expand all / collapse all',
    builder: (_) => const BasicExample(),
  ),
  ExampleEntry(
    title: 'Insert & Remove',
    subtitle: 'Add and remove nodes',
    builder: (_) => const InsertRemoveExample(),
  ),
  ExampleEntry(
    title: 'Selection',
    subtitle: 'Select a node and all its children',
    builder: (_) => const SelectExample(),
  ),
  ExampleEntry(
    title: 'Async Lazy Load',
    subtitle: 'Load children asynchronously on expand',
    builder: (_) => const AsyncExample(),
  ),
];
