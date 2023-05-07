import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sparepark/models/booking_model.dart';
import 'package:sparepark/models/car_park_space.dart';
import 'package:geolocator/geolocator.dart';

class DB_CarPark {
  static Stream<List<CarParkSpaceModel>> read() {
    final userCollection =
        FirebaseFirestore.instance.collection("parking_spaces");
    return userCollection.snapshots().map((querySnapshot) => querySnapshot.docs
        .map((e) => CarParkSpaceModel.fromMap(e.data() as Map<String, dynamic>))
        .toList());

    // .map((e) => CarParkSpaceModel.fromMap(e as Map<String, dynamic>))
    // .toList());
  }

  static Future<void> create(CarParkSpaceModel cps) async {
    final carpark_spaceCollection =
        FirebaseFirestore.instance.collection("parking_spaces");

    final cpsid = carpark_spaceCollection.doc().id;
    final docRef = carpark_spaceCollection.doc(cpsid);

    final newCPS = CarParkSpaceModel(
      p_id: cpsid,
      address: cps.address,
      postcode: cps.postcode,
      hourlyRate: cps.hourlyRate,
      // spaces: cps.spaces,
      description: cps.description,
      phoneNumber: cps.phoneNumber,
      latitude: cps.latitude,
      longitude: cps.longitude,
      p_image: cps.p_image,
    ).toJson();

    try {
      await docRef.set(newCPS);
    } catch (e) {
      print("some error occured $e");
    }
  }

  Future<List<CarParkSpaceModel>> getNearestSpaces({
    double? latitude,
    double? longitude,
    required DateTime startdatetime,
    required DateTime enddatetime,
  }) async {
    final carParkSpaces = await read().first;
    final position = Position(
      latitude: latitude!,
      longitude: longitude!,
      altitude: 0,
      heading: 0,
      speed: 0,
      speedAccuracy: 0,
      accuracy: 0,
      timestamp: null,
    );

    final distanceThreshold = 10000.0;
    final filteredSpaces = carParkSpaces.where((space) {
      final spacePosition = Position(
        latitude: space.latitude,
        longitude: space.longitude,
        altitude: 0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0,
        accuracy: 0,
        timestamp: null,
      );
      final distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        spacePosition.latitude,
        spacePosition.longitude,
      );
      return distance <= distanceThreshold;
    }).toList();
    filteredSpaces.sort((a, b) {
      final aPosition = Position(
        latitude: a.latitude,
        longitude: a.longitude,
        altitude: 0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0,
        accuracy: 0,
        timestamp: null,
      );
      final bPosition = Position(
        latitude: b.latitude,
        longitude: b.longitude,
        altitude: 0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0,
        accuracy: 0,
        timestamp: null,
      );
      final aDistance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        aPosition.latitude,
        aPosition.longitude,
      );
      final bDistance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        bPosition.latitude,
        bPosition.longitude,
      );
      return aDistance.compareTo(bDistance);
    });

    // Get all the bookings between the startdatetime and enddatetime
    final bookings = await FirebaseFirestore.instance
        .collection('bookings')
        .where('start_date_time', isLessThanOrEqualTo: enddatetime)
        .where('end_date_time', isGreaterThanOrEqualTo: startdatetime)
        .get();

    // final bookings = await FirebaseFirestore.instance
    //     .collection('bookings')
    //     .where('start_date_time', isLessThanOrEqualTo: enddatetime)
    //     .get();

    final filteredBookings = bookings.docs
        .map((doc) => BookingModel.fromSnapshot(doc))
        .where((booking) => booking.end_date_time!.isAfter(startdatetime))
        .toList();

    // Filter out any booked spaces between the enddatetime and startdatetime
    final nearestSpaces = filteredSpaces
        .where((space) {
          final spaceIsAvailable =
              bookings.docs.every((booking) => booking['p_id'] != space.p_id);
          return spaceIsAvailable;
        })
        .take(10)
        .toList();

    return nearestSpaces;
  }
}

class DB_ParkingSpaces {
  static final _firestore = FirebaseFirestore.instance;

  static readDocument(String cpsId) async {
    try {
      final documentSnapshot =
          await _firestore.collection('parkingSpaces').doc(cpsId).get();

      if (documentSnapshot.exists) {
        final data = documentSnapshot.data();
        return data;
      } else {
        print('Document does not exist');
        return null;
      }
    } catch (e) {
      print('Error retrieving document: $e');
      return null;
    }
  }
}
