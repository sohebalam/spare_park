import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:sparepark/screens/home_page.dart';
import 'package:sparepark/map.dart';
import 'package:sparepark/screens/register_car_space.dart';
import 'package:sparepark/screens/user_map_info.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  // Widget build(BuildContext context) {
  //   return MaterialApp(
  //       debugShowCheckedModeBanner: false,
  //       home: Scaffold(body: Material(child: UserMapInfo())));
  // }
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('My App')),
        body: Material(
          child: CarParkSpace(),
        ),
      ),
    );
  }
}
