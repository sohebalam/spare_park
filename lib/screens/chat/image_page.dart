import 'package:flutter/material.dart';

class ImagePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Person Image'),
      ),
      body: Center(
        child: Image.asset(
          'assets/person.png',
          height: 200,
        ),
      ),
    );
  }
}
