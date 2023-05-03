import 'package:cloud_firestore/cloud_firestore.dart';

class CarParkSpaceModel {
  String? p_id;
  String address;
  String postcode;
  double hourlyRate;
  double spaces;
  String description;
  String? phoneNumber;
  double latitude;
  double longitude;

  CarParkSpaceModel({
    this.p_id,
    required this.address,
    required this.postcode,
    required this.hourlyRate,
    required this.spaces,
    required this.description,
    this.phoneNumber,
    required this.latitude,
    required this.longitude,
  });

  factory CarParkSpaceModel.fromSnapshot(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return CarParkSpaceModel(
      p_id: snapshot['p_id'],
      address: snapshot['address'],
      postcode: snapshot['postcode'],
      hourlyRate: snapshot['hourlyRate'],
      spaces: snapshot['spaces'],
      description: snapshot['description'],
      phoneNumber: snapshot['phoneNumber'],
      latitude: snapshot['latitude'],
      longitude: snapshot['longitude'],
    );
  }

  Map<String, dynamic> toJson() => {
        'cpsId': p_id,
        'address': address,
        'postcode': postcode,
        'hourlyRate': hourlyRate,
        'spaces': spaces,
        'description': description,
        'phoneNumber': phoneNumber ?? "",
        'latitude': latitude,
        'longitude': longitude,
      };
}
