import 'package:cloud_firestore/cloud_firestore.dart';

class CarParkSpaceModel {
  // String? id;
  // String address;
  // String postcode;
  // double hourlyRate;
  // int spaces;
  // String description;
  // String? phoneNumber;
  // double latitude;
  // double longitude;

  // CarParkSpaceModel({
  //   this.id,
  //   required this.address,
  //   required this.postcode,
  //   required this.hourlyRate,
  //   required this.spaces,
  //   required this.description,
  //   this.phoneNumber,
  //   required this.latitude,
  //   required this.longitude,
  // });

  // factory CarParkSpaceModel.fromSnapshot(DocumentSnapshot snap) {
  //   var snapshot = snap.data() as Map<String, dynamic>;

  //   // print(snapshot);

  //   return CarParkSpaceModel(
  //     id: snapshot['id'],
  //     address: snapshot['address'],
  //     postcode: snapshot['postcode'],
  //     hourlyRate: snapshot['hourlyRate'],
  //     spaces: snapshot['spaces'],
  //     description: snapshot['description'],
  //     phoneNumber: snapshot['phoneNumber'],
  //     latitude: snapshot['latitude'],
  //     longitude: snapshot['longitude'],
  //   );
  // }
  // // print(snapshot['id']);

  // Map<String, dynamic> toJson() => {
  //       'p_id': id,
  //       'address': address,
  //       'postcode': postcode,
  //       'hourlyRate': hourlyRate,
  //       'spaces': spaces,
  //       'description': description,
  //       'phoneNumber': phoneNumber ?? "",
  //       'latitude': latitude,
  //       'longitude': longitude,
  //     };

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

  static fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> e) {}
}
