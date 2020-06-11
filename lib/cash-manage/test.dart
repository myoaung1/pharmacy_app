import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pharmacyapp/custom-widget/widget.dart';
import 'package:pharmacyapp/model/model.cash-manage.dart';
import 'package:pharmacyapp/model/model.master.dart';

class ExpenseTest extends StatefulWidget {
  @override
  _ExpenseState createState() => _ExpenseState();
}

class _ExpenseState extends State<ExpenseTest> {
  final _numformatter = new NumberFormat("#,###");
  final _dateformatter = new DateFormat("dd-MMM-yyyy");

  Icon _cusIcon = Icon(Icons.search);
  Widget _cusSearchBar = Text('Expense');

  List<ExpenseModel> _datalist = [];
  List<ExpenseModel> _datalistselected = [];
  List<ExpenseModel> _datalistsearch = [];

  bool _isVisible = false;
  bool _sort;
  int _selectedMenu = 0;
  String _loadingText = 'Loading...';

  Future<void> getData() async {
    List data;
    _datalist.clear();
    _datalistselected.clear();
    _datalistsearch.clear();
    this._cusIcon = Icon(Icons.search);
    this._cusSearchBar = Text('Expense');
    _isVisible = false;
    var response = await http.get(
        Uri.encodeFull("http://192.168.43.28/api/expense/list"),
        headers: {"Accept": "application/json"});

    setState(() {
      data = json.decode(response.body);
      int count = data.length;
      for (int i = 0; i < count; i++) {
        ExpenseModel item = ExpenseModel(
            expenseid: data[i]["ExpenseID"],
            titleid: data[i]["TitleID"],
            titlename: data[i]["TitleName"],
            amount: double.parse(data[i]["Amount"].toString()),
            date: DateTime.parse(data[i]["Date"]),
            description: data[i]["Description"],
            username: data[i]["Username"]);
        _datalist.add(item);
      }
      print(_datalist[0].expenseid);
    });
  }

