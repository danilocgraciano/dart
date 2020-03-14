import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MaterialApp(home: Home()));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  var _toDoList = [];
  Map<String, dynamic> _lastRemoved;
  int _lastRemovedPos;

  final _toDoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _readData().then((data) {
      setState(() {
        if (data != null) _toDoList = json.decode(data);
      });
    });
  }

  void _addToDo() {
    setState(() {
      Map<String, dynamic> newToDo = Map();

      if (_toDoController.text.isEmpty) return;

      newToDo['title'] = _toDoController.text;
      newToDo['ok'] = false;

      _toDoController.text = '';

      _toDoList.add(newToDo);
      _saveData();
    });
  }

  Future<Null> _refresh() async {
    await Future.delayed(Duration(seconds: 1));

    setState(() {
      _toDoList.sort((o1, o2) {
        if (o1['ok'] && !o2['ok'])
          return 1;
        else if (!o1['ok'] && o2['ok'])
          return -1;
        else
          return 0;
      });

      _saveData();
    });

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Tarefas'),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(17, 1, 7, 1),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                        labelText: 'Nova Tarefa',
                        labelStyle: TextStyle(color: Colors.blueAccent)),
                    controller: _toDoController,
                  ),
                ),
                RaisedButton(
                    color: Colors.blueAccent,
                    child: Text('ADD'),
                    textColor: Colors.white,
                    onPressed: () {
                      _addToDo();
                    }),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
                child: ListView.builder(
                  padding: EdgeInsets.only(top: 10),
                  itemCount: _toDoList.length,
                  itemBuilder: buildItem,
                ),
                onRefresh: _refresh),
          )
        ],
      ),
    );
  }

  Widget buildItem(BuildContext context, int index) {
    return Dismissible(
        background: Container(
          color: Colors.red,
          child: Align(
            alignment: Alignment(-0.9, 0.0),
            child: Icon(Icons.delete, color: Colors.white),
          ),
        ),
        direction: DismissDirection.startToEnd,
        child: CheckboxListTile(
          value: _toDoList[index]['ok'],
          title: Text(_toDoList[index]['title']),
          onChanged: (checked) {
            setState(() {
              _toDoList[index]['ok'] = checked;
              _saveData();
            });
          },
          secondary: CircleAvatar(
              child: Icon(_toDoList[index]['ok'] ? Icons.check : Icons.error)),
        ),
        key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
        onDismissed: (direction) {
          setState(() {
            if (direction == DismissDirection.startToEnd) {
              _lastRemoved = Map.from(_toDoList[index]);
              _lastRemovedPos = index;
              _toDoList.removeAt(index);

              _saveData();
            }

            final snackbar = SnackBar(
              content: Text('Tarefa \'${_lastRemoved['title']}\' removida'),
              action: SnackBarAction(
                  label: 'Desfazer',
                  onPressed: () {
                    setState(() {
                      _toDoList.insert(_lastRemovedPos, _lastRemoved);
                      _saveData();
                    });
                  }),
              duration: Duration(seconds: 2),
            );

            Scaffold.of(context).removeCurrentSnackBar();
            Scaffold.of(context).showSnackBar(snackbar);
          });
        });
  }

  Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/lista_tarefas.json');
  }

  Future<File> _saveData() async {
    var data = json.encode(_toDoList);
    final file = await _getFile();
    return file.writeAsString(data);
  }

  Future<String> _readData() async {
    try {
      final file = await _getFile();
      return file.readAsString();
    } catch (e) {
      return null;
    }
  }
}
