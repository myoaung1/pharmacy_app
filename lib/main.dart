import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pharmacyapp/menu.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo 1',
      theme: ThemeData(primaryColor: Colors.white),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      if (index == 1) {
      } else if (index == 2) {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MenuWidget(),
            ));
      }
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
              'Dashboard',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            leading: Icon(Icons.dashboard),
          )),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
        scrollDirection: Axis.vertical,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.fromLTRB(15, 10, 10, 0),
              child: Text(
                'Summary Voucher',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black54),
                textAlign: TextAlign.start,
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey[300].withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 2), // changes position of shadow
                  ),
                ],
              ),
              child: ListTile(
                leading: Icon(
                  Icons.shopping_cart,
                  color: Colors.green,
                  size: 40,
                ),
                title: Text(
                  'Sale Voucher',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black),
                ),
                subtitle: Text(
                  'voucher count: 2',
                  style: TextStyle(color: Colors.black54, fontSize: 12),
                ),
                contentPadding: EdgeInsets.fromLTRB(20.0, 5.0, 0, 5.0),
                onTap: () {},
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(15, 10, 10, 0),
              child: Text(
                'Stock Manage',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black54),
                textAlign: TextAlign.start,
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey[300].withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 2), // changes position of shadow
                  ),
                ],
              ),
              child: Column(
                children: <Widget>[
                  ListTile(
                    title: Text('Main Stock'),
                    leading: Icon(
                      Icons.store,
                      color: Colors.indigo,
                    ),
                    trailing: Icon(
                      Icons.arrow_right,
                      color: Colors.black54,
                    ),
                  ),
                  Divider(),
                  ListTile(
                    title: Text('Pharmacy Stock'),
                    leading: Icon(
                      Icons.add_box,
                      color: Colors.amber,
                    ),
                    trailing: Icon(
                      Icons.arrow_right,
                      color: Colors.black54,
                    ),
                  ),
                  Divider(),
                  ListTile(
                    title: Text('Damage Stock'),
                    leading: Icon(
                      Icons.broken_image,
                      color: Colors.brown[300],
                    ),
                    trailing: Icon(
                      Icons.arrow_right,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(15, 10, 10, 0),
              child: Text(
                'Quick Report',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black54),
                textAlign: TextAlign.start,
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey[300].withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 2), // changes position of shadow
                  ),
                ],
              ),
              child: Column(
                children: <Widget>[
                  ListTile(
                    title: Text('Daily Report'),
                    leading: Icon(
                      Icons.show_chart,
                      color: Colors.indigo,
                    ),
                    trailing: Icon(
                      Icons.arrow_right,
                      color: Colors.black54,
                    ),
                  ),
                  Divider(),
                  ListTile(
                    title: Text('Cash Summary Report'),
                    leading: Icon(
                      Icons.show_chart,
                      color: Colors.amber,
                    ),
                    trailing: Icon(
                      Icons.arrow_right,
                      color: Colors.black54,
                    ),
                  ),
                  Divider(),
                  ListTile(
                    title: Text('Sale Report'),
                    leading: Icon(
                      Icons.show_chart,
                      color: Colors.brown[300],
                    ),
                    trailing: Icon(
                      Icons.arrow_right,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
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
            title: Text('Dashboard'),
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
    );
  }
}