  Future<void> deleteItems(String id) async {
    final http.Response response = await http.post(
      'http://192.168.43.28/api/expense/delete?id=$id',
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

  void _onSortColumn(int columnindex, bool ascending) {
    if (columnindex == 0) {
      if (ascending) {
        _datalist.sort((a, b) => a.titlename.compareTo(b.titlename));
      } else {
        _datalist.sort((a, b) => b.titlename.compareTo(a.titlename));
      }
    } else if (columnindex == 1) {
      if (ascending) {
        _datalist.sort((a, b) => a.date.compareTo(b.date));
      } else {
        _datalist.sort((a, b) => b.date.compareTo(a.date));
      }
    } else if (columnindex == 3) {
      if (ascending) {
        _datalist.sort((a, b) => a.amount.compareTo(b.amount));
      } else {
        _datalist.sort((a, b) => b.amount.compareTo(a.amount));
      }
    } else if (columnindex == 4) {
      if (ascending) {
        _datalist.sort((a, b) => a.description.compareTo(b.description));
      } else {
        _datalist.sort((a, b) => b.description.compareTo(a.description));
      }
    } else if (columnindex == 5) {
      if (ascending) {
        _datalist.sort((a, b) => a.username.compareTo(b.username));
      } else {
        _datalist.sort((a, b) => b.username.compareTo(a.username));
      }
    }
  }

  void _searchItem(String value) async {
    setState(() {
      _datalistsearch.clear();
      _datalist.forEach((element) {
        if (element.titlename.toLowerCase().contains(value.toLowerCase())) {
          _datalistsearch.add(element);
        }
      });
      //getList(context);
    });
    print('List Count : ${_datalistsearch.length}');
  }

  void _onSelectedRow(bool selected, ExpenseModel item) async {
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
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditExpense(
                  expenseID: _datalistselected[0].expenseid,
                  titleID: _datalistselected[0].titleid.toString(),
                  amount: _datalistselected[0].amount.toString(),
                  description: _datalistselected[0].description,
                ),
              ));
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
    _sort = false;
    getData();
    print("Active Expense");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(60.0), // here the desired height
          child: AppBar(
            elevation: 0,
            titleSpacing: 0,
            backgroundColor: Colors.white,
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
                      this._cusSearchBar = Text('Shop');
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
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CreateExpense(),
              ));
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
      backgroundColor: Colors.white,
    );
  }

  Widget getList(BuildContext context) {
    List<ExpenseModel> listdata;
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
          mainAxisAlignment: MainAxisAlignment.center,
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
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: DataTable(
            sortColumnIndex: 0,
            showCheckboxColumn: true,
            sortAscending: _sort,
            columnSpacing: 20,
            columns: [
              DataColumn(
                  label: Text('Title'),
                  onSort: (columnindex, ascending) {
                    setState(() {
                      _sort = !_sort;
                    });
                    _onSortColumn(columnindex, _sort);
                  }),
              DataColumn(
                  label: Text('Date'),
                  onSort: (columnindex, ascending) {
                    setState(() {
                      _sort = !_sort;
                    });
                    _onSortColumn(columnindex, _sort);
                  }),
              DataColumn(
                  label: Text('Amount'),
                  onSort: (columnindex, ascending) {
                    setState(() {
                      _sort = !_sort;
                    });
                    _onSortColumn(columnindex, _sort);
                  }),
              DataColumn(
                  label: Text('Description'),
                  onSort: (columnindex, ascending) {
                    setState(() {
                      _sort = !_sort;
                    });
                    _onSortColumn(columnindex, _sort);
                  }),
              DataColumn(
                  label: Text('User'),
                  onSort: (columnindex, ascending) {
                    setState(() {
                      _sort = !_sort;
                    });
                    _onSortColumn(columnindex, _sort);
                  }),
            ],
            rows: listdata
                .map((e) => DataRow(
                cells: <DataCell>[
                  DataCell(Text(e.titlename.toString())),
                  DataCell(Text(_dateformatter.format(e.date))),
                  DataCell(Text(_numformatter.format(e.amount))),
                  DataCell(Text(e.description.toString())),
                  DataCell(Text(e.username.toString())),
                ],
                selected: _datalistselected.contains(e),
                onSelectChanged: (b) {
                  _onSelectedRow(b, e);
                }))
                .toList(),
          ),
        ),
      );
    }
  }

  Widget getConfirmationPopup(BuildContext context) {
    return AlertDialog(
      title: Text("Confirmation !!!"),
      content: Text(
          "Would you like to delete '${_datalistselected[0].titlename}' ?"),
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
            deleteItems(_datalistselected[0].expenseid.toString());
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}

class CreateExpense extends StatefulWidget {
  @override
  _CreateExpenseState createState() => _CreateExpenseState();
}

class _CreateExpenseState extends State<CreateExpense> {
  List<CashTitleModel> _cashList = [];
  List<DropdownMenuItem<CashTitleModel>> _dropdownitems = [];
  CashTitleModel _selectedCash;

  String _errorMessage = '';

  FocusNode _amountNode = new FocusNode();
  FocusNode _descriptionNode = new FocusNode();
  final _formKey = GlobalKey<FormState>();
  TextEditingController _amountcontroller = new TextEditingController();
  TextEditingController _descriptioncontroller = new TextEditingController();

  Future<void> createItems(
      int titleID, String amount, String description) async {
    var responsecode = await http.get(
        Uri.encodeFull("http://192.168.43.28/api/expense/getcode"),
        headers: {"Accept": "application/json"});
    String code = jsonDecode(responsecode.body);
    print(code);
    Map data = {
      'ExpenseID': code,
      'Date': DateTime.now().toString(),
      'TitleID': titleID.toString(),
      'Amount': amount,
      'Description': description,
    };
    print(data);
    final http.Response response = await http.post(
      'http://192.168.43.28/api/expense/insert',
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: data,
    );

    if (response.statusCode == 201) {
      setState(() {
        Navigator.pop(context);
      });
    } else {}

    print(responsecode.statusCode);
  }

  Future<void> _getCashList() async {
    var response = await http.get(
        Uri.encodeFull("http://192.168.43.28/api/cashtitle/list"),
        headers: {"Accept": "application/json"});

    setState(() {
      List data = json.decode(response.body);
      int count = data.length;
      for (int i = 0; i < count; i++) {
        CashTitleModel item = CashTitleModel(
          titleid: data[i]["TitleID"],
          titlename: data[i]["Title"].toString(),
        );
        _cashList.add(item);
      }

      _dropdownitems = _buildDropdownItem(_cashList);
      //_selectedCash = _dropdownitems[0].value;
    });
  }

  List<DropdownMenuItem<CashTitleModel>> _buildDropdownItem(List cashList) {
    List<DropdownMenuItem<CashTitleModel>> items = List();
    for (CashTitleModel item in _cashList) {
      items.add(DropdownMenuItem(
        child: Text(item.titlename),
        value: item,
      ));
    }
    return items;
  }

  void _onChangeDropDown(CashTitleModel item) {
    setState(() {
      _selectedCash = item;
    });
  }

  @override
  void initState() {
    _getCashList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(60.0), // here the desired height
          child: AppBar(
            elevation: 0,
            titleSpacing: 0,
            backgroundColor: Colors.white,
            title: Text('Create Expense'),
          )),
      body: Center(
        child: Container(
          decoration: _decoration(),
          padding: EdgeInsets.all(15),
          margin: EdgeInsets.all(10),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                dropdownMenu(),
                Padding(
                  padding: EdgeInsets.fromLTRB(10, 5, 0, 5),
                  child: Text(
                    _errorMessage,
                    style: TextStyle(color: Colors.red[600], fontSize: 12),
                  ),
                ),
                TextFormField(
                  focusNode: _amountNode,
                  controller: _amountcontroller,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.number,
                  decoration: new InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[100],
                    hintText: 'Enter amount name...',
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
                    FocusScope.of(context).requestFocus(_descriptionNode);
                  },
                ),
                SizedBox(
                  height: 10,
                ),
                TextFormField(
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.go,
                  focusNode: _descriptionNode,
                  controller: _descriptioncontroller,
                  decoration: new InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[100],
                    hintText: 'Enter description name...',
                    focusedBorder: OutlineInputBorder(
                      borderSide: new BorderSide(color: Colors.grey[300]),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: new BorderSide(color: Colors.grey[300]),
                    ),
                  ),
                  onFieldSubmitted: (String value) {},
                ),
                SizedBox(
                  height: 10,
                ),
                RaisedButton(
                  elevation: 1,
                  color: Colors.blueAccent,
                  onPressed: () {
                    if (_formKey.currentState.validate()) {
                      if (_selectedCash == null) {
                        setState(() {
                          _errorMessage = 'Please choose title';
                        });
                      } else {
                        _errorMessage = '';
                        createItems(
                            _selectedCash.titleid,
                            _amountcontroller.text,
                            _descriptioncontroller.text);
                      }
                      _formKey.currentState.save();
                    }
                  },
                  child: Text(
                    'Create',
                    style: TextStyle(color: Colors.white),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
      backgroundColor: Colors.grey[100],
    );
  }

  Decoration _decoration() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(5),
    boxShadow: [
      BoxShadow(
        color: Colors.grey[400].withOpacity(0.5),
        spreadRadius: 2,
        blurRadius: 5,
        offset: Offset(0, 2), // changes position of shadow
      ),
    ],
  );

  Widget dropdownMenu() {
    if (_cashList != null)
      return Container(
        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: Colors.grey[300], width: 1)),
        child: DropdownButton(
          onChanged: (e) => _onChangeDropDown(e),
          items: _dropdownitems,
          value: _selectedCash,
          hint: Text('Choose'),
          underline: null,
        ),
      );
    else {
      return Text('loading...');
    }
  }
}

