import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sparepark/models/booking_model.dart';
import 'package:sparepark/models/car_park_space.dart';
import 'dart:math' as math;
import 'package:geolocator/geolocator.dart';

class DB_Booking {
  static Stream<List<BookingModel>> read() {
    final userCollection = FirebaseFirestore.instance.collection("bookings");
    return userCollection.snapshots().map((querySnapshot) =>
        querySnapshot.docs.map((e) => BookingModel.fromSnapshot(e)).toList());
  }

  static Future create(BookingModel book) async {
    final carpark_spaceCollection =
        FirebaseFirestore.instance.collection("bookings");

    final bookid = carpark_spaceCollection.doc().id;
    final docRef = carpark_spaceCollection.doc(bookid);

    final booking = BookingModel(
      p_id: book.p_id,
      b_total: book.b_total,
      end_date_time: book.end_date_time,
      start_date_time: book.start_date_time,
      reg_date: book.reg_date,
    ).toJson();

    try {
      await docRef.set(booking);
    } catch (e) {
      print("some error occured $e");
    }
  }

  // Future<List<BookingModel>> getNearestSpaces({
  //   double? latitude,
  //   double? longitude,
  // }) async {
  //   final Bookings = await read().first;
  //   final position = Position(
  //     latitude: latitude!,
  //     longitude: longitude!,
  //     altitude: 0,
  //     heading: 0,
  //     speed: 0,
  //     speedAccuracy: 0,
  //     accuracy: 0,
  //     timestamp: null,
  //   );

  //   final distanceThreshold = 10000.0;
  //   final filteredSpaces = Bookings.where((space) {
  //     final spacePosition = Position(
  //       latitude: space.latitude,
  //       longitude: space.longitude,
  //       altitude: 0,
  //       heading: 0,
  //       speed: 0,
  //       speedAccuracy: 0,
  //       accuracy: 0,
  //       timestamp: null,
  //     );
  //     final distance = Geolocator.distanceBetween(
  //       position.latitude,
  //       position.longitude,
  //       spacePosition.latitude,
  //       spacePosition.longitude,
  //     );
  //     return distance <= distanceThreshold;
  //   }).toList();
  //   filteredSpaces.sort((a, b) {
  //     final aPosition = Position(
  //       latitude: a.latitude,
  //       longitude: a.longitude,
  //       altitude: 0,
  //       heading: 0,
  //       speed: 0,
  //       speedAccuracy: 0,
  //       accuracy: 0,
  //       timestamp: null,
  //     );
  //     final bPosition = Position(
  //       latitude: b.latitude,
  //       longitude: b.longitude,
  //       altitude: 0,
  //       heading: 0,
  //       speed: 0,
  //       speedAccuracy: 0,
  //       accuracy: 0,
  //       timestamp: null,
  //     );
  //     final aDistance = Geolocator.distanceBetween(
  //       position.latitude,
  //       position.longitude,
  //       aPosition.latitude,
  //       aPosition.longitude,
  //     );
  //     final bDistance = Geolocator.distanceBetween(
  //       position.latitude,
  //       position.longitude,
  //       bPosition.latitude,
  //       bPosition.longitude,
  //     );
  //     return aDistance.compareTo(bDistance);
  //   });
  //   final nearestSpaces = filteredSpaces.take(10).toList();
  //   return nearestSpaces;
  // }
}
