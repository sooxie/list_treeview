import 'package:flutter_test/flutter_test.dart';
import 'package:list_treeview/list_treeview.dart';

class _Node extends NodeData {
  _Node(this.label);
  final String label;
}

_Node node(String label, [List<_Node> children = const []]) {
  final n = _Node(label);
  for (final c in children) {
    n.addChild(c);
  }
  return n;
}

List<_Node> buildSampleData() {
  return [
    node('Documents', [
      node('Work', [node('report.pdf'), node('budget.xlsx')]),
      node('Personal', [node('resume.docx'), node('notes.txt')]),
    ]),
    node('Pictures', [
      node('Vacation', [node('beach.png'), node('mountain.png')]),
      node('avatar.png'),
    ]),
    node('Music', [node('song1.mp3'), node('song2.mp3')]),
  ];
}

void main() {
  int totalNodes(List<_Node> nodes) {
    int sum = 0;
    for (final n in nodes) {
      sum += 1 + totalNodes(n.children.cast<_Node>());
    }
    return sum;
  }

  test('expandAll: every node visible and indexable', () {
    final data = buildSampleData();
    final c = TreeViewController();
    c.treeData(data);
    c.numberOfVisibleChild(); // force root build

    c.expandAll();

    final expected = totalNodes(data); // 18
    final count = c.numberOfVisibleChild();
    expect(count, expected,
        reason: 'all $expected nodes should be visible after expandAll');

    // Every visible index must resolve to a controller (no null crash).
    for (int i = 0; i < count; i++) {
      expect(() => c.treeNodeOfIndex(i), returnsNormally);
    }
  });

  test('collapseAll: only roots visible', () {
    final data = buildSampleData();
    final c = TreeViewController();
    c.treeData(data);
    c.numberOfVisibleChild();

    c.expandAll();
    c.collapseAll();

    expect(c.numberOfVisibleChild(), data.length);
    for (int i = 0; i < data.length; i++) {
      expect(() => c.treeNodeOfIndex(i), returnsNormally);
    }
  });
}
