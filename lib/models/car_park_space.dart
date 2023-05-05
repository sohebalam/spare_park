import 'package:cloud_firestore/cloud_firestore.dart';

class CarParkSpaceModel {
  String p_id;
  String postcode;
  String address;
  double hourlyRate;
  int spaces;
  String description;
  String? phoneNumber;
  double latitude;
  double longitude;

  CarParkSpaceModel({
    required this.p_id,
    required this.postcode,
    required this.address,
    required this.hourlyRate,
    required this.spaces,
    required this.description,
    this.phoneNumber,
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toMap() {
    return {
      'p_id': p_id,
      'postcode': postcode,
      'address': address,
      'hourlyRate': hourlyRate,
      'spaces': spaces,
      'description': description,
      'phoneNumber': phoneNumber ?? "",
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  static CarParkSpaceModel fromMap(Map<String, dynamic> map) {
    return CarParkSpaceModel(
      p_id: map['p_id'],
      postcode: map['postcode'],
      address: map['address'] ?? "",
      hourlyRate: map['hourlyRate'] ?? 0.00,
      spaces: map['spaces'] ?? 0,
      description: map['description'] ?? "",
      phoneNumber: map['phoneNumber'],
      latitude: map['latitude'] ?? 0.00,
      longitude: map['longitude'] ?? 0.00,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'p_id': p_id,
      'postcode': postcode,
      'address': address,
      'hourlyRate': hourlyRate,
      'spaces': spaces,
      'description': description,
      'phoneNumber': phoneNumber ?? "",
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  Future<bool> isAvailable(
      String p_id, DateTime startDateTime, DateTime endDateTime) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('bookings')
        .where('p_id', isEqualTo: p_id)
        .where('start_date_time', isLessThanOrEqualTo: endDateTime)
        .where('end_date_time', isGreaterThanOrEqualTo: startDateTime)
        .get();
    return snapshot.docs.isEmpty;
  }

  static fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> e) {}
}
