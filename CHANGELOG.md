## 0.5.0

- Added `TreeViewController.moveItem(item, newParent, {index})` to move a node
  between parents, reorder siblings, or move to the root level. The moved
  subtree's expand/collapse state is preserved, and a collapsed target parent is
  expanded automatically. Invalid moves (onto self or a descendant) are rejected
  and return `false`.
- Added a "Drag & Drop" example demonstrating `moveItem` with Flutter's
  `LongPressDraggable` / `DragTarget`.

# 0.4.2

- Fix `parentOfItem()` throwing a null-check exception after replacing the controller's tree data.

# 0.4.1

- Fix `RangeError` when expanding a node after appending a child to it while it was collapsed (`insertChildControllers` indexed the controller list with the insertion position instead of the controller's own position)

# 0.4.0

- Flutter 3.0+ / Dart 3 support
- Remove unused `dart:io` import so the package works on Flutter Web
- Clean up analyzer warnings (unused variable, dead code)
- Migrate example to `ElevatedButton` (`RaisedButton` was removed in Flutter 3.0)

# 0.3.0

- flutter 2.0 null safety support
- Fix some bugs


# 0.2.4

- Fix some bug

# 0.2.3

- Add the selected method

# 0.2.2

- Added a way to disable implicit node toggling

# 0.2.0

- The controller must be initialized when the treeView create
- Add asynchronous setup data
- Fix bug

# 0.1.4

- Optimize code format

# 0.1.2

- Adjust the example

# 0.1.1

- Modify the document

# 0.1.0

- Add the project

## 0.0.1

- Initialize the project
