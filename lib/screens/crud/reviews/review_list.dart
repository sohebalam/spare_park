import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sparepark/services/auth_service.dart';
import 'package:sparepark/shared/widgets/app_bar.dart';

class ReviewListPage extends StatefulWidget {
  final String userId;

  ReviewListPage({required this.userId});

  @override
  _ReviewListPageState createState() => _ReviewListPageState();
}

class _ReviewListPageState extends State<ReviewListPage> {
  late Stream<QuerySnapshot> _ReviewStream;

  @override
  void initState() {
    super.initState();

    _ReviewStream = FirebaseFirestore.instance
        .collection('reviews')
        // .where('u_id', isEqualTo: widget.userId)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final isLoggedInStream = authService.user!.map((user) => user != null);
    return Scaffold(
      appBar:
          CustomAppBar(title: 'Reviews', isLoggedInStream: isLoggedInStream),
      body: StreamBuilder<QuerySnapshot>(
        stream: _ReviewStream,
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

          final Review = snapshot.data!.docs;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView.builder(
              itemCount: Review.length,
              itemBuilder: (BuildContext context, int index) {
                final review = Review[index];

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Description: ${review['description']}'),
                        // Text('User id: ${Review['u_id']}'),
                        // Text('Review Space id: ${Review['p_id']}'),
                        // Text('Review Date: ${Review['reg_date']}'),
                        // Text('Review Start: ${Review['start_date_time']}'),
                        // Text('Review End: ${Review['end_date_time']}'),
                        // Text('Total Price: ${Review['b_total']}'),
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
                            // TextButton(
                            //   onPressed: () {
                            //     // TODO: Implement add review action
                            //   },
                            //   child: Text('Add Review'),
                            // ),
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
