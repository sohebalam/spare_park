import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:sparepark/models/user_model.dart';

class AuthService {
  final auth.FirebaseAuth _firebaseAuth = auth.FirebaseAuth.instance;
  final StreamController<User?> _userController = StreamController<User?>();

  Future<void> disconnect() async {
    await _firebaseAuth.signOut();
    _userController.add(null);
  }

  User? _userFromFirebase(auth.User? user) {
    if (user == null) {
      return null;
    }
    return User(uid: user.uid, email: user.email ?? "");
  }

  Stream<User?>? get user {
    return _firebaseAuth.authStateChanges().map(_userFromFirebase);
  }

  Future<User?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return _userFromFirebase(credential.user);
  }

  Future<User?> createUserWithEmailAndPassword(
    String email,
    String password,
    File image,
    String name,

    // String? uid
  ) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Upload the user's image to Firebase Storage and get the download URL
      final ref = FirebaseStorage.instance
          .ref()
          .child('users/${credential.user!.uid}/image.jpg');
      final uploadTask = ref.putFile(image);
      final snapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();

      // Create a new document for the user in Firestore
      final userDoc = FirebaseFirestore.instance
          .collection('users')
          .doc(credential.user!.uid);
      await userDoc.set({
        'name': name,
        'email': email,
        'image': downloadUrl,
        'uid': userDoc.id
      });

      return _userFromFirebase(credential.user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<void> signOut() async {
    return await _firebaseAuth.signOut();
  }

  logout() {}

  isExistingUser(String email) {}
}
