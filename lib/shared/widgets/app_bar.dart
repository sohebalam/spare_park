import 'package:flutter/material.dart';
import 'package:sparepark/shared/style/contstants.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool isLoggedIn;

  const CustomAppBar({Key? key, required this.title, required this.isLoggedIn})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Padding(
        padding: EdgeInsets.only(left: isLoggedIn ? 110 : 111),
        child: Text(title),
      ),
      backgroundColor: Constants().primaryColor,
      actions: isLoggedIn
          ? <Widget>[
              IconButton(
                icon: Icon(Icons.logout),
                onPressed: () {
                  // TODO: Implement logout functionality
                },
              ),
            ]
          : null,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
