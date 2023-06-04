import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sparepark/screens/crud/parking/edit_parking_space.dart';
import 'package:sparepark/screens/crud/parking/view_parking_space.dart';
import 'package:sparepark/shared/auth_service.dart';
import 'package:sparepark/shared/widgets/app_bar.dart';

class ParkingPage extends StatefulWidget {
  final String userId;

  ParkingPage({required this.userId});

  @override
  _ParkingPageState createState() => _ParkingPageState();
}

class _ParkingPageState extends State<ParkingPage> {
  late Stream<QuerySnapshot> _ParkingStream;
  final currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();

    _ParkingStream = FirebaseFirestore.instance
        .collection('parking_spaces')
        .where('u_id', isEqualTo: widget.userId)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final isLoggedInStream = authService.user!.map((user) => user != null);
    return Scaffold(
      appBar: CustomAppBar(
          title: 'Parking Details', isLoggedInStream: isLoggedInStream),
      body: StreamBuilder<QuerySnapshot>(
        stream: _ParkingStream,
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

          final Parking = snapshot.data!.docs;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView.builder(
              itemCount: Parking.length,
              itemBuilder: (BuildContext context, int index) {
                final parking = Parking[index];

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Address: ${parking['address']}'),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ViewParkingSpace(
                                      parking: parking,
                                      user: currentUser!,
                                    ),
                                  ),
                                );
                              },
                              child: Text('View'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditParkingSpace(
                                      parking: parking,
                                      user: currentUser!,
                                    ),
                                  ),
                                );
                              },
                              child: Text('Edit'),
                            ),
                            TextButton(
                              onPressed: () {
                                print('Address: ${parking['p_id']}');
                                String parkingId = parking.id;
                                // _deleteParking(context, parkingId);
                                showDeleteDialog(context, parkingId);
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

  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  void _deleteParking(BuildContext context, String parkingId) async {
    try {
      // Delete the parking space from the 'parking_spaces' collection
      await FirebaseFirestore.instance
          .collection('parking_spaces')
          .doc(parkingId)
          .delete();

      // Delete the bookings associated with the parking space
      await FirebaseFirestore.instance
          .collection('bookings')
          .where('p_id', isEqualTo: parkingId)
          .get()
          .then((querySnapshot) {
        querySnapshot.docs.forEach((bookingDoc) async {
          String bookingId = bookingDoc.id;

          // Delete the reviews connected to the booking
          await FirebaseFirestore.instance
              .collection('reviews')
              .where('b_id', isEqualTo: bookingId)
              .get()
              .then((querySnapshot) {
            querySnapshot.docs.forEach((reviewDoc) {
              reviewDoc.reference.delete();
            });
          });

          // Delete the booking
          bookingDoc.reference.delete();
        });
      });

      // Show a success message
      _scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text('Parking deleted successfully'),
        ),
      );
    } catch (error) {
      // Show an error message
      _scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text('Error deleting the Parking: $error'),
        ),
      );
    }
  }

  void showDeleteDialog(BuildContext context, String parkingId) async {
    final bool canDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Booking'),
          content: Text('Are you sure you want to delete?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // User chose to cancel
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // User chose to delete
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );

    if (canDelete != null && canDelete) {
      _deleteParking(context, parkingId);
    }
  }
}
