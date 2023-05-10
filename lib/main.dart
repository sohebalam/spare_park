import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:sparepark/firebase_options.dart';
import 'package:sparepark/screens/register_space.dart';
import 'package:sparepark/screens/register_space_screen.dart';
import 'package:sparepark/services/auth_service.dart';
import 'package:sparepark/wrapper.dart';
import 'package:provider/provider.dart';
import 'screens/screens.dart';

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
        initialRoute: '/carpark_register',
        routes: {
          '/': (context) => Wrapper(),
          '/carpark_register': (context) => RegisterSpace(),
          '/login': (context) => LoginScreen(),
          '/register': (context) => RegisterScreen(),
        },
      ),
    );
  }
}
