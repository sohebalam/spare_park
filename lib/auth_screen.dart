import 'package:auth_buttons/auth_buttons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter_platform_interface/src/types/location.dart';
import 'package:provider/provider.dart';
import 'package:sparepark/main.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sparepark/screens/mapscreens/results_page.dart';
import 'package:sparepark/services/auth_service.dart';

class AuthScreen extends StatefulWidget {
  final String prior_page;
  final LatLng? location;
  final List<List>? results;
  final double? latitude;
  final double? longitude;
  final DateTime? startdatetime;
  final DateTime? enddatetime;

  AuthScreen({
    Key? key,
    required this.prior_page,
    this.location,
    this.results,
    this.latitude,
    this.longitude,
    this.startdatetime,
    this.enddatetime,
  }) : super(key: key);

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  GoogleSignIn googleSignIn = GoogleSignIn();
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> signInFunction(
    BuildContext context,
    LatLng? location,
    List<List>? results,
    DateTime? startdatetime,
    DateTime? enddatetime,
  ) async {
    GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    if (googleUser == null) {
      return;
    }
    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);
    UserCredential userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);

    DocumentSnapshot userExist =
        await firestore.collection('users').doc(userCredential.user!.uid).get();

    if (userExist.exists) {
      print("User Already Exists in Database");
    } else {
      await firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': userCredential.user!.email,
        'name': userCredential.user!.displayName,
        'image': userCredential.user!.photoURL,
        'uid': userCredential.user!.uid,
        'date': DateTime.now(),
      });
    }

    if (widget.prior_page == 'map_home') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultsPage(
            location: widget.location!,
            results: widget.results!,
            startdatetime: widget.startdatetime!,
            enddatetime: widget.enddatetime!,
          ),
        ),
      );
    } else {
      // handle other cases
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final isLoggedInStream = authService.user!.map((user) => user != null);
    print('resutls:');
    print(widget.results);
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: NetworkImage(
                            "https://cdn.iconscout.com/icon/free/png-256/chat-2639493-2187526.png"))),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: "Email",
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      labelText: "Password",
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    authService.signInWithEmailAndPassword(
                      emailController.text,
                      passwordController.text,
                    );
                  },
                  child: Text('Login'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/register');
                  },
                  child: Text('Register'),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 0, 30),
              child: Center(
                child: GoogleAuthButton(
                  onPressed: () async {
                    await signInFunction(
                      context,
                      widget.location!,
                      widget.results!,
                      widget.startdatetime,
                      widget.enddatetime,
                    );
                  },
                  text: "Sign up with Google",
                  style: AuthButtonStyle(
                    width: 350,
                    height: 60,
                    iconType: AuthIconType.outlined,
                    buttonColor: Colors.white,
                    textStyle: TextStyle(
                      fontSize: 12,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
