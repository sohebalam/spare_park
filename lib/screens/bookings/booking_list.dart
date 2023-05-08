import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: Text('Booking Details'),
      ),
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

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Booking id: ${booking['b_id']}'),
                        Text('User id: ${booking['u_id']}'),
                        Text('Parking Space id: ${booking['p_id']}'),
                        Text('Booking Date: ${booking['reg_date']}'),
                        Text('Booking Start: ${booking['start_date_time']}'),
                        Text('Booking End: ${booking['end_date_time']}'),
                        Text('Total Price: ${booking['b_total']}'),
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
                                // TODO: Implement add review action
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
