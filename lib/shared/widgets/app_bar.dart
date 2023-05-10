import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sparepark/services/auth_service.dart';
import 'package:sparepark/shared/functions.dart';
import 'package:sparepark/shared/style/contstants.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  // final Stream<bool> isLoggedInStream;

  CustomAppBar({
    Key? key,
    required this.title,
    required Stream<bool> isLoggedInStream,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final isLoggedInStream = authService.user?.map((user) => user != null);
    return StreamBuilder<bool>(
      stream: isLoggedInStream,
      initialData: false,
      builder: (context, snapshot) {
        return AppBar(
          title: snapshot.data == true
              ? Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                      ),
                    ),
                  ],
                ),
          centerTitle: true,
          backgroundColor: Constants().primaryColor,
          actions: snapshot.data == true
              ? <Widget>[
                  IconButton(
                    icon: Icon(Icons.logout),
                    onPressed: () {
                      authService.disconnect();
                    },
                  ),
                ]
              : null,
        );
      },
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
