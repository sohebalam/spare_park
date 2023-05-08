import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:sparepark/screens/crud/parking/register_car_parking.dart';

class MapHomePage extends StatefulWidget {
  @override
  _MapHomePageState createState() => _MapHomePageState();
}

class _MapHomePageState extends State<MapHomePage> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Map Home Page'),
      ),
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            ListTile(
              title: Text('Register Parking Space'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RegisterParkingSpace(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Text('Map'),
      ),
    );
  }
}
