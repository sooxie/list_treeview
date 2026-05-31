# AGENTS.md

Guidance for AI coding agents working in this repo.

## Project

`list_treeview` — a Flutter **package** (pub.dev) providing a `ListTreeView`
widget: an infinitely-nestable tree view built on `ListView`. It manages only the
tree data structure; each row's UI is supplied by the caller. Dart `^3.0.0`,
Flutter `3.0+`, null-safe.

## Commands

```bash
flutter pub get            # install deps (run in root and in example/)
flutter analyze            # static analysis — keep it warning-free
dart format .              # format before committing
flutter test               # run tests (currently a stub)
cd example && flutter run  # run the demo app
```

## Layout

```
lib/
  list_treeview.dart            # public API barrel (exports the 3 files below)
  tree/
    tree_view.dart              # ListTreeView widget (renders via ListView.builder)
    node/tree_node.dart         # NodeData (extend this), TreeNode, TreeNodeItem (lazy)
    controller/
      tree_controller.dart      # TreeViewController — the main public API
      node_controller.dart      # NodeController — internal index/visibility bookkeeping
    tree_define.dart            # typedefs: IndexedBuilder, PressCallback, ExpandCallback
example/                        # runnable demo
test/listtreeview_test.dart     # test stub
```

Public exports: `tree_view.dart`, `tree_controller.dart`, `tree_node.dart`.
`NodeController` and `tree_define.dart` are internal.

## Architecture

Two parallel trees kept in sync:

- **Data tree** — user `NodeData` subclasses linked via `children`; source of truth
  for content.
- **Controller tree** — `NodeController` mirrors the data tree and computes each
  node's flat `ListView` index, level, and visible-descendant count. Expand/collapse
  mutates this tree.

`TreeViewController extends ChangeNotifier`. Mutations (`treeData`, `insert*`,
`removeItem`, `expandOrCollapse`, `select*`) call `notifyListeners()`; the widget
listens and rebuilds via `ListView.builder`. `TreeNodeItem` resolves its `NodeData`
lazily, so only visible rows are realized.

Typical flow: subclass `NodeData` → build tree with `addChild` →
`controller.treeData([roots])` → pass `controller` + `itemBuilder` to `ListTreeView`.

## Conventions

- Every source file starts with the MIT license header (`Copyright (c) 2020 sooxie`) —
  preserve it on new files.
- Doc comments use `///`; comments and identifiers are in English.
- Keep the UI caller-driven — don't bake styling into the widget.
- For any released change, bump `version` in `pubspec.yaml` and add a `CHANGELOG.md` entry.
