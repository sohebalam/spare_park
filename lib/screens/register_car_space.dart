import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sparepark/models/car_park_space.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:sparepark/models/user_model.dart';
import 'package:sparepark/shared/carpark_space_db_helper.dart';

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

        final id =
            FirebaseFirestore.instance.collection('parking_spaces').doc().id;

        final carParkSpace = CarParkSpaceModel(
          address: _addressController.text,
          postcode: postcode,
          hourlyRate: double.parse(_hourlyRateController.text),
          spaces: int.parse(_spacesController.text),
          description: _descriptionController.text,
          // phoneNumber: _phoneNumberController.text,
          latitude: latitude,
          longitude: longitude, p_id: id,
        );

        DB_CarPark.create(carParkSpace);
      } else {
        // Postcode is invalid, show error message
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Invalid postcode'),
          duration: Duration(seconds: 2),
        ));
      }
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
          StreamBuilder<List<CarParkSpaceModel>>(
              stream: DB_CarPark.read(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text("some error occured"),
                  );
                }
                if (snapshot.hasData) {
                  final userData = snapshot.data;
                  return Expanded(
                    child: ListView.builder(
                        itemCount: userData!.length,
                        itemBuilder: (context, index) {
                          final singleSpace = userData[index];
                          return Container(
                            margin: EdgeInsets.symmetric(vertical: 5),
                            child: ListTile(
                              leading: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                    color: Colors.deepPurple,
                                    shape: BoxShape.circle),
                              ),
                              title: Text("${singleSpace.address}"),
                              subtitle: Text("${singleSpace.postcode}"),
                            ),
                          );
                        }),
                  );
                }
                return Center(
                  child: CircularProgressIndicator(),
                );
              }),
        ],
      ),
    );
  }
}
