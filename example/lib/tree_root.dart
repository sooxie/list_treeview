//import 'dart:math';
//import 'package:flutter/material.dart';
//import 'package:list_treeview/list_treeview.dart';
//
///// The data class that is bound to the child node
///// You must inherit from NodeData ！！！
///// You can customize any of your properties
//class TreeNodeData extends NodeData {
//  TreeNodeData({this.label,this.color}) : super();
//
//  /// Other properties that you want to define
//  final String label;
//  final Color color;
//  String property1;
//  String property2;
//  String property3;
/////...
//}
//
//class TreePage extends StatefulWidget {
//  @override
//  State<StatefulWidget> createState() {
//    // TODO: implement createState
//    return _TreePageState();
//  }
//}
//
//class _TreePageState extends State<TreePage>
//    with SingleTickerProviderStateMixin {
//
//  TreeViewController _controller;
//  @override
//  void initState() {
//    super.initState();
//
//    var colors1 = TreeNodeData(label: 'Colors1');
//    var color11 = TreeNodeData(label: 'rgb(0,139,69)', color: Color.fromARGB(255, 0 ,139 , 69));
//    var color12 = TreeNodeData(label: 'rgb(0,139,69)', color: Color.fromARGB(255,0,191 ,255));
//    var color13 = TreeNodeData(label: 'rgb(0,139,69)', color: Color.fromARGB(255,255 ,106, 106));
//    var color14 = TreeNodeData(label: 'rgb(0,139,69)', color: Color.fromARGB(255,160 ,32, 240));
//    colors1.addChild(color11);
//    colors1.addChild(color12);
//    colors1.addChild(color13);
//    colors1.addChild(color14);
//
//    var colors2 = TreeNodeData(label: 'Colors2');
//    var color21 = TreeNodeData(label: 'rgb(0,139,69)', color: Color.fromARGB(255, 255 ,64, 64));
//    var color22 = TreeNodeData(label: 'rgb(0,139,69)', color: Color.fromARGB(255,28, 134, 238));
//    var color23 = TreeNodeData(label: 'rgb(0,139,69)', color: Color.fromARGB(255,255 ,106, 106));
//    var color24 = TreeNodeData(label: 'rgb(0,139,69)', color: Color.fromARGB(255,205 ,198, 115));
//    colors2.addChild(color21);
//    colors2.addChild(color22);
//    colors2.addChild(color23);
//    colors2.addChild(color24);
//    /// set data
//    _controller = TreeViewController(data: [colors1,colors2]);
//  }
//
//  @override
//  void dispose() {
//    super.dispose();
//  }
//
//  _getRandomColor() {
//    return Color.fromARGB(
//        255,
//        Random.secure().nextInt(255),
//        Random.secure().nextInt(255),
//        Random.secure().nextInt(255));
//  }
//  /// Add
//  void add(TreeNodeData dataNode) {
//    /// create New node
////    DateTime time = DateTime.now();
////    int milliseconds = time.millisecondsSinceEpoch ~/ 1000;
//    int r = Random.secure().nextInt(255);
//    int g = Random.secure().nextInt(255);
//    int b = Random.secure().nextInt(255);
//
//    var newNode = TreeNodeData(
//      label: 'rgb($r,$g,$b)', color: Color.fromARGB(2555, r, g, b)
//    );
//
//    _controller.insertAtFront(dataNode,newNode);
////    _controller.insertAtRear(dataNode, newNode);
////    _controller.insertAtIndex(1, dataNode, newNode);
//  }
//
//  void delete(dynamic item) {
//    _controller.removeItem(item);
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    return Scaffold(
//      appBar: AppBar(
//        title: Text('TreeView'),
//      ),
//      body: Column(
//        children: <Widget>[
//
//          Expanded(
//              child: ListTreeView(
//            itemBuilder: (BuildContext context, int index, int level,
//                bool isExpand, dynamic data) {
//              TreeNodeData item = data;
////              double width = MediaQuery.of(context).size.width;
//              double offsetX = level * 16.0;
//              return Container(
//                padding: EdgeInsets.all(16.0),
//                decoration: BoxDecoration(
//                    border: Border(
//                        bottom: BorderSide(width: 1, color: Colors.grey))),
//                child: Row(
//                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                  children: <Widget>[
//                    Expanded(
//                      child: Padding(
//                        padding: EdgeInsets.only(left: offsetX),
//                        child: Row(
//                          mainAxisAlignment: MainAxisAlignment.start,
//                          crossAxisAlignment: CrossAxisAlignment.center,
//                          children: <Widget>[
//
//                            Text('$index',
//
//                            ),
//                            SizedBox(
//                              width: 10,
//                            ),
//                            Text('${item.label}',
//                              style: TextStyle(
//                                color: item.color
//                              ),
//                            ),
//                          ],
//                        ),
//                      ),
//                    ),
//                    Visibility(
//                    visible: isExpand,
//                      child: InkWell(
//                        onTap: () {
//                          add(item);
//                        },
//                        child: Icon(Icons.add,
//                          size: 30,
//                        ),
//                      ),
//                    )
//
//                  ],
//                ),
//              );
//            },
//            onTap: (index, level, isExpand, data) {
//              print('index = $index');
//            },
//            onLongPress: (index, level, isExpand, data) {
//              delete(data);
//            },
//            controller: _controller,
//          )),
//        ],
//      ),
//    );
//  }
//}
