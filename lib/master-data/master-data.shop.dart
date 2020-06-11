import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:pharmacyapp/custom-widget/widget.dart';
import 'dart:convert';

import 'package:pharmacyapp/model/model.master.dart';

class ShopMaster extends StatefulWidget {
  @override
  _ShopMasterState createState() => _ShopMasterState();
}

class _ShopMasterState extends State<ShopMaster> {
  Icon cusIcon = Icon(Icons.search);
  Widget cusSearchBar = Text('Shop');

  List data;
  List<ShopModel> datalist = [];
  List<ShopModel> datalistselected = [];
  List<ShopModel> datalistsearch = [];

  bool _isVisible = false;
  bool _sort;
  int _selectedMenu = 0;
  int _shopId = 0;
  String _loadingText = 'Loading...';

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _controller = TextEditingController();

  Future<void> getData() async {
    List data;
    datalist.clear();
    datalistselected.clear();
    datalistsearch.clear();
    this.cusIcon = Icon(Icons.search);
    this.cusSearchBar = Text('Shop');
    _isVisible = false;
    var response = await http.get(
        Uri.encodeFull("http://192.168.43.28/api/shop/list"),
        headers: {"Accept": "application/json"});

    setState(() {
      data = json.decode(response.body);
      int count = data.length;
      for (int i = 0; i < count; i++) {
        ShopModel item = ShopModel(
          shopid: data[i]["ShopID"],
          shopname: data[i]["ShopName"].toString(),
        );
        datalist.add(item);
      }
    });
  }

  Future<void> createItems(String name) async {
    Map data = {
      'ShopID': "0",
      'ShopName': name,
    };

    final http.Response response = await http.post(
      'http://192.168.43.28/api/shop/insert',
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: data,
    );

    if (response.statusCode == 201) {
      setState(() {
        getData();
      });
      _controller.text = '';
    } else {
      print(response.body);
    }
  }

  Future<void> editItems(String name) async {
    Map data = {
      'ShopID': _shopId.toString(),
      'ShopName': name,
    };

    final http.Response response = await http.post(
      'http://192.168.43.28/api/shop/update',
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: data,
    );

    if (response.statusCode == 200) {
      setState(() {
        getData();
      });
      _controller.text = '';
    } else {
      print(response.statusCode);
    }
  }

  Future<void> deleteItems(String id) async {
    final http.Response response = await http.post(
      'http://192.168.43.28/api/shop/delete?id=$id',
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

  onSelectedRow(bool selected, ShopModel item) async {
    setState(() {
      if (selected) {
        datalistselected.clear();
        datalistselected.add(item);
      } else {
        datalistselected.remove(item);
      }

      if (datalistselected.length > 0) {
        _isVisible = true;
      } else {
        _isVisible = false;
      }
    });
  }

  onSortColumn(int columnindex, bool ascending) {
    if (columnindex == 0) {
      if (ascending) {
        datalist.sort((a, b) => a.shopid.compareTo(b.shopid));
      } else {
        datalist.sort((a, b) => b.shopid.compareTo(a.shopid));
      }
    } else if (columnindex == 1) {
      if (ascending) {
        datalist.sort((a, b) => a.shopname.compareTo(b.shopname));
      } else {
        datalist.sort((a, b) => b.shopname.compareTo(a.shopname));
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      if (datalistselected.length > 1) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return getMessagePopup(
                  context, "Warning !!!", "Please choose single row.");
            });
      } else {
        // index 0 for edit
        if (index == 0) {
          _shopId = datalistselected[0].shopid;
          _controller.text = datalistselected[0].shopname;
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

  void _searchItem(String value) async {
    setState(() {
      datalistsearch.clear();
      datalist.forEach((element) {
        if (element.shopname.toLowerCase().contains(value.toLowerCase())) {
          datalistsearch.add(element);
        }
      });
      getList(context);
    });
    print('List Count : ${datalistsearch.length}');
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
            title: cusSearchBar,
            actions: <Widget>[
              IconButton(
                icon: cusIcon,
                onPressed: () {
                  setState(() {
                    if (this.cusIcon.icon == Icons.search) {
                      this.cusIcon = Icon(Icons.clear);
                      this.cusSearchBar = TextField(
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
                      this.cusIcon = Icon(Icons.search);
                      this.cusSearchBar = Text('Shop');
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
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: getList(context),
      ),
      floatingActionButton: FloatingActionButton(
        shape: CircleBorder(),
        elevation: 3,
        backgroundColor: Colors.blueAccent,
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
        onPressed: () {
          _controller.text = "";
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return getpopup(context, "insert", "0", "Create");
              });
        },
      ),
      bottomNavigationBar: AnimatedOpacity(
        opacity: _isVisible ? 1.0 : 0.0,
        duration: Duration(milliseconds: 1000),
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
    List<ShopModel> listdata;
    if (datalistsearch.length > 0) {
      print('Success');
      listdata = datalistsearch;
    } else if (this.cusIcon.icon == Icons.clear) {
      print('Success / Null');
      listdata = datalistsearch;
      _loadingText = 'No data will be return';
    } else {
      listdata = datalist;
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
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          DataTable(
            sortColumnIndex: 0,
            showCheckboxColumn: true,
            sortAscending: _sort,
            columns: [
              DataColumn(
                  label: Text('ID'),
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
            ],
            rows: listdata
                .map((e) => DataRow(
                        cells: <DataCell>[
                          DataCell(Text(e.shopid.toString())),
                          DataCell(Text(e.shopname)),
                        ],
                        selected: datalistselected.contains(e),
                        onSelectChanged: (b) {
                          onSelectedRow(b, e);
                        }))
                .toList(),
          )
        ],
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
                  padding: EdgeInsets.all(10.0),
                  width: _screenWidth - 75,
                  child: TextFormField(
                    autofocus: true,
                    controller: _controller,
                    textInputAction: TextInputAction.go,
                    decoration: new InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[100],
                      hintText: 'Enter shop name...',
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
                          createItems(_controller.text);
                        } else if (mode == "update") {
                          editItems(_controller.text);
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
                          createItems(_controller.text);
                        } else if (mode == "update") {
                          editItems(_controller.text);
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
          Text("Would you like to delete '${datalistselected[0].shopname}' ?"),
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
            deleteItems(datalistselected[0].shopid.toString());
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
