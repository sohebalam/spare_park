import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:sparepark/firebase_options.dart';
import 'package:sparepark/screens/auth/register_screen.dart';
import 'package:sparepark/screens/mapscreens/map_home.dart';
import 'package:sparepark/services/auth_service.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(
          create: (_) => AuthService(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Auth Example',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        initialRoute: '/map_home',
        routes: {
          // '/': (context) => Wrapper(),
          '/map_home': (context) => MapHome(),
          // '/login': (context) => LoginScreen(),
          '/register': (context) => RegisterScreen(),
        },
      ),
    );
  }
}
