import 'package:flutter/material.dart';

class ChatUserPage extends StatelessWidget {
  final String u_id;

  const ChatUserPage({Key? key, required this.u_id}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print(u_id);
    return Scaffold(
      appBar: AppBar(
        title: Text('User Page'),
      ),
      body: Center(
        child: Text('User ID: $u_id'),
      ),
    );
  }
}
