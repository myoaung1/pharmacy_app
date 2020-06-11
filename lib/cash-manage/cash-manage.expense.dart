import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:pharmacyapp/model/model.cash-manage.dart';
import 'package:pharmacyapp/model/model.master.dart';
import 'package:pharmacyapp/style/custom-style.dart';

class MenuItem {
  const MenuItem(this.name, this.icon);
  final String name;
  final Icon icon;
}

class SubMenu {
  const SubMenu({this.title, this.icon});

  final String title;
  final IconData icon;
}

const List<SubMenu> choices = const <SubMenu>[
  const SubMenu(title: 'Search', icon: Icons.search),
  const SubMenu(title: 'Sort By Title', icon: null),
  const SubMenu(title: 'Sort By Date', icon: null),
  const SubMenu(title: 'Sort By Amount', icon: null),
];

class Expense extends StatefulWidget {
  @override
  _ExpenseState createState() => _ExpenseState();
}

class _ExpenseState extends State<Expense> {
  final _dateformatter = new DateFormat("dd/MMM/yyyy");
  final _numformatter = new NumberFormat("#,###");
  List<ExpenseModel> _listitem = [];
  List<ExpenseModel> _datalistsearch = [];
  bool _sortDate = true;
  bool _sortTitle = true;
  bool _sortAmount = true;
  Icon _cusIcon = Icon(Icons.search);
  Widget _cusSearchBar = Text('Expense');

  Future<void> _getList() async {
    _listitem.clear();
    var response = await http.get(
        Uri.encodeFull("http://192.168.43.28/api/expense/list"),
        headers: {"Accept": "application/json"});
    setState(() {
      var data = jsonDecode(response.body);
      for (int i = 0; i < data.length; i++) {
        ExpenseModel item = ExpenseModel(
            expenseid: data[i]["ExpenseID"],
            date: DateTime.parse(data[i]["Date"].toString()),
            titleid: data[i]["TitleID"],
            titlename: data[i]["TitleName"],
            amount: data[i]["Amount"],
            description: data[i]["Description"],
            username: data[i]["Username"]);
        _listitem.add(item);
      }
    });
  }

  void _select(SubMenu choice) {
    setState(() {
      if (choice.title == "Sort By Date") {
        if (!_sortDate) {
          _listitem.sort((a, b) => a.date.compareTo(b.date));
          _sortDate = true;
        } else {
          _listitem.sort((a, b) => b.date.compareTo(a.date));
          _sortDate = false;
        }
      } else if (choice.title == "Sort By Title") {
        if (!_sortTitle) {
          _listitem.sort((a, b) => a.titlename.compareTo(b.titlename));
          _sortTitle = true;
        } else {
          _listitem.sort((a, b) => b.titlename.compareTo(a.titlename));
          _sortTitle = false;
        }
      } else if (choice.title == "Sort By Amount") {
        if (!_sortAmount) {
          _listitem.sort((a, b) => a.amount.compareTo(b.amount));
          _sortAmount = true;
        } else {
          _listitem.sort((a, b) => b.amount.compareTo(a.amount));
          _sortAmount = false;
        }
      }
    });
  }

  Future<void> _onRefresh() async {
    setState(() {
      _getList();
    });
  }

  void _searchItem(String value) async {
    setState(() {
      _datalistsearch.clear();
      _listitem.forEach((element) {
        if (element.titlename.toLowerCase().contains(value.toLowerCase())) {
          _datalistsearch.add(element);
        }
      });
      _listView(context);
    });
    print('List Count : ${_datalistsearch.length}');
  }

  @override
  void initState() {
    _getList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: _appbar(context),
        body: _listView(context),
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
        ));
  }

  Widget _appbar(BuildContext context) => AppBar(
        elevation: 2,
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
                  this._cusIcon = Icon(Icons.search);
                  this._cusSearchBar = Text('Expense');
                }
              });
            },
          ),
          PopupMenuButton<SubMenu>(
            onSelected: _select,
            itemBuilder: (BuildContext context) {
              return choices.skip(1).map((SubMenu choice) {
                return PopupMenuItem<SubMenu>(
                  value: choice,
                  child: Text(choice.title),
                );
              }).toList();
            },
          ),
        ],
      );

  Widget _listView(BuildContext context) {
    List<ExpenseModel> data = [];
    if (_datalistsearch.length > 0) {
      data = _datalistsearch;
    } else {
      data = _listitem;
    }

    return Container(
      padding: EdgeInsets.only(top: 5),
      child: RefreshIndicator(
        backgroundColor: Colors.white,
        color: Colors.black87,
        onRefresh: _onRefresh,
        child: Stack(
          children: <Widget>[
            ListView.builder(
                itemCount: data.length,
                itemBuilder: (BuildContext context, int index) {
                  return _card(index, data[index]);
                })
          ],
        ),
      ),
    );
  }

  Widget _card(int index, ExpenseModel model) {
    return Padding(
      padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
      child: Container(
        decoration: decoration(),
        child: ExpansionTile(
          title: Text(
            '${model.titlename} - ${_numformatter.format(model.amount)}',
            style: TextStyle(
                color: Colors.green[900], fontWeight: FontWeight.w500),
          ),
          subtitle: Text(
            'Create : ${_dateformatter.format(model.date)}',
            style: TextStyle(fontSize: 11, color: Colors.black54),
          ),
          children: <Widget>[
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.fromLTRB(15, 15, 15, 15),
                  color: Colors.grey[100],
                  child: Text(
                    model.description == null ? 'N/A' : model.description,
                    style: TextStyle(fontSize: 12),
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(15, 5, 15, 5),
                  color: Colors.grey[200],
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Expanded(
                        flex: 0,
                        child: Icon(
                          Icons.person_outline,
                          size: 18,
                          color: Colors.black54,
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          model.username == null
                              ? 'null'
                              : " ${model.username}",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 0,
                        child: SizedBox(
                          height: 20,
                          width: 70,
                          child: FlatButton.icon(
                            padding: EdgeInsets.zero,
                            icon: Icon(
                              Icons.delete,
                              size: 16,
                              color: Colors.red[300],
                            ),
                            label: Text(
                              "Delete",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.red[300],
                              ),
                            ),
                            onPressed: () {},
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
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
    final _screendHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(60.0), // here the desired height
          child: AppBar(
            elevation: 0,
            titleSpacing: 0,
            backgroundColor: Colors.white,
            title: Text('Create Expense'),
          )),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(top: _screendHeight / 10),
        scrollDirection: Axis.vertical,
        child: Container(
          decoration: decoration(),
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
