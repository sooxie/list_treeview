import 'package:flutter_test/flutter_test.dart';
import 'package:list_treeview/list_treeview.dart';

class _Node extends NodeData {
  _Node(this.label);
  final String label;
  @override
  String toString() => 'Node($label)';
}

_Node node(String label, [List<_Node> children = const []]) {
  final n = _Node(label);
  for (final c in children) {
    n.addChild(c);
  }
  return n;
}

List<String> childLabels(NodeData parent) =>
    parent.children.map((e) => (e as _Node).label).toList();

List<String> visibleLabels(TreeViewController c) {
  final count = c.numberOfVisibleChild();
  return [
    for (int i = 0; i < count; i++) (c.treeNodeOfIndex(i).item as _Node).label,
  ];
}

void main() {
  group('moveItem: validation & basic moves', () {
    test('cross-parent move places node under the new parent', () {
      final work = node('Work', [node('a'), node('b')]);
      final personal = node('Personal', [node('c')]);
      final data = [
        node('Documents', [work, personal])
      ];
      final c = TreeViewController();
      c.treeData(data);
      c.numberOfVisibleChild(); // force root controller build
      c.expandAll();

      final a = work.children.first as _Node;
      final ok = c.moveItem(a, personal);

      expect(ok, isTrue);
      expect(childLabels(work), ['b']);
      expect(childLabels(personal), ['c', 'a']);
    });

    test('move to root level when newParent is null', () {
      final work = node('Work', [node('a')]);
      final data = [
        node('Documents', [work])
      ];
      final c = TreeViewController();
      c.treeData(data);
      c.numberOfVisibleChild();
      c.expandAll();

      final a = work.children.first as _Node;
      final ok = c.moveItem(a, null);

      expect(ok, isTrue);
      expect(work.children, isEmpty);
      expect(data.map((e) => e.label).toList(), ['Documents', 'a']);
    });

    test('reorder within same parent uses post-removal index', () {
      final root = node('root', [node('a'), node('b'), node('c')]);
      final data = [root];
      final c = TreeViewController();
      c.treeData(data);
      c.numberOfVisibleChild();
      c.expandAll();

      final a = root.children.first as _Node;
      c.moveItem(a, root, index: 2);

      expect(childLabels(root), ['b', 'c', 'a']);
    });

    test('null index appends to the end', () {
      final root = node('root', [node('a'), node('b')]);
      final data = [root];
      final c = TreeViewController();
      c.treeData(data);
      c.numberOfVisibleChild();
      c.expandAll();

      final a = root.children.first as _Node;
      c.moveItem(a, root);

      expect(childLabels(root), ['b', 'a']);
    });

    test('index past the end is clamped', () {
      final root = node('root', [node('a'), node('b')]);
      final data = [root];
      final c = TreeViewController();
      c.treeData(data);
      c.numberOfVisibleChild();
      c.expandAll();

      final a = root.children.first as _Node;
      c.moveItem(a, root, index: 99);

      expect(childLabels(root), ['b', 'a']);
    });

    test('rejects moving a node onto itself', () {
      final a = node('a');
      final data = [
        node('root', [a])
      ];
      final c = TreeViewController();
      c.treeData(data);
      c.numberOfVisibleChild();
      c.expandAll();

      expect(c.moveItem(a, a), isFalse);
      expect(childLabels(data.first), ['a']);
    });

    test('rejects moving a node into its own descendant', () {
      final child = node('child');
      final parent = node('parent', [child]);
      final data = [
        node('root', [parent])
      ];
      final c = TreeViewController();
      c.treeData(data);
      c.numberOfVisibleChild();
      c.expandAll();

      expect(c.moveItem(parent, child), isFalse);
      expect(childLabels(parent), ['child']);
    });

    test('rejects a target parent that is not in the tree', () {
      final a = node('a');
      final root = node('root', [a]);
      final data = [root];
      final c = TreeViewController();
      c.treeData(data);
      c.numberOfVisibleChild();
      c.expandAll();

      final orphan = node('orphan'); // never added to the tree
      final ok = c.moveItem(a, orphan);

      expect(ok, isFalse);
      // The node must not be removed from the tree.
      expect(childLabels(root), ['a']);
      expect(orphan.children, isEmpty);
    });

    test('rejects an item that is not in the tree', () {
      final root = node('root', [node('a')]);
      final data = [root];
      final c = TreeViewController();
      c.treeData(data);
      c.numberOfVisibleChild();
      c.expandAll();

      final orphan = node('orphan');
      expect(c.moveItem(orphan, root), isFalse);
      expect(childLabels(root), ['a']);
    });

    test('moves an item whose parent has never been expanded', () {
      final grandchild = node('gc');
      final child = node('child', [grandchild]);
      final root = node('root', [child]);
      final dest = node('dest');
      final data = [root, dest];
      final c = TreeViewController();
      c.treeData(data);
      // Build root controllers only; root is never expanded, so `grandchild`
      // has no NodeController.
      c.numberOfVisibleChild();

      final ok = c.moveItem(grandchild, dest);

      expect(ok, isTrue);
      expect(child.children, isEmpty);
      expect(childLabels(dest), ['gc']);
      expect(visibleLabels(c), containsAllInOrder(['root', 'dest', 'gc']));
    });
  });

  group('moveItem: auto-expand collapsed target', () {
    test('expands a collapsed target parent so the node becomes visible', () {
      final src = node('src', [node('a')]);
      final dest = node('dest', [node('x'), node('y')]);
      final data = [
        node('root', [src, dest])
      ];
      final c = TreeViewController();
      c.treeData(data);
      c.numberOfVisibleChild();
      c.expandAll();
      c.collapseItem(c.treeNodeOfIndex(c.indexOfItem(dest))); // collapse dest

      final a = src.children.first as _Node;
      final ok = c.moveItem(a, dest);

      expect(ok, isTrue);
      expect(childLabels(dest), ['x', 'y', 'a']);
      // dest is now expanded and 'a' is visible in the flattened list.
      expect(visibleLabels(c), contains('a'));
    });

    test('expands a collapsed ancestor chain of the target parent', () {
      final deep = node('deep', [node('x')]);
      final mid = node('mid', [deep]);
      final src = node('src', [node('a')]);
      final data = [
        node('root', [src, mid])
      ];
      final c = TreeViewController();
      c.treeData(data);
      c.numberOfVisibleChild();
      c.expandAll();
      // Collapse mid; deep is now hidden and has no live controller path.
      c.collapseItem(c.treeNodeOfIndex(c.indexOfItem(mid)));

      final a = src.children.first as _Node;
      final ok = c.moveItem(a, deep);

      expect(ok, isTrue);
      expect(childLabels(deep), ['x', 'a']);
      expect(visibleLabels(c), contains('a'));
    });
  });

  group('moveItem: preserve subtree expansion', () {
    test('moved expanded subtree stays expanded under the new parent', () {
      final leaf = node('leaf');
      final mid = node('mid', [leaf]);
      final src = node('src', [mid]);
      final dest = node('dest'); // initially childless -> collapsed
      final data = [
        node('root', [src, dest])
      ];
      final c = TreeViewController();
      c.treeData(data);
      c.numberOfVisibleChild();
      c.expandAll(); // src and mid are expanded; dest has no children

      c.moveItem(mid, dest);

      final labels = visibleLabels(c);
      expect(childLabels(dest), ['mid']);
      // mid stays expanded after the move, so leaf is visible.
      expect(labels, contains('mid'));
      expect(labels, contains('leaf'));
    });

    test('moved collapsed subtree stays collapsed', () {
      final leaf = node('leaf');
      final mid = node('mid', [leaf]);
      final src = node('src', [mid]);
      final dest = node('dest');
      final data = [
        node('root', [src, dest])
      ];
      final c = TreeViewController();
      c.treeData(data);
      c.numberOfVisibleChild();
      c.expandAll();
      // Collapse mid before moving it.
      c.collapseItem(c.treeNodeOfIndex(c.indexOfItem(mid)));

      c.moveItem(mid, dest);

      final labels = visibleLabels(c);
      expect(labels, contains('mid'));
      expect(labels, isNot(contains('leaf')));
    });
  });
}
