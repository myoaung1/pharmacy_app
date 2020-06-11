import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pharmacyapp/cash-manage/cash-manage.expense.dart';
import 'package:pharmacyapp/main.dart';
import 'package:pharmacyapp/master-data/master-data.shop.dart';
import 'package:pharmacyapp/master-data/master-data.stock-item.dart';
import 'package:pharmacyapp/master-data/master-data.supplier.dart';

class MenuWidget extends StatefulWidget {
  @override
  _MenuWidgetState createState() => _MenuWidgetState();
}

class _MenuWidgetState extends State<MenuWidget> {
  int _selectedIndex = 2;

  void _onItemTapped(int index) {
    setState(() {
      if (index == 0) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MyHomePage(),
            ));
      } else if (index == 1) {}
      _selectedIndex = index;
    });
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
            title: Text(
              'Menu',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            leading: Icon(Icons.assignment),
          )),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: <Widget>[
            Container(
              color: Colors.blueAccent,
              padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
              child: ListTile(
                contentPadding: EdgeInsets.fromLTRB(15, 20, 30, 20),
                title: Text(
                  'Administrator',
                  style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5),
                ),
                leading: Icon(
                  Icons.account_circle,
                  size: 60,
                  color: Colors.white,
                ),
                subtitle: Text(
                  'Post : Admin',
                  style: TextStyle(color: Colors.white70),
                ),
                trailing: Icon(
                  Icons.info_outline,
                  color: Colors.white70,
                  size: 30,
                ),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                // Master Data Menu
                Container(
                  margin: EdgeInsets.fromLTRB(10, 15, 10, 0),
                  decoration: decoration(),
                  child: ExpansionTile(
                    title: Text('Master Data'),
                    leading: Icon(Icons.widgets),
                    children: <Widget>[
                      Divider(
                        height: 0,
                      ),
                      // Shop Sub Menu
                      ListTile(
                        title: Text(
                          'Shop',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        contentPadding: EdgeInsets.only(left: 20.0),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ShopMaster(),
                              ));
                        },
                      ),
                      Divider(
                        height: 0,
                      ),
                      // Supplier Sub Menu
                      ListTile(
                        title: Text(
                          'Supplier',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        contentPadding: EdgeInsets.only(left: 20.0),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Supplier(),
                              ));
                        },
                      ),
                      Divider(
                        height: 0,
                      ),
                      // Cash Title Sub Menu
                      ListTile(
                        title: Text(
                          'Cash Title',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        contentPadding: EdgeInsets.only(left: 20.0),
                        onTap: () {},
                      ),
                      Divider(
                        height: 0,
                      ),
                      // Stock Item Sub Menu
                      ListTile(
                        title: Text(
                          'Stock Item',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        contentPadding: EdgeInsets.only(left: 20.0),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => StockItem(),
                              ));
                        },
                      ),
                      Divider(
                        height: 0,
                      ),
                      // Packet Type Sub Menu
                      ListTile(
                        title: Text(
                          'Packet Type',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        contentPadding: EdgeInsets.only(left: 20.0),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => StockItem(),
                              ));
                        },
                      ),
                      Divider(
                        height: 0,
                      ),
                    ],
                  ),
                ),
                // Sale Menu
                Container(
                  margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
                  decoration: decoration(),
                  child: ExpansionTile(
                    title: Text('Sale'),
                    leading: Icon(Icons.add_shopping_cart),
                    children: <Widget>[
                      Divider(
                        height: 0,
                      ),
                      // New Voucher Sub Menu
                      ListTile(
                        title: Text(
                          'New Voucher',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        contentPadding: EdgeInsets.only(left: 20.0),
                        onTap: () {},
                      ),
                      Divider(
                        height: 0,
                      ),
                      // Voucher List Sub Menu
                      ListTile(
                        title: Text(
                          'Daily Voucher List',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        contentPadding: EdgeInsets.only(left: 20.0),
                        onTap: () {},
                      ),
                      Divider(
                        height: 0,
                      ),
                    ],
                  ),
                ),
                // Purchase Menu
                Container(
                  margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
                  decoration: decoration(),
                  child: ExpansionTile(
                    title: Text('Purchase'),
                    leading: Icon(Icons.shopping_basket),
                    children: <Widget>[
                      Divider(
                        height: 0,
                      ),
                      // Shop Sub Menu
                      ListTile(
                        title: Text(
                          'New Voucher',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        contentPadding: EdgeInsets.only(left: 20.0),
                        onTap: () {},
                      ),
                      Divider(
                        height: 0,
                      ),
                    ],
                  ),
                ),
                // Stock Manage
                Container(
                  margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
                  decoration: decoration(),
                  child: ExpansionTile(
                    title: Text('Stock Manage'),
                    leading: Icon(Icons.apps),
                    children: <Widget>[
                      Divider(
                        height: 0,
                      ),
                      // Main Stock Sub Menu
                      ListTile(
                        title: Text(
                          'Main Stock',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        contentPadding: EdgeInsets.only(left: 20.0),
                        onTap: () {},
                      ),
                      Divider(
                        height: 0,
                      ),
                      // Pharmacy Stock Sub Menu
                      ListTile(
                        title: Text(
                          'Pharmacy Stock',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        contentPadding: EdgeInsets.only(left: 20.0),
                        onTap: () {},
                      ),
                      Divider(
                        height: 0,
                      ),
                    ],
                  ),
                ),
                // Cash Manage Menu
                Container(
                  margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
                  decoration: decoration(),
                  child: ExpansionTile(
                    title: Text('Cash Manage'),
                    leading: Icon(Icons.monetization_on),
                    children: <Widget>[
                      Divider(
                        height: 0,
                      ),
                      // Expense Sub Menu
                      ListTile(
                        title: Text(
                          'Expense',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        contentPadding: EdgeInsets.only(left: 20.0),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Expense(),
                              ));
                        },
                      ),
                      Divider(
                        height: 0,
                      ),
                      // Patty Sub Menu
                      ListTile(
                        title: Text(
                          'Patty Cash',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        contentPadding: EdgeInsets.only(left: 20.0),
                        onTap: () {},
                      ),
                      Divider(
                        height: 0,
                      ),
                      // Patty Sub Menu
                      ListTile(
                        title: Text(
                          'Other Income',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        contentPadding: EdgeInsets.only(left: 20.0),
                        onTap: () {},
                      ),
                      Divider(
                        height: 0,
                      ),
                      // Cash In Out Sub Menu
                      ListTile(
                        title: Text(
                          'Cash In/Out',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        contentPadding: EdgeInsets.only(left: 20.0),
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
                // Report Menu
                Container(
                  margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
                  decoration: decoration(),
                  child: ExpansionTile(
                    title: Text('Report'),
                    leading: Icon(Icons.multiline_chart),
                    children: <Widget>[
                      Divider(),
                      // Expense Sub Menu
                      ListTile(
                        title: Text(
                          'Expense',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        contentPadding: EdgeInsets.only(left: 20.0),
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
                // Setting Menu
                Container(
                  margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
                  decoration: decoration(),
                  child: ListTile(
                    leading: Icon(Icons.settings),
                    title: Text('Settings'),
                  ),
                ),
                // Logout Menu
                Container(
                  margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
                  decoration: decoration(),
                  child: ListTile(
                    leading: Icon(Icons.exit_to_app),
                    title: Text('Log Out'),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.dashboard,
              size: 20,
            ),
            title: Text(
              'Dashboard',
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.add_shopping_cart,
              size: 20,
            ),
            title: Text('Sale'),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.menu,
              size: 20,
            ),
            title: Text('Menu'),
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.indigoAccent,
        backgroundColor: Colors.white,
        elevation: 0,
        onTap: _onItemTapped,
      ),
      backgroundColor: Colors.grey[200],
    );
  }

  Decoration decoration() {
    return BoxDecoration(
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
  }
}
