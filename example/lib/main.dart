import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:list_treeview/list_treeview.dart';
import 'package:list_treeview/tree/tree_view.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: Center(
        child: RaisedButton(
          child: Text('TreeView'),
          onPressed: () {
            Navigator.push(
                context, CupertinoPageRoute(builder: (_) => TreePage()));
          },
        ),
      ),
    );
  }
}

/// The data class that is bound to the child node
/// You must inherit from NodeData ！！！
/// You can customize any of your properties
class TreeNodeData extends NodeData {
  TreeNodeData({this.label, this.color}) : super();

  /// Other properties that you want to define
  final String label;
  final Color color;
  String property1;
  String property2;
  String property3;

  ///...
}

class TreePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _TreePageState();
  }
}

class _TreePageState extends State<TreePage>
    with SingleTickerProviderStateMixin {
  TreeViewController _controller;
  bool _isSuccess;
  @override
  void initState() {
    super.initState();
    ///The controller must be initialized when the treeView create
    _controller = TreeViewController();
    ///Data may be requested asynchronously
    getData();
  }


  void getData() async {

    print('start get data');
    _isSuccess = false;
    await Future.delayed(Duration(seconds: 2));

    var colors1 = TreeNodeData(label: 'Colors1');
    var color11 = TreeNodeData(
        label: 'rgb(0,139,69)', color: Color.fromARGB(255, 0, 139, 69));
    var color12 = TreeNodeData(
        label: 'rgb(0,139,69)', color: Color.fromARGB(255, 0, 191, 255));
    var color13 = TreeNodeData(
        label: 'rgb(0,139,69)', color: Color.fromARGB(255, 255, 106, 106));
    var color14 = TreeNodeData(
        label: 'rgb(0,139,69)', color: Color.fromARGB(255, 160, 32, 240));
    colors1.addChild(color11);
    colors1.addChild(color12);
    colors1.addChild(color13);
    colors1.addChild(color14);

    var colors2 = TreeNodeData(label: 'Colors2');
    var color21 = TreeNodeData(
        label: 'rgb(0,139,69)', color: Color.fromARGB(255, 255, 64, 64));
    var color22 = TreeNodeData(
        label: 'rgb(0,139,69)', color: Color.fromARGB(255, 28, 134, 238));
    var color23 = TreeNodeData(
        label: 'rgb(0,139,69)', color: Color.fromARGB(255, 255, 106, 106));
    var color24 = TreeNodeData(
        label: 'rgb(0,139,69)', color: Color.fromARGB(255, 205, 198, 115));
    colors2.addChild(color21);
    colors2.addChild(color22);
    colors2.addChild(color23);
    colors2.addChild(color24);

    /// set data
    _controller.treeData([colors1, colors2]);
    print('set treeData suceess');

    setState(() {
      _isSuccess = true;
    });

  }




  @override
  void dispose() {
    super.dispose();
  }

  /// Add
  void add(TreeNodeData dataNode) {
    /// create New node
//    DateTime time = DateTime.now();
//    int milliseconds = time.millisecondsSinceEpoch ~/ 1000;
    int r = Random.secure().nextInt(255);
    int g = Random.secure().nextInt(255);
    int b = Random.secure().nextInt(255);

    var newNode = TreeNodeData(
        label: 'rgb($r,$g,$b)', color: Color.fromARGB(2555, r, g, b));

    _controller.insertAtFront(dataNode, newNode);
//    _controller.insertAtRear(dataNode, newNode);
//    _controller.insertAtIndex(1, dataNode, newNode);
  }

  void delete(dynamic item) {
    _controller.removeItem(item);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TreeView'),
      ),
      body: _isSuccess ? getBody(): getProgressView(),
    );
  }

  Widget getProgressView() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }


  Widget getBody() {
    return Column(
      children: <Widget>[
        Expanded(
            child: ListTreeView(
              itemBuilder: (BuildContext context, int index, int level,
                  bool isExpand, dynamic data) {
                TreeNodeData item = data;
//              double width = MediaQuery.of(context).size.width;
                double offsetX = level * 16.0;
                return Container(
                  padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                      border: Border(
                          bottom: BorderSide(width: 1, color: Colors.grey))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(left: offsetX),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                '$index',
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                '${item.label}',
                                style: TextStyle(color: item.color),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Visibility(
                        visible: isExpand,
                        child: InkWell(
                          onTap: () {
                            add(item);
                          },
                          child: Icon(
                            Icons.add,
                            size: 30,
                          ),
                        ),
                      )
                    ],
                  ),
                );
              },
              onTap: (index, level, isExpand, data) {
                print('index = $index');
              },
              onLongPress: (index, level, isExpand, data) {
                delete(data);
              },
              controller: _controller,
            )),
      ],
    );
  }



}
