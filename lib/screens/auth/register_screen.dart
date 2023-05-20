import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sparepark/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:sparepark/shared/widgets/TextField.dart';
import 'package:sparepark/shared/widgets/app_bar.dart';
import 'package:sparepark/shared/widgets/errorMessage.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isLoading = false;
  final picker = ImagePicker();
  File? _image;
  String? _error;
  String? _errorMessage;
  bool submitted = false;

  void _registerUser() async {
    setState(() {
      submitted = true;
    });

    if (_image == null) {
      setState(() {
        _errorMessage = 'Please select an image.';
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true; // Set loading state
    });

    if (_image == null) {
      setState(() {
        _error = 'Please select an image.';
      });
      return;
    }

    // try {
    final authService = Provider.of<AuthService>(context, listen: false);

    try {
      final user = await authService.createUserWithEmailAndPassword(
        context,
        emailController.text,
        passwordController.text,
        _image!,
        nameController.text,
        // You can also pass other parameters like image and name here
      );
      if (user != null) {
        // User created successfully, show a success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('New user registered successfully!'),
          ),
        );
      } else {
        // User creation failed, show an error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Something went wrong. Please try again later.'),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      // Use e.message instead of e.toString() to show the specific error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message.toString()),
        ),
      );
    } catch (e) {
      // An unknown exception occurred, show an error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
    setState(() {
      _isLoading = false; // Reset loading state
    });
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final isLoggedInStream = authService.user!.map((user) => user != null);
    Future<void> _getImage() async {
      final action = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Select Image Source'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  GestureDetector(
                    child: Text('Camera'),
                    onTap: () {
                      Navigator.of(context).pop(ImageSource.camera);
                    },
                  ),
                  Padding(padding: EdgeInsets.all(8.0)),
                  GestureDetector(
                    child: Text('Gallery'),
                    onTap: () {
                      Navigator.of(context).pop(ImageSource.gallery);
                    },
                  ),
                ],
              ),
            ),
          );
        },
      );

      if (action == null) return;

      final pickedFile = await picker.pickImage(source: action);

      setState(() {
        if (pickedFile != null) {
          _image = File(pickedFile.path);
          _errorMessage = null;
        } else {
          print('No image selected.');
        }
      });
    }

    return Scaffold(
      appBar:
          CustomAppBar(title: 'Register', isLoggedInStream: isLoggedInStream),
      body: Container(
        margin: const EdgeInsets.only(top: 16.0, left: 16, right: 16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    errorText: !submitted || nameController.text.isNotEmpty
                        ? null
                        : 'Please enter your name.',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    errorText: !submitted || emailController.text.isNotEmpty
                        ? null
                        : 'Please enter your email.',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    errorText: !submitted || passwordController.text.isNotEmpty
                        ? null
                        : 'Please enter your password.',
                  ),
                ),
              ),
              const SizedBox(
                height: 16.0,
              ),
              TextButton(
                onPressed: _getImage,
                child: const Text('Select an image'),
              ),
              const SizedBox(
                height: 16.0,
              ),
              if (_image != null)
                Container(
                  height: 200.0,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: FileImage(_image!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              const SizedBox(
                height: 16.0,
              ),
              if (_isLoading) Center(child: CircularProgressIndicator()),
              buildErrorMessage(context, _errorMessage),
              AbsorbPointer(
                absorbing: _isLoading,
                child: ElevatedButton(
                  onPressed: _registerUser,
                  child: const Text('Register'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