class EditExpense extends StatefulWidget {
  final String expenseID;
  final String titleID;
  final String amount;
  final String description;

  EditExpense(
      {Key key,
        @required this.expenseID,
        @required this.titleID,
        @required this.amount,
        @required this.description})
      : super(key: key);

  @override
  _EditExpenseState createState() => _EditExpenseState();
}

class _EditExpenseState extends State<EditExpense> {
  List<CashTitleModel> _cashList = [];
  List<DropdownMenuItem<CashTitleModel>> _dropdownitems = [];
  CashTitleModel _selectedCash;

  String _errorMessage = '';

  FocusNode _amountNode = new FocusNode();
  FocusNode _descriptionNode = new FocusNode();
  final _formKey = GlobalKey<FormState>();
  TextEditingController _amountcontroller = new TextEditingController();
  TextEditingController _descriptioncontroller = new TextEditingController();

  Future<void> editItems(int titleID, String amount, String description) async {
    Map data = {
      'ExpenseID': widget.expenseID,
      'TitleID': titleID.toString(),
      'Description': description,
    };
    final http.Response response = await http.post(
      'http://192.168.43.28/api/expense/update',
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: data,
    );

    if (response.statusCode == 200) {
      setState(() {
        Navigator.pop(context);
      });
    } else {}

    print(response.statusCode);
  }

