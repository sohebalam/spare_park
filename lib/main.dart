import 'package:flutter/material.dart';
// import 'package:firebase_crud/home_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:sparepark/firebase_options.dart';
import 'package:sparepark/screens/crud/bookings/booking_list.dart';
import 'package:sparepark/screens/crud/bookings/create_booking.dart';
import 'package:sparepark/screens/mapscreens/map_home.dart';
import 'package:sparepark/screens/crud/parking/parking_list.dart';
import 'package:sparepark/screens/crud/parking/register_car_parking.dart';
import 'package:sparepark/screens/crud/reviews/create_review.dart';
import 'package:sparepark/screens/crud/reviews/review_list.dart';
import 'package:sparepark/screens/mapscreens/map_homepage.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Stripe.publishableKey =
      'pk_test_51N4eusA3A5lLQKKzHmKCZVaUW7lheJqD1xgmoQuKagsz0glmNUx9flCfp5xriz07jBWU51DYRzfv2eGwEZsmkhZm00lWvz2Dqb';
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: Material(
//           child: MapHomePage(
//               // userId: '123',
//               )),
//     );
//   }
// }
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Material(
        child: MapHomePage(
            // userId: '123',
            ),
      ),
    );
  }
}
