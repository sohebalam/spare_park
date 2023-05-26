import 'package:auth_buttons/auth_buttons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter_platform_interface/src/types/location.dart';
import 'package:provider/provider.dart';
import 'package:sparepark/main.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sparepark/screens/auth/register_screen.dart';
import 'package:sparepark/screens/mapscreens/map_home.dart';
import 'package:sparepark/screens/mapscreens/results_page.dart';
import 'package:sparepark/services/auth_service.dart';
import 'package:sparepark/shared/style/contstants.dart';
import 'package:sparepark/shared/widgets/app_bar.dart';
import 'package:sparepark/shared/widgets/drawer.dart';

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
  bool _obscureText = true;

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
    DocumentSnapshot userEmailExist = await firestore
        .collection('users')
        .doc(userCredential.user!.email)
        .get();

    if (userExist.exists || userEmailExist.exists) {
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
      print('prior_page value: ${widget.prior_page}');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResultsPage(
            location: location!,
            results: results!,
            startdatetime: startdatetime!,
            enddatetime: enddatetime!,
          ),
        ),
      );
    } else {
      print('here nav');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MapHome(),
        ),
      );
    }
  }

  Future<void> signInFunc(
    BuildContext context,
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
    DocumentSnapshot userEmailExist = await firestore
        .collection('users')
        .doc(userCredential.user!.email)
        .get();

    if (userExist.exists || userEmailExist.exists) {
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
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MapHome(),
      ),
    );
  }

  // Future<void> signInFunc(BuildContext context) async {
  //   // Perform custom sign-in logic here
  //   // Replace the code below with your own custom sign-in implementation
  //   // Once the user is authenticated, navigate to the desired page
  //   // Example:
  //   Navigator.pushReplacement(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => MapHome(),
  //     ),
  //   );
  // }

  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final isLoggedInStream = authService.user!.map((user) => user != null);
    print('results:');
    print(widget.results);
    return Scaffold(
      appBar: CustomAppBar(title: 'Login', isLoggedInStream: isLoggedInStream),
      drawer: AppDrawer(),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              SizedBox(height: 80),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 180, // Adjust the width as needed
                    height: 180, // Adjust the height as needed
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/parking.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(height: 16), // Add space between the image and text
                  Padding(
                    padding: EdgeInsets.only(
                        right: 15), // Adjust the left padding as needed
                    child: Text(
                      'Spare Park',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
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
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureText
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: _obscureText
                                  ? Colors.grey
                                  : Constants().primaryColor,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureText = !_obscureText;
                              });
                            },
                          )),
                      obscureText: _obscureText,
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Constants()
                          .primaryColor, // Set a different color for the button
                    ),
                    onPressed: () {
                      if (emailController.text.length > 6 &&
                          passwordController.text.length > 6) {
                        authService.signInWithEmailAndPassword(
                          context,
                          emailController.text,
                          passwordController.text,
                          prior_page: widget.prior_page,
                          location: widget.location,
                          results: widget.results,
                          startdatetime: widget.startdatetime,
                          enddatetime: widget.enddatetime,
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "Email and password must be at least 6 characters long.",
                            ),
                          ),
                        );
                      }
                    },
                    child: Text(
                      'Login',
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RegisterScreen(
                            prior_page: widget.prior_page,
                            location: widget.location,
                            results: widget.results,
                            startdatetime: widget.startdatetime,
                            enddatetime: widget.enddatetime,
                          ),
                        ),
                      );
                    },
                    child: Text('Register',
                        style: TextStyle(
                          color: Constants().primaryColor,
                        )),
                  ),
                ],
              ),
              SizedBox(height: 70),
              Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 0, 30),
                child: Center(
                  child: GoogleAuthButton(
                    onPressed: () async {
                      if (widget.prior_page == 'map_home') {
                        await signInFunction(
                          context,
                          widget.location,
                          widget.results,
                          widget.startdatetime,
                          widget.enddatetime,
                        );
                      } else {
                        await signInFunc(context);
                      }
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
      ),
    );
  }
}
