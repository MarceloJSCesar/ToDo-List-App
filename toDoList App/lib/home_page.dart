import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _toDoController = TextEditingController();
  List _toDoList = [];
  Map<String, dynamic> _lastRemoved;
  int _lastRemovedPos;

  void addToDo() {
    setState(() {
      Map<String, dynamic> _newToDo = Map();
      _newToDo["title"] = _toDoController.text;
      _newToDo["Ok"] = false;
      _toDoList.add(_newToDo);
      _toDoController.text = "";
      _saveData();
    });
  }

  void clearAllToDo() {
    setState(() {
      _toDoController.text = "";
      _toDoList.length = 0;
    });
  }

  Future<Null> _refresh() async {
    await Future.delayed(Duration(seconds: 1));

    setState(() {
      _toDoList.sort((a, b) {
        if (a["Ok"] && !b["Ok"])
          return 1;
        else if (!a["Ok"] && b["Ok"])
          return -1;
        else
          return 0;
      });
      _saveData();
    });
    return null;
  }

  @override
  void initState() {
    super.initState();
    _readData().then((data) {
      setState(() {
        _toDoList = json.decode(data);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.greenAccent,
        title: Text(
          'ToDo List',
          style: TextStyle(fontSize: 15, color: Colors.black),
        ),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.delete_forever,
              color: Colors.grey,
            ),
            onPressed: () {
              clearAllToDo();
            },
          ),
          IconButton(
            icon: Icon(
              Icons.settings,
              color: Colors.black,
            ),
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (_) {
                    return AlertDialog(
                      backgroundColor: Colors.greenAccent,
                      content: Scaffold(
                        backgroundColor: Colors.greenAccent,
                        body: Container(
                          margin: EdgeInsets.only(top: 40),
                          child: Column(
                            children: <Widget>[
                              ListTile(
                                title: Text(
                                  'Organize',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                trailing: IconButton(
                                  icon: Icon(
                                    Icons.sort,
                                    color: Colors.black,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _toDoList.sort();
                                    });
                                  },
                                ),
                                onTap: () {
                                  _toDoList.sort();
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  });
            },
          ),
        ],
      ),
      backgroundColor: Colors.greenAccent,
      body: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(10, 20, 10, 0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    textAlign: TextAlign.center,
                    controller: _toDoController,
                    decoration: InputDecoration(
                      labelText: 'Errands',
                      labelStyle: TextStyle(color: Colors.black, fontSize: 18),
                    ),
                  ),
                ),
                RaisedButton(
                  child: Text(
                    'Add',
                    style: TextStyle(color: Colors.black),
                  ),
                  onPressed: () {
                    if (_toDoController.text.length <= 0) {
                      showDialog(
                          context: context,
                          builder: (_) {
                            return AlertDialog(
                              backgroundColor: Colors.greenAccent,
                              content: Text(
                                  'Please Fill The Blanks To Get Add Your Errands ! Enjoy '),
                            );
                          });
                    } else {
                      addToDo();
                    }
                  },
                  colorBrightness: Brightness.dark,
                  color: Colors.greenAccent,
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              margin: EdgeInsets.only(top: 20),
              child: RefreshIndicator(
                color: Colors.black,
                backgroundColor: Colors.greenAccent,
                onRefresh: _refresh,
                child: ListView.builder(
                    itemCount: _toDoList.length, itemBuilder: _buildListTile),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListTile(BuildContext context, index) {
    return Dismissible(
      key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
      direction: DismissDirection.startToEnd,
      background: Container(
        child: Align(
          alignment: Alignment(-0.9, 0.0),
          child: Icon(
            Icons.delete,
            color: Colors.white,
          ),
        ),
        color: Colors.red,
      ),
      child: CheckboxListTile(
        title: Text(_toDoList[index]["title"]),
        value: _toDoList[index]["Ok"],
        onChanged: (value) {
          setState(() {
            _toDoList[index]["Ok"] = value;
            _saveData();
          });
        },
        secondary: CircleAvatar(
          child: Icon(
            _toDoList[index]["Ok"] ? Icons.check : Icons.home_work_outlined,
          ),
        ),
      ),
      onDismissed: (direction) {
        setState(() {
          _lastRemoved = Map.from(_toDoList[index]);
          _lastRemovedPos = index;
          _toDoList.removeAt(index);
          _saveData();

          final snack = SnackBar(
            content: Text('Errands \" ${_lastRemoved["title"]} \" Removed'),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () {
                setState(() {
                  _toDoList.insert(_lastRemovedPos, _lastRemoved);
                  _saveData();
                });
              },
            ),
            duration: Duration(seconds: 2),
          );
          Scaffold.of(context).removeCurrentSnackBar();
          Scaffold.of(context).showSnackBar(snack);
        });
      },
    );
  }

  Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/data.json');
  }

  Future<File> _saveData() async {
    String data = json.encode(_toDoList);
    final file = await _getFile();
    return file.writeAsString(data);
  }

  Future<String> _readData() async {
    try {
      final file = await _getFile();
      return file.readAsString();
    } catch (value) {
      return null;
    }
  }
}
