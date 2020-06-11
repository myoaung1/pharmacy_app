import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:pharmacyapp/custom-widget/widget.dart';
import 'package:pharmacyapp/model/model.master.dart';

class PacketType extends StatefulWidget {
  @override
  _PacketTypeState createState() => _PacketTypeState();
}

class _PacketTypeState extends State<PacketType> {
  Icon _cusIcon = Icon(Icons.search);
  Widget _cusSearchBar = Text('Packet Type');

  List<PacketTypeModel> _datalist = [];
  List<PacketTypeModel> _datalistselected = [];
  List<PacketTypeModel> _datalistsearch = [];

  bool _isVisible = false;
  bool _sort;
  int _selectedMenu = 0;
  String _typecode = '';
  String _loadingText = 'Loading...';

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _namecontroller = TextEditingController();
  final TextEditingController _capacitycontroller = TextEditingController();

  Future<void> getData() async {
    List data;
    _datalist.clear();
    _datalistselected.clear();
    _datalistsearch.clear();
    this._cusIcon = Icon(Icons.search);
    this._cusSearchBar = Text('Packet Type');
    _isVisible = false;
    var response = await http.get(
        Uri.encodeFull("http://192.168.43.28/api/packet-type/list"),
        headers: {"Accept": "application/json"});

    setState(() {
      data = json.decode(response.body);
      int count = data.length;
      for (int i = 0; i < count; i++) {
        PacketTypeModel item = PacketTypeModel(
            typecode: data[i]["TypeCode"],
            typename: data[i]["TypeName"],
            capacity: data[i]["Capacity"]);
        _datalist.add(item);
      }
    });
  }

  Future<void> createItems(String name, String capacity) async {
    final http.Response responsecode = await http.get(
      'http://192.168.43.28/api/packet-type/getcode',
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );
    String code = json.decode(responsecode.body);

    Map data = {
      'TypeCode': code,
      'TypeName': name,
      'Capacity': capacity,
    };

    final http.Response response = await http.post(
      'http://192.168.43.28/api/packet-type/insert',
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: data,
    );

    if (response.statusCode == 201) {
      setState(() {
        getData();
        getList(context);
      });
      _namecontroller.text = '';
      _capacitycontroller.text = '';
    } else {
      print("response code : ${response.statusCode}");
    }
  }

  Future<void> editItems(String name, String capacity) async {
    Map data = {
      'TypeCode': _typecode.toString(),
      'TypeName': name,
      'Capacity': capacity
    };

    final http.Response response = await http.post(
      'http://192.168.43.28/api/packet-type/update',
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: data,
    );

    if (response.statusCode == 200) {
      setState(() {
        getData();
      });
      _namecontroller.text = '';
      _capacitycontroller.text = '';
    } else {
      print("response code : ${response.statusCode}");
    }
  }

