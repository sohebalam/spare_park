import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sparepark/screens/chat/chat_list.dart';
import 'package:sparepark/screens/crud/bookings/booking_list.dart';
import 'package:sparepark/screens/crud/parking/parking_list.dart';
import 'package:sparepark/screens/crud/parking/register_car_parking.dart';
import 'package:sparepark/screens/crud/reviews/review_list.dart';
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
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      // Add a ListView to the drawer. This ensures the user can scroll
      // through the options in the drawer if there isn't enough vertical
      // space to fit everything.
      child: ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Constants().primaryColor,
            ),
            child: currentUser != null
                ? Text('${currentUser!.displayName}')
                : null,
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
                return Container(); // Return an empty container if there are no parking spaces
              }
              return ListTile(
                title: const Text('My Bookings'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          BookingsPage(userId: currentUser!.uid.toString()),
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
                return Container(); // Return an empty container if there are no parking spaces
              }
              return ListTile(
                title: const Text('My Parking Spaces'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ParkingPage(userId: currentUser!.uid.toString()),
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
                return Container(); // Return an empty container if there are no parking spaces
              }
              return ListTile(
                title: const Text('My Reviews'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ReviewListPage(userId: currentUser!.uid.toString()),
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
                return Container(); // Return an empty container if there are no parking spaces
              }
              return ListTile(
                title: const Text('Admin'),
                onTap: () {
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (context) =>
                  //         // ADMIN PAGES
                  //         ReviewListPage(userId: currentUser!.uid.toString()),
                  //   ),
                  // );
                },
              );
            },
          ),
          ListTile(
            title: const Text('Logout'),
            onTap: () {
              // Logout the user
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
