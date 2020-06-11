import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:pharmacyapp/custom-widget/widget.dart';
import 'dart:convert';
import 'package:pharmacyapp/model/model.master.dart';

class StockItem extends StatefulWidget {
  @override
  _StockItemState createState() => _StockItemState();
}

class _StockItemState extends State<StockItem> {
  Icon cusIcon = Icon(Icons.search);
  Widget cusSearchBar = Text('Stock Item --');
  int _selectedMenu = 0;
  String _itemCode = '';
  String _loadingText = 'Loading...';
  bool _isVisible = false;
  bool _sort;
  FocusNode _itemnameNode = new FocusNode();
  FocusNode _chemicalnameNode = new FocusNode();
  FocusNode _companynameNode = new FocusNode();
  List<StockItemModel> datalist = [];
  List<StockItemModel> datalistselected = [];
  List<StockItemModel> datalistsearch = [];
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _itemnamecontroller = TextEditingController();
  final TextEditingController _chemicalnamecontroller = TextEditingController();
  final TextEditingController _companynamecontroller = TextEditingController();

  Future<void> getData() async {
    List data;
    datalist.clear();
    datalistselected.clear();
    datalistsearch.clear();
    this.cusIcon = Icon(Icons.search);
    this.cusSearchBar = Text('Stock Item');
    _isVisible = false;
    var response = await http.get(
        Uri.encodeFull("http://192.168.43.28/api/stockitem/list"),
        headers: {"Accept": "application/json"});

    setState(() {
      data = json.decode(response.body);
      int count = data.length;
      for (int i = 0; i < count; i++) {
        StockItemModel item = StockItemModel(
          itemcode: data[i]["ItemCode"].toString(),
          itemname: data[i]["ItemName"].toString(),
          chemicalname: data[i]["ChemicalName"].toString(),
          companyname: data[i]["CompanyName"].toString(),
        );
        datalist.add(item);
      }
    });
  }

  Future<void> createItem(String name, String chemical, String company) async {
    var dataId;
    var responseID = await http.get(
        Uri.encodeFull(
            "http://192.168.43.28/api/stockitem/getcode?firstletter=${name.substring(0, 1).toUpperCase()}"),
        headers: {"Accept": "application/json"});
    setState(() {
      dataId = json.decode(responseID.body);
    });

    Map data = {
      'ItemCode': dataId == null
          ? '${name.substring(0, 1).toUpperCase()}0001'
          : '$dataId',
      'ItemName': name,
      'ChemicalName': chemical,
      'CompanyName': company
    };

    final http.Response response = await http.post(
      'http://192.168.43.28/api/stockitem/insert',
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: data,
    );

    if (response.statusCode == 201) {
      setState(() {
        getData();
      });
    } else {}
  }

  Future<void> editItem(String name, String chemical, String company) async {
    Map data = {
      'ItemCode': _itemCode,
      'ItemName': name,
      'ChemicalName': chemical,
      'CompanyName': company
    };

    final http.Response response = await http.post(
      'http://192.168.43.28/api/stockitem/update',
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: data,
    );

    if (response.statusCode == 200) {
      setState(() {
        getData();
      });
    } else {}
  }

