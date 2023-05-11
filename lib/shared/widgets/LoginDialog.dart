import 'package:flutter/material.dart';

class CustomLoginDialog extends StatelessWidget {
  final _formKey1 = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Custom Login'),
      content: Form(
        key: _formKey1,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
                // add custom login fields here
                ),
            ElevatedButton(
              onPressed: () {
                // perform custom login authentication
              },
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
