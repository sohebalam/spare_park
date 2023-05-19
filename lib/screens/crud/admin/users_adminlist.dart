import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:sparepark/screens/crud/reviews/edit_review.dart';
import 'package:sparepark/screens/crud/reviews/view_review.dart';
import 'package:sparepark/screens/crud/user/admin_profile.dart';
import 'package:sparepark/services/auth_service.dart';
import 'package:sparepark/shared/widgets/app_bar.dart';

class UsersAdminListPage extends StatefulWidget {
  UsersAdminListPage();

  @override
  _UsersAdminListPageState createState() => _UsersAdminListPageState();
}

class _UsersAdminListPageState extends State<UsersAdminListPage> {
  late Stream<QuerySnapshot> _usersStream;

  @override
  void initState() {
    super.initState();

    _usersStream = FirebaseFirestore.instance.collection('users').snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final isLoggedInStream = authService.user!.map((user) => user != null);

    return Scaffold(
      key: _scaffoldMessengerKey,
      appBar: CustomAppBar(
        title: 'Users',
        isLoggedInStream: isLoggedInStream,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _usersStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          final users = snapshot.data!.docs;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView.builder(
              itemCount: users.length,
              itemBuilder: (BuildContext context, int index) {
                final user = users[index];

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('User ID: ${user.id}'),
                        Text('Name: ${user['name']}'),
                        Text('Email: ${user['email']}'),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        AdminUserProfilePage(userId: user.id),
                                  ),
                                );
                              },
                              child: Text('Edit'),
                            ),
                            TextButton(
                              onPressed: () {
                                String userId = user.id;
                                _deleteUser(context, userId);
                              },
                              child: Text('Delete'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

void _deleteUser(BuildContext context, String userId) async {
  try {
    // Delete the user from the 'users' collection
    await FirebaseFirestore.instance.collection('users').doc(userId).delete();

    // Show a success message
    _scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text('User deleted successfully'),
      ),
    );
  } catch (error) {
    // Show an error message
    _scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text('Error deleting the user: $error'),
      ),
    );
  }
}
