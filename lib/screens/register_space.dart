import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:sparepark/models/car_park_space.dart';
import 'package:sparepark/services/auth_service.dart';
import 'package:sparepark/shared/carpark_space_db_helper.dart';
import 'package:sparepark/shared/widgets/app_bar.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:sparepark/models/car_park_space.dart';
// import 'package:sparepark/shared/carpark_space_db_helper.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class RegisterSpace extends StatefulWidget {
  @override
  State<RegisterSpace> createState() => _RegisterSpaceState();
}

class _RegisterSpaceState extends State<RegisterSpace> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _postcodeController = TextEditingController();
  final _hourlyRateController = TextEditingController();
  final _spacesController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _postcodeOptions = <String>[];
  final picker = ImagePicker();

  File? _image;

  void _fetchPostcodeOptions(String input) async {
    final url =
        Uri.parse('https://api.postcodes.io/postcodes/$input/autocomplete');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['result'] != null) {
        final options = List<String>.from(data['result']);
        setState(() {
          _postcodeOptions.clear();
          _postcodeOptions.addAll(options);
        });
      }
    }
  }

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
      } else {
        print('No image selected.');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final isLoggedInStream = authService.user!.map((user) => user != null);
    User? user = FirebaseAuth.instance.currentUser;

    void _submitForm() async {
      if (_formKey.currentState!.validate()) {
        // Validate postcode
        final postcode = _postcodeController.text;
        final postcodeUrl =
            Uri.parse('https://api.postcodes.io/postcodes/$postcode');
        final postcodeResponse = await http.get(postcodeUrl);
        if (postcodeResponse.statusCode == 200) {
          // Postcode is valid, continue with form submission
          final postcodeData = json.decode(postcodeResponse.body);
          final longitude = postcodeData['result']['longitude'];
          final latitude = postcodeData['result']['latitude'];

          final id =
              FirebaseFirestore.instance.collection('parking_spaces').doc().id;

          final RegisterParkingSpace = CarParkSpaceModel(
            u_id: user!.uid,
            address: _addressController.text,
            postcode: postcode,
            hourlyRate: double.parse(_hourlyRateController.text),
            description: _descriptionController.text,
            latitude: latitude,
            longitude: longitude,
            p_id: id,
          );

          // Upload image to Firebase Storage
          if (_image != null) {
            final storageRef = firebase_storage.FirebaseStorage.instance
                .ref()
                .child('parking_spaces')
                .child(id);
            final uploadTask = storageRef.putFile(_image!);
            final snapshot = await uploadTask.whenComplete(() {});
            final imageUrl = await snapshot.ref.getDownloadURL();
            RegisterParkingSpace.p_image = imageUrl;
          }

          DB_CarPark.create(RegisterParkingSpace);
        } else {
          // Postcode is invalid, show error message
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Invalid postcode'),
            duration: Duration(seconds: 2),
          ));
        }
      }
    }

    return Scaffold(
        appBar: CustomAppBar(
          title: 'Register your space',
          isLoggedInStream: isLoggedInStream,
        ),
        body: SingleChildScrollView(
            child: Stack(children: [
          Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: StreamBuilder<bool>(
                stream: authService.user?.map((user) => user != null),
                initialData: false,
                builder: (context, snapshot) {
                  if (snapshot.data == true) {
                    return Text(
                      'You are logged in.',
                      style: TextStyle(fontSize: 20),
                    );
                  } else {
                    return Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: Text(
                        'You are not logged in, please login to register your space.',
                        style: TextStyle(fontSize: 20),
                      ),
                    );
                  }
                },
              ),
            ),
          ]),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 50.0,
                ),
                Form(
                  key: _formKey,
                  child: TextFormField(
                    controller: _addressController,
                    decoration: InputDecoration(
                      labelText: 'Address',
                    ),
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Please enter an address';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(
                  height: 16.0,
                ),
                TextFormField(
                  controller: _postcodeController,
                  decoration: InputDecoration(
                    labelText: 'Postcode',
                  ),
                  onChanged: (input) {
                    if (input.length > 2) {
                      _fetchPostcodeOptions(input);
                    }
                  },
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter a postcode';
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: 8.0,
                ),
                if (_postcodeOptions.isNotEmpty)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _postcodeOptions.length,
                      itemBuilder: (context, index) {
                        final option = _postcodeOptions[index];
                        return ListTile(
                          title: Text(option),
                          onTap: () {
                            _postcodeController.text = option;
                            setState(() {
                              _postcodeOptions.clear();
                            });
                          },
                        );
                      },
                    ),
                  ),
                SizedBox(
                  height: 16.0,
                ),
                TextFormField(
                  controller: _hourlyRateController,
                  decoration: InputDecoration(
                    labelText: 'Hourly rate (£)',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter an hourly rate';
                    }
                    if (double.tryParse(value!) == null) {
                      return 'Please enter a valid hourly rate';
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: 16.0,
                ),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: 16.0,
                ),
                TextButton(
                  onPressed: _getImage,
                  child: Text('Select an image'),
                ),
                SizedBox(
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
                SizedBox(
                  height: 16.0,
                ),
                Center(
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    child: Text('Submit'),
                  ),
                ),
              ],
            ),
          ),
        ])));
  }
}