  Future<void> deleteItems(String itemcode) async {
    final http.Response response = await http.post(
      'http://192.168.43.28/api/stockitem/delete?ID=$itemcode',
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
          'Failed to delete items. St.Code ${response.statusCode} , id : $itemcode'));
  }

  onSelectedRow(bool selected, StockItemModel item) async {
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
        datalist.sort((a, b) => a.itemcode.compareTo(b.itemcode));
      } else {
        datalist.sort((a, b) => b.itemcode.compareTo(a.itemcode));
      }
    } else if (columnindex == 1) {
      if (ascending) {
        datalist.sort((a, b) => a.itemname.compareTo(b.itemname));
      } else {
        datalist.sort((a, b) => b.itemname.compareTo(a.itemname));
      }
    } else if (columnindex == 2) {
      if (ascending) {
        datalist.sort((a, b) => a.chemicalname.compareTo(b.chemicalname));
      } else {
        datalist.sort((a, b) => b.chemicalname.compareTo(a.chemicalname));
      }
    } else if (columnindex == 3) {
      if (ascending) {
        datalist.sort((a, b) => a.companyname.compareTo(b.companyname));
      } else {
        datalist.sort((a, b) => b.companyname.compareTo(a.companyname));
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
          _itemCode = datalistselected[0].itemcode;
          _itemnamecontroller.text = datalistselected[0].itemname;
          _chemicalnamecontroller.text = datalistselected[0].chemicalname;
          _companynamecontroller.text = datalistselected[0].companyname;
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
        if (element.itemname.toLowerCase().contains(value.toLowerCase())) {
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
                      this.cusSearchBar = Text('Stock Item');
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
          _itemnamecontroller.text = '';
          _chemicalnamecontroller.text = '';
          _companynamecontroller.text = '';
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
    List<StockItemModel> listdata;
    if (datalistsearch.length > 0) {
      print('Success');
      listdata = datalistsearch;
    } else if (this.cusIcon.icon == Icons.clear) {
      print('Success / Null');
      listdata = datalistsearch;
      _loadingText = 'No data will be return';
    } else {
      print('Failed');
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
      return SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            sortColumnIndex: 0,
            showCheckboxColumn: true,
            sortAscending: _sort,
            columnSpacing: 17.0,
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
                  label: Text('Chemical'),
                  onSort: (columnindex, ascending) {
                    setState(() {
                      _sort = !_sort;
                    });
                    onSortColumn(columnindex, _sort);
                  }),
              DataColumn(
                  label: Text('Company'),
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
                          DataCell(Text(e.itemcode)),
                          DataCell(Text(e.itemname)),
                          DataCell(Text(e.chemicalname)),
                          DataCell(Text(e.companyname)),
                        ],
                        selected: datalistselected.contains(e),
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
                print('close button');
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
                  padding: EdgeInsets.all(5.0),
                  width: _screenWidth - 75,
                  child: TextFormField(
                    autofocus: true,
                    focusNode: _itemnameNode,
                    controller: _itemnamecontroller,
                    textInputAction: TextInputAction.next,
                    decoration: new InputDecoration(
                      contentPadding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                      filled: true,
                      fillColor: Colors.grey[100],
                      hintText: 'Enter item name...',
                      focusedBorder: OutlineInputBorder(
                        borderSide: new BorderSide(color: Colors.grey[300]),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: new BorderSide(color: Colors.grey[300]),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderSide: new BorderSide(color: Colors.grey[300]),
                      ),
                    ),
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter item name';
                      }
                      return null;
                    },
                    onFieldSubmitted: (String value) {
                      FocusScope.of(context).requestFocus(_chemicalnameNode);
                    },
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(5.0),
                  child: TextFormField(
                    focusNode: _chemicalnameNode,
                    controller: _chemicalnamecontroller,
                    textInputAction: TextInputAction.next,
                    decoration: new InputDecoration(
                      contentPadding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                      filled: true,
                      fillColor: Colors.grey[100],
                      hintText: 'Enter chemical name...',
                      focusedBorder: OutlineInputBorder(
                        borderSide: new BorderSide(color: Colors.grey[300]),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: new BorderSide(color: Colors.grey[300]),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderSide: new BorderSide(color: Colors.grey[300]),
                      ),
                    ),
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter chemical name';
                      }
                      return null;
                    },
                    onFieldSubmitted: (String value) {
                      FocusScope.of(context).requestFocus(_companynameNode);
                    },
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(5.0),
                  child: TextFormField(
                    focusNode: _companynameNode,
                    controller: _companynamecontroller,
                    textInputAction: TextInputAction.go,
                    decoration: new InputDecoration(
                      contentPadding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                      filled: true,
                      fillColor: Colors.grey[100],
                      hintText: 'Enter company name...',
                      focusedBorder: OutlineInputBorder(
                        borderSide: new BorderSide(color: Colors.grey[300]),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: new BorderSide(color: Colors.grey[300]),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderSide: new BorderSide(color: Colors.grey[300]),
                      ),
                    ),
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter company name';
                      }
                      return null;
                    },
                    onFieldSubmitted: (String value) {
                      if (_formKey.currentState.validate()) {
                        if (mode == 'insert') {
                          createItem(
                              _itemnamecontroller.text,
                              _chemicalnamecontroller.text,
                              _companynamecontroller.text);
                        } else if (mode == 'update') {
                          editItem(
                              _itemnamecontroller.text,
                              _chemicalnamecontroller.text,
                              _companynamecontroller.text);
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
                        if (mode == 'insert') {
                          createItem(
                              _itemnamecontroller.text,
                              _chemicalnamecontroller.text,
                              _companynamecontroller.text);
                        } else if (mode == 'update') {
                          editItem(
                              _itemnamecontroller.text,
                              _chemicalnamecontroller.text,
                              _companynamecontroller.text);
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
          Text("Would you like to delete '${datalistselected[0].itemname}' ?"),
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
            deleteItems(datalistselected[0].itemcode);
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
