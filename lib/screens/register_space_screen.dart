import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:sparepark/models/car_park_space.dart';
import 'package:sparepark/services/auth_service.dart';
import 'package:sparepark/shared/carpark_space_db_helper.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:auth_buttons/auth_buttons.dart';
import 'package:sparepark/shared/functions.dart';
import 'package:sparepark/shared/widgets/app_bar.dart';

class RegisterSpaceScreen extends StatefulWidget {
  RegisterSpaceScreen();

  @override
  State<RegisterSpaceScreen> createState() => _RegisterSpaceScreenState();
}

class _RegisterSpaceScreenState extends State<RegisterSpaceScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _postcodeController = TextEditingController();
  final _hourlyRateController = TextEditingController();
  final _spacesController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _postcodeOptions = <String>[];
  final picker = ImagePicker();
  final bool isLoggedIn = FirebaseAuth.instance.currentUser != null;

  File? _image;

  @override
  Widget build(BuildContext context) {
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

    final authService = Provider.of<AuthService>(context);
    final isLoggedInStream = authService.user!.map((user) => user != null);
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Register your space',
        isLoggedInStream: isLoggedInStream,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                child: Padding(
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
              ),
              Column(children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Container(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
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
                        ],
                      ),
                    ),
                  ),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}