  Future<void> _getCashList() async {
    var response = await http.get(
        Uri.encodeFull("http://192.168.43.28/api/cashtitle/list"),
        headers: {"Accept": "application/json"});

    setState(() {
      List data = json.decode(response.body);
      int count = data.length;
      for (int i = 0; i < count; i++) {
        CashTitleModel item = CashTitleModel(
          titleid: data[i]["TitleID"],
          titlename: data[i]["Title"].toString(),
        );
        _cashList.add(item);
      }

      _dropdownitems = _buildDropdownItem(_cashList);
      _selectedCash = _cashList
          .where((element) => element.titleid == int.parse(widget.titleID)).single;
      //_selectedCash = _dropdownitems[0].value;
    });
  }

  List<DropdownMenuItem<CashTitleModel>> _buildDropdownItem(List cashList) {
    List<DropdownMenuItem<CashTitleModel>> items = List();
    for (CashTitleModel item in _cashList) {
      items.add(DropdownMenuItem(
        child: Text(item.titlename),
        value: item,
      ));
    }
    return items;
  }

  void _onChangeDropDown(CashTitleModel item) {
    setState(() {
      _selectedCash = item;
    });
  }

  @override
  void initState() {
    _getCashList();

    _amountcontroller.text = widget.amount;
    _descriptioncontroller.text = widget.description;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(60.0), // here the desired height
          child: AppBar(
            elevation: 0,
            titleSpacing: 0,
            backgroundColor: Colors.white,
            title: Text('Create Expense'),
          )),
      body: Center(
        child: Container(
          decoration: _decoration(),
          padding: EdgeInsets.all(15),
          margin: EdgeInsets.all(10),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                dropdownMenu(),
                Padding(
                  padding: EdgeInsets.fromLTRB(10, 5, 0, 5),
                  child: Text(
                    _errorMessage,
                    style: TextStyle(color: Colors.red[600], fontSize: 12),
                  ),
                ),
                TextFormField(
                  focusNode: _amountNode,
                  controller: _amountcontroller,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.number,
                  decoration: new InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[100],
                    hintText: 'Enter amount name...',
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
                    FocusScope.of(context).requestFocus(_descriptionNode);
                  },
                ),
                SizedBox(
                  height: 10,
                ),
                TextFormField(
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.go,
                  focusNode: _descriptionNode,
                  controller: _descriptioncontroller,
                  decoration: new InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[100],
                    hintText: 'Enter description name...',
                    focusedBorder: OutlineInputBorder(
                      borderSide: new BorderSide(color: Colors.grey[300]),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: new BorderSide(color: Colors.grey[300]),
                    ),
                  ),
                  onFieldSubmitted: (String value) {},
                ),
                SizedBox(
                  height: 10,
                ),
                RaisedButton(
                  elevation: 1,
                  color: Colors.blueAccent,
                  onPressed: () {
                    if (_formKey.currentState.validate()) {
                      if (_selectedCash == null) {
                        setState(() {
                          _errorMessage = 'Please choose title';
                        });
                      } else {
                        _errorMessage = '';
                        editItems(_selectedCash.titleid, _amountcontroller.text,
                            _descriptioncontroller.text);
                      }
                      _formKey.currentState.save();
                    }
                  },
                  child: Text(
                    'Edit',
                    style: TextStyle(color: Colors.white),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
      backgroundColor: Colors.grey[100],
    );
  }

  Decoration _decoration() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(5),
    boxShadow: [
      BoxShadow(
        color: Colors.grey[400].withOpacity(0.5),
        spreadRadius: 2,
        blurRadius: 5,
        offset: Offset(0, 2), // changes position of shadow
      ),
    ],
  );

  Widget dropdownMenu() {
    if (_cashList != null)
      return Container(
        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: Colors.grey[300], width: 1)),
        child: DropdownButton(
          onChanged: (e) => _onChangeDropDown(e),
          items: _dropdownitems,
          value: _selectedCash,
          hint: Text('Choose'),
          underline: null,
        ),
      );
    else {
      return Text('loading...');
    }
  }
}
