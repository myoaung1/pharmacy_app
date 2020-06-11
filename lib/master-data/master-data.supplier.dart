import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:pharmacyapp/custom-widget/widget.dart';
import 'package:pharmacyapp/model/model.master.dart';
import 'package:intl/intl.dart';

class Supplier extends StatefulWidget {
  @override
  _SupplierState createState() => _SupplierState();
}

class _SupplierState extends State<Supplier> {
  final _numformatter = new NumberFormat("#,###");
  final _dateformatter = new DateFormat("dd-MMM-yyyy");

  Icon cusIcon = Icon(Icons.search);
  Widget cusSearchBar = Text('Supplier');

  List<SupplierModel> _datalist = [];
  List<SupplierModel> _datalistselected = [];
  List<SupplierModel> _datalistsearch = [];

  bool _isVisible = false;
  bool _sort;
  int _selectedMenu = 0;
  String _supplierId = '';
  String _loadingText = 'Loading...';

  FocusNode _companyNode = new FocusNode();
  FocusNode _contactnameNode = new FocusNode();
  FocusNode _addressNode = new FocusNode();
  FocusNode _phoneNode = new FocusNode();
  FocusNode _balanceNode = new FocusNode();

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _companycontroller = TextEditingController();
  final TextEditingController _contactnamecontroller = TextEditingController();
  final TextEditingController _addresscontroller = TextEditingController();
  final TextEditingController _phonecontroller = TextEditingController();
  final TextEditingController _balancecontroller = TextEditingController();

  Future<void> getData() async {
    List data;
    _datalist.clear();
    _datalistselected.clear();
    _datalistsearch.clear();
    this.cusIcon = Icon(Icons.search);
    this.cusSearchBar = Text('Supplier');
    _isVisible = false;
    var response = await http.get(
        Uri.encodeFull("http://192.168.43.28/api/supplier/list"),
        headers: {"Accept": "application/json"});

    setState(() {
      data = json.decode(response.body);
      int count = data.length;
      for (int i = 0; i < count; i++) {
        SupplierModel item = SupplierModel(
          supplierid: data[i]["SupplierID"],
          company: data[i]["Company"],
          contactname: data[i]["ContactName"].toString(),
          address: data[i]["Address"].toString(),
          phone: data[i]["Phone"].toString(),
          balance: data[i]["Balance"] == null
              ? 0
              : double.parse(data[i]["Balance"].toString()).toInt(),
          updatedate: data[i]["UpdateDate"] == null
              ? null
              : DateTime.parse(data[i]["UpdateDate"]),
        );
        _datalist.add(item);
      }
    });
  }

  Future<void> createItems(String company, String contactname, String address,
      String phone, String balance) async {
    final http.Response responsecode = await http.get(
      'http://192.168.43.28/api/supplier/getcode',
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );

    Map data = {
      'SupplierID': json.decode(responsecode.body),
      'Company': company,
      'ContactName': contactname,
      'Address': address,
      'Phone': phone,
      'Balance': balance,
    };

    final http.Response response = await http.post(
      'http://192.168.43.28/api/supplier/insert',
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: data,
    );

    if (response.statusCode == 201) {
      setState(() {
        getData();
      });
      _companycontroller.text = '';
      _contactnamecontroller.text = '';
      _addresscontroller.text = '';
      _phonecontroller.text = '';
      _balancecontroller.text = '';
    } else {
      print(response.body);
    }
  }

  Future<void> editItems(String company, String contactname, String address,
      String phone, String balance) async {
    Map data = {
      'SupplierID': _supplierId,
      'Company': company,
      'ContactName': contactname,
      'Address': address,
      'Phone': phone,
      'Balance': balance,
      'UpdateDate': DateTime.now().toString(),
    };

    final http.Response response = await http.post(
      'http://192.168.43.28/api/supplier/update',
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: data,
    );

    if (response.statusCode == 200) {
      setState(() {
        getData();
      });
      _companycontroller.text = '';
      _contactnamecontroller.text = '';
      _addresscontroller.text = '';
      _phonecontroller.text = '';
      _balancecontroller.text = '';
    } else {
      print(response.statusCode);
    }
  }

