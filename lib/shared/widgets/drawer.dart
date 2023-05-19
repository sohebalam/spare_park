import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sparepark/screens/auth/auth_screen.dart';
import 'package:sparepark/screens/chat/chat_list.dart';
import 'package:sparepark/screens/crud/admin/booking_adminlist.dart';
import 'package:sparepark/screens/crud/admin/parking_adminlist.dart';
import 'package:sparepark/screens/crud/admin/review_adminlist.dart';
import 'package:sparepark/screens/crud/admin/users_adminlist.dart';
import 'package:sparepark/screens/crud/bookings/booking_list.dart';
import 'package:sparepark/screens/crud/parking/parking_list.dart';
import 'package:sparepark/screens/crud/parking/register_car_parking.dart';
import 'package:sparepark/screens/crud/reviews/review_list.dart';
import 'package:sparepark/screens/crud/user/profile.dart';
import 'package:sparepark/services/auth_service.dart';
import 'package:sparepark/shared/style/contstants.dart';
// import 'package:your_app_name/utils/constants.dart';
// import 'package:your_app_name/views/register_parking_space.dart';

class AppDrawer extends StatefulWidget {
  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  // Define messageCount and currentUser at the class level
  int messageCount = 0;
  User? currentUser;

  late Stream<QuerySnapshot> _bookingsStream;
  late Stream<QuerySnapshot> _ParkingStream;
  late Stream<QuerySnapshot> _ReviewStream;
  String userName = '';
  late Stream<bool> isLoggedInStream;

  Future<void> getMessageCount() async {
    print("Finding messages for current user");

    if (currentUser == null) {
      print("Current user is null");
      return;
    }

    Stream<int> messageCountStream() {
      return FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .collection('messages')
          .snapshots()
          .map((snapshot) => snapshot.docs.length);
    }

    messageCountStream().listen((count) {
      setState(() {
        messageCount = count;
      });
    });
  }

  @override
  void initState() {
    super.initState();

    // Get the current user when the widget is first created
    currentUser = FirebaseAuth.instance.currentUser;
    // Call getMessageCount to get message count for current user
    getMessageCount();
    _bookingsStream = FirebaseFirestore.instance
        .collection('bookings')
        .where('u_id', isEqualTo: currentUser?.uid)
        .snapshots();
    _ParkingStream = FirebaseFirestore.instance
        .collection('parking_spaces')
        .where('u_id', isEqualTo: currentUser?.uid)
        .snapshots();
    _ReviewStream = FirebaseFirestore.instance
        .collection('reviews')
        .where('u_id', isEqualTo: currentUser?.uid)
        .snapshots();

    if (currentUser != null) {
      retrieveUserName();
    }
  }

  Stream<DocumentSnapshot> getUserStream(String userId) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .snapshots();
  }

  Future<void> retrieveUserName() async {
    if (currentUser!.providerData[0].providerId == 'password') {
      // Custom user login, retrieve the user document
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .get();

      // Get the value of the 'name' field from the user document
      final userData = userDoc.data() as Map<String, dynamic>?;
      setState(() {
        userName = userData?['name'] ?? '';
      });
    } else {
      // Social login, use 'displayName' field
      setState(() {
        userName = currentUser!.displayName ?? '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final isLoggedInStream = authService.user!.map((user) => user != null);

    return Drawer(
      child: ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Constants().primaryColor,
            ),
            child: StreamBuilder<bool>(
              stream: isLoggedInStream,
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data!) {
                  return Text('$userName');
                }
                return Text('');
              },
            ),
          ),
          StreamBuilder<bool>(
            stream: isLoggedInStream,
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data!) {
                return const Text('');
              }
              return ListTile(
                title: const Text('Login'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AuthScreen(
                        prior_page: 'Drawer',
                      ),
                    ),
                  );
                },
              );
            },
          ),
          ListTile(
            title: const Text('Register Parking Space'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RegisterParkingSpace(),
                ),
              );
            },
          ),
          StreamBuilder<bool>(
            stream: isLoggedInStream,
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data!) {
                return Column(
                  children: [
                    ListTile(
                      title: Row(
                        children: [
                          const Text('Profile'),
                          SizedBox(width: 8),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UserProfilePage(),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      title: Row(
                        children: [
                          const Text('Messages'),
                          SizedBox(width: 8),
                          MessageAvatar(messageCount: messageCount),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatList(),
                          ),
                        );
                      },
                    ),
                    StreamBuilder<QuerySnapshot>(
                      stream: _bookingsStream,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return Container();
                        }
                        return ListTile(
                          title: const Text('My Bookings'),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BookingsPage(
                                  userId: currentUser!.uid.toString(),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                    StreamBuilder<QuerySnapshot>(
                      stream: _ParkingStream,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return Container();
                        }
                        return ListTile(
                          title: const Text('My Parking Spaces'),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ParkingPage(
                                  userId: currentUser!.uid.toString(),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                    StreamBuilder<QuerySnapshot>(
                      stream: _ReviewStream,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return Container();
                        }
                        return ListTile(
                          title: const Text('My Reviews'),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ReviewListPage(
                                  userId: currentUser!.uid.toString(),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                    StreamBuilder<DocumentSnapshot>(
                      stream: currentUser != null
                          ? getUserStream(currentUser!.uid)
                          : null,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData || !snapshot.data!.exists) {
                          return Container();
                        }
                        final userDoc = snapshot.data!;
                        final userData =
                            userDoc.data() as Map<String, dynamic>?;
                        final isUserAdmin = userData?['isAdmin'] ?? false;

                        if (isUserAdmin) {
                          return Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.grey,
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                            margin: EdgeInsets.only(
                              left: 16.0,
                              right: 16.0,
                              top: 8.0,
                            ),
                            child: Column(
                              children: [
                                Padding(
                                  padding: EdgeInsets.fromLTRB(0, 15, 0, 0),
                                  child: Center(
                                    child: Text(
                                      'Admin',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                                ListTile(
                                  title: const Text('Users List'),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            UsersAdminListPage(),
                                      ),
                                    );
                                  },
                                ),
                                ListTile(
                                  title: const Text('Parking Spaces List'),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ParkingAdminListPage(),
                                      ),
                                    );
                                  },
                                ),
                                ListTile(
                                  title: const Text('Bookings List'),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            BookingAdminListPage(),
                                      ),
                                    );
                                  },
                                ),
                                ListTile(
                                  title: const Text('Reviews List'),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ReviewAdminListPage(),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          );
                        } else {
                          return Container(); // User is not an admin, return an empty container
                        }
                      },
                    ),
                  ],
                );
              }
              return Container();
            },
          ),
        ],
      ),
    );
  }
}

class MessageAvatar extends StatelessWidget {
  final int messageCount;

  const MessageAvatar({required this.messageCount});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 8),
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Constants().primaryColor,
          ),
          padding: EdgeInsets.all(5),
          child: Text(
            '$messageCount',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
