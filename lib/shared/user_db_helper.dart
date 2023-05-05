import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sparepark/models/car_park_space.dart';

// class DB_CarPark {
//   static Stream<List<CarParkSpaceModel>> read() {
//     final userCollection =
//         FirebaseFirestore.instance.collection("carpark_spaces");
//     return userCollection.snapshots().map((querySnapshot) => querySnapshot.docs
//         .map((e) => CarParkSpaceModel.fromSnapshot(e))
//         .toList());
//   }

//   static Future create(CarParkSpaceModel cps) async {
//     final carpark_spaceCollection =
//         FirebaseFirestore.instance.collection("carpark_spaces");

//     final cpsid = carpark_spaceCollection.doc().id;
//     final docRef = carpark_spaceCollection.doc(cpsid);

//     final newUser = CarParkSpaceModel(
//       p_id: cpsid,
//       address: cps.address,
//       postcode: cps.postcode,
//       hourlyRate: cps.hourlyRate,
//       spaces: cps.spaces,
//       description: cps.description,
//       phoneNumber: cps.phoneNumber,
//       latitude: cps.latitude,
//       longitude: cps.longitude,
//     ).toJson();

//     try {
//       await docRef.set(newUser);
//     } catch (e) {
//       print("some error occured $e");
//     }
//   }

  // static Future update(CarParkSpaceModel user) async {
  //   final userCollection = FirebaseFirestore.instance.collection("users");

  //   final docRef = userCollection.doc(user.id);

  //   final newUser =
  //       CarParkSpaceModel(id: user.id, username: user.username, age: user.age)
  //           .toJson();

  //   try {
  //     await docRef.update(newUser);
  //   } catch (e) {
  //     print("some error occured $e");
  //   }
  // }

  // static Future delete(CarParkSpaceModel user) async {
  //   final userCollection = FirebaseFirestore.instance.collection("users");

  //   final docRef = userCollection.doc(user.id).delete();
  // }
// }
