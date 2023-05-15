import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sparepark/screens/crud/reviews/create_review.dart';
import 'package:sparepark/services/auth_service.dart';
import 'package:sparepark/shared/widgets/app_bar.dart';

class BookingsPage extends StatefulWidget {
  final String userId;

  BookingsPage({required this.userId});

  @override
  _BookingsPageState createState() => _BookingsPageState();
}

class _BookingsPageState extends State<BookingsPage> {
  late Stream<QuerySnapshot> _bookingsStream;

  @override
  void initState() {
    super.initState();

    _bookingsStream = FirebaseFirestore.instance
        .collection('bookings')
        .where('u_id', isEqualTo: widget.userId)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final isLoggedInStream = authService.user!.map((user) => user != null);
    return Scaffold(
      appBar:
          CustomAppBar(title: 'Bookings', isLoggedInStream: isLoggedInStream),
      body: StreamBuilder<QuerySnapshot>(
        stream: _bookingsStream,
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

          final bookings = snapshot.data!.docs;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView.builder(
              itemCount: bookings.length,
              itemBuilder: (BuildContext context, int index) {
                final booking = bookings[index];
                final bookingDate = DateFormat('HH:mm a dd MMM yyyy')
                    .format(booking['reg_date'].toDate());
                final bookingStart = DateFormat('HH:mm a dd MMM yyyy')
                    .format(booking['start_date_time'].toDate());
                final bookingEnd = DateFormat('HH:mm a dd MMM yyyy')
                    .format(booking['end_date_time'].toDate());

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Text('Booking id: ${booking['b_id']}'),
                        // Text('User id: ${booking['u_id']}'),
                        // Text('Parking Space id: ${booking['p_id']}'),
                        Text('Booked Date: $bookingDate'),
                        Text('Booking Start: $bookingStart'),
                        Text('Booking End: $bookingEnd'),
                        Text('Total Price: £${booking['b_total']}'),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {
                                // TODO: Implement view action
                              },
                              child: Text('View'),
                            ),
                            TextButton(
                              onPressed: () {
                                // TODO: Implement edit action
                              },
                              child: Text('Edit'),
                            ),
                            TextButton(
                              onPressed: () {
                                // TODO: Implement delete action
                              },
                              child: Text('Delete'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ReviewPage(
                                      b_id: booking['b_id'],
                                    ),
                                  ),
                                );
                              },
                              child: Text('Add Review'),
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
