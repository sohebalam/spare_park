import 'package:cloud_firestore/cloud_firestore.dart';

class ParkingSpace {
  String p_id;
  String postcode;
  String address;
  double hourlyRate;
  int spaces;
  String description;
  String? phoneNumber;
  double latitude;
  double longitude;

  ParkingSpace({
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

  static ParkingSpace fromMap(Map<String, dynamic> map) {
    return ParkingSpace(
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
}
