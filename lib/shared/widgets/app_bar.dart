import 'package:flutter/material.dart';
import 'package:sparepark/shared/functions.dart';
import 'package:sparepark/shared/style/contstants.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool isLoggedIn;

  const CustomAppBar({Key? key, required this.title, required this.isLoggedIn})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: isLoggedIn
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
                // SizedBox(width: 10.0),
                // Icon(
                //   Icons.account_circle,
                //   color: Constants().primaryColor,
                // ),
              ],
            ),
      centerTitle: true,
      backgroundColor: Constants().primaryColor,
      actions: isLoggedIn
          ? <Widget>[
              IconButton(
                icon: Icon(Icons.logout),
                onPressed: () {
                  disconnect();
                },
              ),
            ]
          : null,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
