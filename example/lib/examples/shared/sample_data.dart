import 'tree_node_data.dart';

/// Builds a small multi-level sample tree shared across the examples.
List<TreeNodeData> buildSampleData() {
  TreeNodeData node(String label, [List<TreeNodeData> children = const []]) {
    final n = TreeNodeData(label: label);
    for (final child in children) {
      n.addChild(child);
    }
    return n;
  }

  return [
    node('Documents', [
      node('Work', [
        node('report.pdf'),
        node('budget.xlsx'),
      ]),
      node('Personal', [
        node('resume.docx'),
        node('notes.txt'),
      ]),
    ]),
    node('Pictures', [
      node('Vacation', [
        node('beach.png'),
        node('mountain.png'),
      ]),
      node('avatar.png'),
    ]),
    node('Music', [
      node('song1.mp3'),
      node('song2.mp3'),
    ]),
  ];
}

/// Builds root nodes whose children are loaded lazily (no children yet).
List<TreeNodeData> buildLazyRoots() {
  return [
    TreeNodeData(label: 'Continents', lazy: true),
    TreeNodeData(label: 'Languages', lazy: true),
    TreeNodeData(label: 'Frameworks', lazy: true),
  ];
}

/// Simulates fetching the children for a lazily-loaded node.
List<TreeNodeData> buildLazyChildren(TreeNodeData parent) {
  return List.generate(
    3,
    (i) => TreeNodeData(label: '${parent.label} child ${i + 1}'),
  );
}
