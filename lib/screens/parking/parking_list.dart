import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ParkingPage extends StatefulWidget {
  final String userId;

  ParkingPage({required this.userId});

  @override
  _ParkingPageState createState() => _ParkingPageState();
}

class _ParkingPageState extends State<ParkingPage> {
  late Stream<QuerySnapshot> _ParkingStream;

  @override
  void initState() {
    super.initState();

    _ParkingStream = FirebaseFirestore.instance
        .collection('parking_spaces')
        // .where('u_id', isEqualTo: widget.userId)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Parking Details'),
      ),
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
                        // Text('User id: ${parking['u_id']}'),
                        // Text('Parking Space id: ${parking['p_id']}'),
                        // Text('parking Date: ${parking['reg_date']}'),
                        // Text('parking Start: ${parking['start_date_time']}'),
                        // Text('parking End: ${parking['end_date_time']}'),
                        // Text('Total Price: ${parking['b_total']}'),
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
