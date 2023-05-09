import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sparepark/shared/functions.dart';

// class ParkingSpacesPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Parking Spaces'),
//       ),
//       body: StreamBuilder<QuerySnapshot>(
//         stream:
//             FirebaseFirestore.instance.collection('parking_spaces').snapshots(),
//         builder: (context, snapshot) {
//           if (snapshot.hasData) {
//             return ListView.builder(
//               itemCount: snapshot.data?.docs.length,
//               itemBuilder: (context, index) {
//                 DocumentSnapshot parkingSpace =
//                     snapshot.data?.docs[index] as DocumentSnapshot<Object?>;
//                 return ListTile(
//                   title: Text(parkingSpace['address']),
//                   // You can add more widgets here to display other fields
//                 );
//               },
//             );
//           } else if (snapshot.hasError) {
//             return Center(
//               child: Text('Something went wrong'),
//             );
//           } else {
//             return Center(
//               child: CircularProgressIndicator(),
//             );
//           }
//         },
//       ),
//     );
//   }
// }
class ParkingSpacesPage extends StatelessWidget {
  final double latitude;
  final double longitude;

  ParkingSpacesPage({required this.latitude, required this.longitude});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Parking Spaces'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance.collection('parking_spaces').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<DocumentSnapshot<Object?>>? parkingSpaces = snapshot.data?.docs
                .map((e) => e as DocumentSnapshot<Object?>)
                .toList();
            List<DocumentSnapshot> closestParkingSpaces =
                findClosestParkingSpaces(latitude, longitude, parkingSpaces!);

            return ListView.builder(
              itemCount: closestParkingSpaces.length,
              itemBuilder: (context, index) {
                DocumentSnapshot parkingSpace = closestParkingSpaces[index];
                return ListTile(
                  title: Text(parkingSpace['address']),
                  // You can add more widgets here to display other fields
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Something went wrong'),
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
