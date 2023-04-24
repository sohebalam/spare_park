import 'package:flutter/material.dart';
// import 'package:firebase_crud/home_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sparepark/firebase_options.dart';
import 'package:sparepark/pages/home_page.dart';
import 'package:sparepark/screens/map.dart';
import 'package:sparepark/screens/register_car_space.dart';
import 'package:sparepark/screens/mapscreens/user_map_info.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Material(child: UserMapInfo()),
    );
  }
}
