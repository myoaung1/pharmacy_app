import 'package:flutter/material.dart';

class Expense extends StatefulWidget {
  @override
  _ExpenseState createState() => _ExpenseState();
}

class _ExpenseState extends State<Expense> {
  @override
  Widget build(BuildContext context) {
    var appBar2 = AppBar(
      elevation: 0,
      titleSpacing: 0,
      backgroundColor: Colors.grey[0],
      title: Text(
        'Expense',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
      ),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.search),
          onPressed: () {},
        )
      ],
    );
    return Scaffold(
        appBar: PreferredSize(
            preferredSize: Size.fromHeight(60.0), // here the desired height
            child: appBar2));
  }
}