  Future<void> deleteItems(String id) async {
    final http.Response response = await http.post(
      'http://192.168.43.28/api/packet-type/delete?id=$id',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    if (response.statusCode == 200) {
      setState(() {
        getData();
      });
    } else
      print(Exception(
          'Failed to delete items. St.Code ${response.statusCode} , id : $id'));
  }

  void _onItemTapped(int index) {
    setState(() {
      if (_datalistselected.length > 1) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return getMessagePopup(
                  context, "Warning !!!", "Please choose single row.");
            });
      } else {
        // index 0 for edit
        if (index == 0) {
          _typecode = _datalistselected[0].typecode;
          _namecontroller.text = _datalistselected[0].typename;
          _capacitycontroller.text = _datalistselected[0].capacity.toString();
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return getpopup(context, "update", "0", "Update");
              });
        }
        // index 0 for delete
        else if (index == 1) {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return getConfirmationPopup(context);
              });
        }
      }
      _selectedMenu = index;
    });
  }

  onSelectedRow(bool selected, PacketTypeModel item) async {
    setState(() {
      if (selected) {
        _datalistselected.clear();
        _datalistselected.add(item);
      } else {
        _datalistselected.remove(item);
      }

      if (_datalistselected.length > 0) {
        _isVisible = true;
      } else {
        _isVisible = false;
      }
    });
  }

  onSortColumn(int columnindex, bool ascending) {
    if (columnindex == 0) {
      if (ascending) {
        _datalist.sort((a, b) => a.typecode.compareTo(b.typecode));
      } else {
        _datalist.sort((a, b) => b.typecode.compareTo(a.typecode));
      }
    } else if (columnindex == 1) {
      if (ascending) {
        _datalist.sort((a, b) => a.typename.compareTo(b.typename));
      } else {
        _datalist.sort((a, b) => b.typename.compareTo(a.typename));
      }
    } else if (columnindex == 2) {
      if (ascending) {
        _datalist.sort((a, b) => a.capacity.compareTo(b.capacity));
      } else {
        _datalist.sort((a, b) => b.capacity.compareTo(a.capacity));
      }
    }
  }

  void _searchItem(String value) async {
    setState(() {
      _datalistsearch.clear();
      _datalist.forEach((element) {
        if (element.typename.toLowerCase().contains(value.toLowerCase())) {
          _datalistsearch.add(element);
        }
      });
      getList(context);
    });
    print('List Count : ${_datalistsearch.length}');
  }

  @override
  void initState() {
    super.initState();
    _sort = false;
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(60.0), // here the desired height
          child: AppBar(
            elevation: 0,
            titleSpacing: 0,
            backgroundColor: Colors.grey[0],
            title: _cusSearchBar,
            actions: <Widget>[
              IconButton(
                icon: _cusIcon,
                onPressed: () {
                  setState(() {
                    if (this._cusIcon.icon == Icons.search) {
                      this._cusIcon = Icon(Icons.clear);
                      this._cusSearchBar = TextField(
                        autofocus: true,
                        decoration: new InputDecoration(
                          contentPadding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                          hintText: 'Search ...',
                        ),
                        textInputAction: TextInputAction.search,
                        onSubmitted: (value) => _searchItem(value),
                      );
                    } else {
                      setState(() {
                        getData();
                      });
                      this._cusIcon = Icon(Icons.search);
                      this._cusSearchBar = Text('Packet Type');
                    }
                  });
                },
              ),
              IconButton(
                icon: Icon(Icons.refresh),
                onPressed: () {
                  setState(() {
                    getData();
                  });
                },
              ),
            ],
          )),
      body: getList(context),
      floatingActionButton: FloatingActionButton(
        shape: CircleBorder(),
        elevation: 3,
        backgroundColor: Colors.blueAccent,
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
        onPressed: () {
          _namecontroller.text = "";
          _capacitycontroller.text = "";
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return getpopup(context, "insert", "0", "Create");
              });
        },
      ),
      bottomNavigationBar: AnimatedOpacity(
        opacity: _isVisible ? 1.0 : 0.0,
        duration: Duration(milliseconds: 500),
        // The green box must be a child of the AnimatedOpacity widget.
        child: Visibility(
          visible: _isVisible,
          child: BottomNavigationBar(
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.edit),
                title: Text('Edit'),
                backgroundColor: Colors.blue,
              ),
              BottomNavigationBarItem(
                  icon: Icon(Icons.delete),
                  title: Text('Delete'),
                  backgroundColor: Colors.blue),
            ],
            currentIndex: _selectedMenu,
            selectedItemColor: Colors.blueAccent,
            onTap: _onItemTapped,
          ),
        ),
      ),
    );
  }

  Widget getList(BuildContext context) {
    List<PacketTypeModel> listdata;
    if (_datalistsearch.length > 0) {
      print('Success');
      listdata = _datalistsearch;
    } else if (this._cusIcon.icon == Icons.clear) {
      print('Success / Null');
      listdata = _datalistsearch;
      _loadingText = 'No data will be return';
    } else {
      listdata = _datalist;
    }
    if (listdata.length == 0) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(
                  backgroundColor: Colors.blueAccent,
                  valueColor:
                      new AlwaysStoppedAnimation<Color>(Colors.white70)),
            ),
            Text(_loadingText),
          ],
        ),
      );
    } else {
      return SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            sortColumnIndex: 0,
            showCheckboxColumn: true,
            sortAscending: _sort,
            columnSpacing: 10,
            columns: [
              DataColumn(
                  label: Text('Code'),
                  onSort: (columnindex, ascending) {
                    setState(() {
                      _sort = !_sort;
                    });
                    onSortColumn(columnindex, _sort);
                  }),
              DataColumn(
                  label: Text('Name'),
                  onSort: (columnindex, ascending) {
                    setState(() {
                      _sort = !_sort;
                    });
                    onSortColumn(columnindex, _sort);
                  }),
              DataColumn(
                  label: Text('Capacity'),
                  onSort: (columnindex, ascending) {
                    setState(() {
                      _sort = !_sort;
                    });
                    onSortColumn(columnindex, _sort);
                  }),
            ],
            rows: listdata
                .map((e) => DataRow(
                        cells: <DataCell>[
                          DataCell(Text(e.typecode)),
                          DataCell(Text(e.typename)),
                          DataCell(Text(e.capacity.toString()))
                        ],
                        selected: _datalistselected.contains(e),
                        onSelectChanged: (b) {
                          onSelectedRow(b, e);
                        }))
                .toList(),
          ),
        ),
      );
    }
  }

  Widget getpopup(
      BuildContext context, String mode, String id, String buttonText) {
    final _screenWidth = MediaQuery.of(context).size.width;

    return AlertDialog(
      insetPadding: EdgeInsets.all(0),
      content: Stack(
        overflow: Overflow.visible,
        children: <Widget>[
          Positioned(
            right: -30.0,
            top: -30.0,
            child: InkResponse(
              onTap: () {
                Navigator.of(context).pop();
                print('close');
              },
              child: CircleAvatar(
                child: Icon(Icons.close),
                backgroundColor: Colors.blue,
              ),
            ),
          ),
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  width: _screenWidth - 75,
                  padding: EdgeInsets.all(10.0),
                  child: TextFormField(
                    autofocus: true,
                    controller: _namecontroller,
                    textInputAction: TextInputAction.next,
                    decoration: new InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[100],
                      hintText: 'Enter type name...',
                      focusedBorder: OutlineInputBorder(
                        borderSide: new BorderSide(color: Colors.grey[300]),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: new BorderSide(color: Colors.grey[300]),
                      ),
                    ),
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter name';
                      }
                      return null;
                    },
                    onFieldSubmitted: (String value) {
                      if (_formKey.currentState.validate()) {
                        if (mode == "insert") {
                          createItems(
                              _namecontroller.text, _capacitycontroller.text);
                        } else if (mode == "update") {
                          editItems(
                              _namecontroller.text, _capacitycontroller.text);
                        }
                        _formKey.currentState.save();
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(10.0),
                  child: TextFormField(
                    autofocus: true,
                    controller: _capacitycontroller,
                    textInputAction: TextInputAction.go,
                    keyboardType: TextInputType.number,
                    decoration: new InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[100],
                      hintText: 'Enter capacity...',
                      focusedBorder: OutlineInputBorder(
                        borderSide: new BorderSide(color: Colors.grey[300]),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: new BorderSide(color: Colors.grey[300]),
                      ),
                    ),
                    style: TextStyle(height: 1),
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter capacity';
                      }
                      return null;
                    },
                    onFieldSubmitted: (String value) {
                      if (_formKey.currentState.validate()) {
                        if (mode == "insert") {
                          createItems(
                              _namecontroller.text, _capacitycontroller.text);
                        } else if (mode == "update") {
                          editItems(
                              _namecontroller.text, _capacitycontroller.text);
                        }
                        _formKey.currentState.save();
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(10, 5, 10, 0),
                  child: RaisedButton(
                    child: Text(
                      buttonText,
                      style: TextStyle(color: Colors.white),
                    ),
                    color: Colors.blue,
                    onPressed: () {
                      if (_formKey.currentState.validate()) {
                        if (mode == "insert") {
                          createItems(
                              _namecontroller.text, _capacitycontroller.text);
                        } else if (mode == "update") {
                          editItems(
                              _namecontroller.text, _capacitycontroller.text);
                        }
                        _formKey.currentState.save();
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                )
              ],
            ),
          )
        ],
      ),
      contentPadding: EdgeInsets.all(10.0),
    );
  }

  Widget getConfirmationPopup(BuildContext context) {
    return AlertDialog(
      title: Text("Confirmation !!!"),
      content:
          Text("Would you like to delete '${_datalistselected[0].typename}' ?"),
      actions: [
        FlatButton(
          child: Text(
            'Cancel',
            style: TextStyle(color: Colors.black54),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        FlatButton(
          child: Text(
            'Delete',
            style: TextStyle(color: Colors.red),
          ),
          onPressed: () {
            deleteItems(_datalistselected[0].typecode.toString());
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
