import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sparepark/services/auth_service.dart';
import 'package:sparepark/shared/widgets/app_bar.dart';

class ReviewItem extends StatefulWidget {
  final String reviewId;

  ReviewItem({required this.reviewId, required bookingId, required parkingId});

  @override
  _ReviewItemState createState() => _ReviewItemState();
}

class _ReviewItemState extends State<ReviewItem> {
  late Future<DocumentSnapshot> _reviewFuture;
  late Future<DocumentSnapshot> _bookingFuture;
  late Future<DocumentSnapshot> _parkingSpaceFuture;

  @override
  void initState() {
    super.initState();

    _reviewFuture = FirebaseFirestore.instance
        .collection('reviews')
        .doc(widget.reviewId)
        .get();
    print('_reviewFuture ${_reviewFuture}');

    _bookingFuture = _reviewFuture.then((reviewSnapshot) {
      return FirebaseFirestore.instance
          .collection('bookings')
          .doc(reviewSnapshot['b_id'])
          .get();
    });
    print('_bookingFuture ${_bookingFuture}');

    _parkingSpaceFuture = _bookingFuture.then((bookingSnapshot) {
      return FirebaseFirestore.instance
          .collection('parking_spaces')
          .doc(bookingSnapshot['p_id'])
          .get();
    });
    print(_parkingSpaceFuture);
    print('_parkingSpaceFuture ${_parkingSpaceFuture}');
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final isLoggedInStream = authService.user!.map((user) => user != null);
    return Scaffold(
      appBar: CustomAppBar(
          title: 'Review Details', isLoggedInStream: isLoggedInStream),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder(
          future: Future.wait([
            _reviewFuture,
            _bookingFuture,
            _parkingSpaceFuture,
          ]),
          builder: (BuildContext context,
              AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }

            final reviewSnapshot = snapshot.data![0];
            final bookingSnapshot = snapshot.data![1];
            final parkingSpaceSnapshot = snapshot.data![2];

            final bookingStart = DateFormat('HH:mm a dd MMM yyyy')
                .format(bookingSnapshot['start_date_time'].toDate());
            final bookingEnd = DateFormat('HH:mm a dd MMM yyyy')
                .format(bookingSnapshot['end_date_time'].toDate());

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    'Parking Space Address: ${parkingSpaceSnapshot['address']}'),
                Text('Booking start time and date: ${bookingStart}'),
                Text('Booking end time and date: ${bookingEnd}'),
                Text('Review Description: ${reviewSnapshot['description']}'),
                Text('Review Rating: ${reviewSnapshot['rating']}'),
                Text(
                    'Review Safety Rating: ${reviewSnapshot['safety_rating']}'),
              ],
            );
          },
        ),
      ),
    );
  }
}
