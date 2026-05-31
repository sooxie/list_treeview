import 'package:flutter_test/flutter_test.dart';
import 'package:list_treeview/list_treeview.dart';

/// Minimal NodeData used by the tests.
class _Node extends NodeData {
  _Node(this.label);
  final String label;
}

void main() {
  test('add a child to a collapsed node, then expand it', () {
    // Documents has two children and starts collapsed.
    final documents = _Node('Documents')
      ..addChild(_Node('Work'))
      ..addChild(_Node('Personal'));

    final controller = TreeViewController();
    controller.treeData([documents]);
    // Force the root controller tree to be built.
    controller.numberOfVisibleChild();

    // Append a child while the parent is collapsed, then reveal it by
    // expanding. This used to throw a RangeError inside
    // NodeController.insertChildControllers.
    final newNode = _Node('New node');
    controller.insertAtRear(documents, newNode, closeCanInsert: true);

    expect(documents.children.length, 3);

    final index = controller.indexOfItem(documents);
    expect(index, 0);

    // Should not throw.
    controller.expandOrCollapse(index);

    expect(controller.isExpanded(documents), isTrue);
    // Documents + its 3 visible children are now laid out.
    expect(controller.numberOfVisibleChild(), 4);
  });
}