  Future<void> deleteItems(String id) async {
    final http.Response response = await http.post(
      'http://192.168.43.28/api/supplier/delete?id=$id',
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

  void _searchItem(String value) async {
    setState(() {
      _datalistsearch.clear();
      _datalist.forEach((element) {
        if (element.company.toLowerCase().contains(value.toLowerCase())) {
          _datalistsearch.add(element);
        }
      });
      getList(context);
    });
    print('List Count : ${_datalistsearch.length}');
  }

  onSortColumn(int columnindex, bool ascending) {
    if (columnindex == 0) {
      if (ascending) {
        _datalist.sort((a, b) => a.supplierid.compareTo(b.supplierid));
      } else {
        _datalist.sort((a, b) => b.supplierid.compareTo(a.supplierid));
      }
    } else if (columnindex == 1) {
      if (ascending) {
        _datalist.sort((a, b) => a.company.compareTo(b.company));
      } else {
        _datalist.sort((a, b) => b.company.compareTo(a.company));
      }
    } else if (columnindex == 2) {
      if (ascending) {
        _datalist.sort((a, b) => a.contactname.compareTo(b.contactname));
      } else {
        _datalist.sort((a, b) => b.contactname.compareTo(a.contactname));
      }
    } else if (columnindex == 3) {
      if (ascending) {
        _datalist.sort((a, b) => a.address.compareTo(b.address));
      } else {
        _datalist.sort((a, b) => b.address.compareTo(a.address));
      }
    } else if (columnindex == 4) {
      if (ascending) {
        _datalist.sort((a, b) => a.phone.compareTo(b.phone));
      } else {
        _datalist.sort((a, b) => b.phone.compareTo(a.phone));
      }
    } else if (columnindex == 5) {
      if (ascending) {
        _datalist.sort((a, b) => a.balance.compareTo(b.balance));
      } else {
        _datalist.sort((a, b) => b.balance.compareTo(a.balance));
      }
    }
  }

  onSelectedRow(bool selected, SupplierModel item) async {
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
          _supplierId = _datalistselected[0].supplierid;
          _companycontroller.text = _datalistselected[0].company;
          _contactnamecontroller.text = _datalistselected[0].contactname;
          _addresscontroller.text = _datalistselected[0].address;
          _phonecontroller.text = _datalistselected[0].phone;
          _balancecontroller.text = _datalistselected[0].balance.toString();
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
                      this.cusSearchBar = Text('Supplier');
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
          _companycontroller.text = '';
          _contactnamecontroller.text = '';
          _addresscontroller.text = '';
          _phonecontroller.text = '';
          _balancecontroller.text = '';
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
    List<SupplierModel> listdata;
    if (_datalistsearch.length > 0) {
      print('Success');
      listdata = _datalistsearch;
    } else if (this.cusIcon.icon == Icons.clear) {
      print('Success / Null');
      listdata = _datalistsearch;
      _loadingText = 'No data will be return';
    } else {
      listdata = _datalist;
      print(listdata.length);
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
            columnSpacing: 20,
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
                  label: Text('Company'),
                  onSort: (columnindex, ascending) {
                    setState(() {
                      _sort = !_sort;
                    });
                    onSortColumn(columnindex, _sort);
                  }),
              DataColumn(
                  label: Text('Contact Name'),
                  onSort: (columnindex, ascending) {
                    setState(() {
                      _sort = !_sort;
                    });
                    onSortColumn(columnindex, _sort);
                  }),
              DataColumn(
                  label: Text('Address'),
                  onSort: (columnindex, ascending) {
                    setState(() {
                      _sort = !_sort;
                    });
                    onSortColumn(columnindex, _sort);
                  }),
              DataColumn(
                  label: Text('Phone'),
                  onSort: (columnindex, ascending) {
                    setState(() {
                      _sort = !_sort;
                    });
                    onSortColumn(columnindex, _sort);
                  }),
              DataColumn(
                  label: Text('Balance'),
                  onSort: (columnindex, ascending) {
                    setState(() {
                      _sort = !_sort;
                    });
                    onSortColumn(columnindex, _sort);
                  }),
              DataColumn(
                  label: Text('Update Date'),
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
                          DataCell(Text(e.supplierid)),
                          DataCell(Text(e.company)),
                          DataCell(Text(e.contactname)),
                          DataCell(Text(e.address)),
                          DataCell(Text(e.phone)),
                          DataCell(Text(e.balance == null
                              ? 'N/A'
                              : _numformatter.format(e.balance))),
                          DataCell(Text(e.updatedate == null
                              ? 'N/A'
                              : _dateformatter.format(e.updatedate))),
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

    return SingleChildScrollView(
      padding: EdgeInsets.only(top: 50),
      scrollDirection: Axis.vertical,
      child: AlertDialog(
        insetPadding: EdgeInsets.only(top: 50),
        content: new Container(
          padding: EdgeInsets.all(10),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(10.0),
                  width: _screenWidth - 75,
                  child: TextFormField(
                    focusNode: _companyNode,
                    autofocus: true,
                    controller: _companycontroller,
                    textInputAction: TextInputAction.next,
                    decoration: new InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[100],
                      hintText: 'Enter company name...',
                      focusedBorder: OutlineInputBorder(
                        borderSide: new BorderSide(color: Colors.grey[300]),
                      ),
                      enabledBorder: OutlineInputBorder(
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
                      FocusScope.of(context).requestFocus(_contactnameNode);
                    },
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(10.0),
                  child: TextFormField(
                    focusNode: _contactnameNode,
                    controller: _contactnamecontroller,
                    textInputAction: TextInputAction.next,
                    decoration: new InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[100],
                      hintText: 'Enter contact name...',
                      focusedBorder: OutlineInputBorder(
                        borderSide: new BorderSide(color: Colors.grey[300]),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: new BorderSide(color: Colors.grey[300]),
                      ),
                    ),
                    onFieldSubmitted: (String value) {
                      FocusScope.of(context).requestFocus(_addressNode);
                    },
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(10.0),
                  child: TextFormField(
                    focusNode: _addressNode,
                    controller: _addresscontroller,
                    textInputAction: TextInputAction.next,
                    decoration: new InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[100],
                      hintText: 'Enter address...',
                      focusedBorder: OutlineInputBorder(
                        borderSide: new BorderSide(color: Colors.grey[300]),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: new BorderSide(color: Colors.grey[300]),
                      ),
                    ),
                    onFieldSubmitted: (String value) {
                      FocusScope.of(context).requestFocus(_phoneNode);
                    },
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(10.0),
                  child: TextFormField(
                    focusNode: _phoneNode,
                    controller: _phonecontroller,
                    textInputAction: TextInputAction.next,
                    decoration: new InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[100],
                      hintText: 'Enter phone...',
                      focusedBorder: OutlineInputBorder(
                        borderSide: new BorderSide(color: Colors.grey[300]),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: new BorderSide(color: Colors.grey[300]),
                      ),
                    ),
                    onFieldSubmitted: (String value) {
                      FocusScope.of(context).requestFocus(_balanceNode);
                    },
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(10.0),
                  child: TextFormField(
                    focusNode: _balanceNode,
                    controller: _balancecontroller,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.go,
                    decoration: new InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[100],
                      hintText: 'Enter balance name...',
                      focusedBorder: OutlineInputBorder(
                        borderSide: new BorderSide(color: Colors.grey[300]),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: new BorderSide(color: Colors.grey[300]),
                      ),
                    ),
                    onFieldSubmitted: (String value) {
                      if (_formKey.currentState.validate()) {
                        if (mode == "insert") {
                          createItems(
                              _companycontroller.text,
                              _contactnamecontroller.text,
                              _addresscontroller.text,
                              _phonecontroller.text,
                              _balancecontroller.text);
                        } else if (mode == "update") {
                          editItems(
                              _companycontroller.text,
                              _contactnamecontroller.text,
                              _addresscontroller.text,
                              _phonecontroller.text,
                              _balancecontroller.text);
                        }
                        _formKey.currentState.save();
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(10, 5, 10, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      RaisedButton(
                        child: Text(
                          'Cancel',
                          style: TextStyle(color: Colors.black54),
                        ),
                        color: Colors.white,
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      RaisedButton(
                        child: Text(
                          buttonText,
                          style: TextStyle(color: Colors.white),
                        ),
                        color: Colors.blue,
                        onPressed: () {
                          if (_formKey.currentState.validate()) {
                            if (mode == "insert") {
                              createItems(
                                  _companycontroller.text,
                                  _contactnamecontroller.text,
                                  _addresscontroller.text,
                                  _phonecontroller.text,
                                  _balancecontroller.text);
                            } else if (mode == "update") {
                              editItems(
                                  _companycontroller.text,
                                  _contactnamecontroller.text,
                                  _addresscontroller.text,
                                  _phonecontroller.text,
                                  _balancecontroller.text);
                            }
                            _formKey.currentState.save();
                            Navigator.of(context).pop();
                          }
                        },
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
        contentPadding: EdgeInsets.all(0.0),
      ),
    );
  }

  Widget getConfirmationPopup(BuildContext context) {
    return AlertDialog(
      title: Text("Confirmation !!!"),
      content:
          Text("Would you like to delete '${_datalistselected[0].company}' ?"),
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
            deleteItems(_datalistselected[0].supplierid.toString());
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
