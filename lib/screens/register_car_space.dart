import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sparepark/models/car_park_space.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:sparepark/models/user_model.dart';
import 'package:sparepark/pages/edit_page.dart';
import 'package:sparepark/shared/firestore_helper.dart';
// import 'package:sparepark/shared/carpark_space_db_helper.dart';
import 'package:sparepark/shared/user_db_helper.dart';

class CarParkSpace extends StatefulWidget {
  @override
  _CarParkSpaceState createState() => _CarParkSpaceState();
}

class _CarParkSpaceState extends State<CarParkSpace> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _postcodeController = TextEditingController();
  final _hourlyRateController = TextEditingController();
  final _spacesController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _postcodeOptions = <String>[];

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
        print('Address: ${_addressController.text}');
        print('Postcode: $postcode');
        print('Longitude: $longitude');
        print('Latitude: $latitude');
        print('Hourly Rate: ${_hourlyRateController.text}');
        print('Spaces: ${_spacesController.text}');
        print('Description: ${_descriptionController.text}');

        await _registerParkingSpace(postcode, latitude, longitude);
      } else {
        // Postcode is invalid, show error message
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Invalid postcode'),
          duration: Duration(seconds: 2),
        ));
      }
    }
  }

  Future<void> _registerParkingSpace(postcode, latitude, longitude) async {
    try {
      final id =
          FirebaseFirestore.instance.collection('parking_spaces').doc().id;
      final parkingSpace = ParkingSpace(
        p_id: id, postcode: postcode,

        address: _addressController.text,
        hourlyRate: double.parse(_hourlyRateController.text),
        spaces: int.parse(_spacesController.text),
        description: _descriptionController.text,
        // phoneNumber: _phoneNumberController.text,
        latitude: latitude,
        longitude: longitude,
      );
      await FirebaseFirestore.instance
          .collection('parking_spaces')
          .doc(id)
          .set(parkingSpace.toMap());
      // SnackBar(content: Text('Parking space registered successfully'));
    } catch (e) {
      // SnackBar(content: Text('Failed to register parking space'));
    }
  }

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

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 50.0,
          ),
          TextFormField(
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
          TextFormField(
            controller: _postcodeController,
            decoration: InputDecoration(
              labelText: 'Postcode',
            ),
            onChanged: (value) {
              _fetchPostcodeOptions(value);
            },
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Please enter a postcode';
              }
              return null;
            },
          ),
          if (_postcodeOptions.isNotEmpty)
            Container(
              height: 100.0,
              child: ListView.builder(
                itemCount: _postcodeOptions.length,
                itemBuilder: (context, index) {
                  final postcodeOption = _postcodeOptions[index];
                  return ListTile(
                    title: Text(postcodeOption),
                    onTap: () {
                      setState(() {
                        _postcodeController.text = postcodeOption;
                        _postcodeOptions.clear();
                      });
                    },
                  );
                },
              ),
            ),
          TextFormField(
            controller: _hourlyRateController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Hourly rate',
            ),
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Please enter an hourly rate';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _spacesController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Spaces',
            ),
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Please enter the number of spaces';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _descriptionController,
            decoration: InputDecoration(
              labelText: 'Description',
            ),
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Please enter a description';
              }
              return null;
            },
          ),
          SizedBox(height: 16.0),
          Center(
            child: ElevatedButton(
              onPressed: _submitForm,
              child: Text('Submit'),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<ParkingSpace>>(
              future: _getParkingSpaces(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  final parkingSpaces = snapshot.data;
                  return ListView.builder(
                    itemCount: parkingSpaces!.length,
                    itemBuilder: (context, index) {
                      final parkingSpace = parkingSpaces[index];
                      return ListTile(
                        title: Text(parkingSpace.postcode),
                        subtitle: Text(parkingSpace.p_id),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

Future<List<ParkingSpace>> _getParkingSpaces() async {
  final snapshot =
      await FirebaseFirestore.instance.collection('parking_spaces').get();
  return snapshot.docs.map((doc) => ParkingSpace.fromMap(doc.data())).toList();
}
