import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter_platform_interface/src/types/location.dart';
import 'package:sparepark/main.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sparepark/screens/mapscreens/results_page.dart';

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
            // Text(
            //   "Flutter Chat App",
            //   style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
            // ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              child: ElevatedButton(
                onPressed: () async {
                  await signInFunction(
                    context,
                    widget.location!,
                    widget.results!,
                    widget.startdatetime,
                    widget.enddatetime,
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.network(
                      'https://www.freepnglogos.com/uploads/google-logo-png/google-logo-png-webinar-optimizing-for-success-google-business-webinar-13.png',
                      height: 36,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      "Sign in With Google",
                      style: TextStyle(fontSize: 20),
                    )
                  ],
                ),
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.black),
                    padding: MaterialStateProperty.all(
                        EdgeInsets.symmetric(vertical: 12))),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
