import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

GoogleSignIn googleSignIn = GoogleSignIn();
FirebaseFirestore firestore = FirebaseFirestore.instance;

Future signInFunction() async {
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

  // Navigator.pushAndRemoveUntil(context,
  //     MaterialPageRoute(builder: (context) => ChatHome()), (route) => false);
}

final _auth = FirebaseAuth.instance;
Future<void> disconnect() async {
// User? get user => _auth.currentUser;
  await _auth.signOut();
}

DateTime roundToNearest15Minutes(DateTime dateTime) {
  final minutes = dateTime.minute;
  final roundedMinutes = (minutes / 15).round() * 15;
  return DateTime(dateTime.year, dateTime.month, dateTime.day, dateTime.hour,
      roundedMinutes);
}

String formatDateTime(DateTime dateTime) {
  String day = dateTime.day.toString().padLeft(2, '0');
  String month = dateTime.month.toString().padLeft(2, '0');
  String year = dateTime.year.toString();
  String hour = dateTime.hour.toString().padLeft(2, '0');
  String minute = dateTime.minute.toString().padLeft(2, '0');
  return '$day/$month/$year $hour:$minute';
}

// Widget textWidget(
//     {required String text,
//     double fontSize = 12,
//     FontWeight fontWeight = FontWeight.normal,
//     Color color = Colors.black}) {
//   return Text(
//     text,
//     style: GoogleFonts.poppins(
//         fontSize: fontSize, fontWeight: fontWeight, color: color),
//   );
// }
