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
import 'package:sparepark/shared/widgets/loginDialog.dart';
import 'package:sparepark/shared/widgets/app_bar.dart';

class EditParkingSpace extends StatefulWidget {
  final QueryDocumentSnapshot parking;
  final User user;

  EditParkingSpace({required this.parking, required this.user});

  @override
  _EditParkingSpaceState createState() => _EditParkingSpaceState();
}

class _EditParkingSpaceState extends State<EditParkingSpace> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _postcodeController = TextEditingController();
  final _hourlyRateController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _postcodeOptions = <String>[];
  final picker = ImagePicker();
  bool _isLoading = false;

  File? _image;

  @override
  void initState() {
    super.initState();
    _addressController.text = widget.parking['address'];
    _postcodeController.text = widget.parking['postcode'];
    _hourlyRateController.text = widget.parking['hourlyRate'].toString();
    _descriptionController.text = widget.parking['description'];
    _image = File(widget.parking['p_image']);
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

  Future<void> _getImage() async {
    final action = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Image Source'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Choose an option:'),
                ListTile(
                  leading: Icon(Icons.camera),
                  title: Text('Camera'),
                  onTap: () {
                    Navigator.pop(context, 'camera');
                  },
                ),
                ListTile(
                  leading: Icon(Icons.image),
                  title: Text('Gallery'),
                  onTap: () {
                    Navigator.pop(context, 'gallery');
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
    if (action != null) {
      final pickedFile = await picker.pickImage(
        source: action == 'camera' ? ImageSource.camera : ImageSource.gallery,
      );
      setState(() {
        if (pickedFile != null) {
          _image = File(pickedFile.path);
        }
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Perform form submission logic here
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    _postcodeController.dispose();
    _hourlyRateController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Parking Space'),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _addressController,
                        decoration: InputDecoration(
                          labelText: 'Address',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an address';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16.0),
                      TextFormField(
                        controller: _postcodeController,
                        decoration: InputDecoration(
                          labelText: 'Postcode',
                          suffixIcon: IconButton(
                            icon: Icon(Icons.search),
                            onPressed: () {
                              _fetchPostcodeOptions(_postcodeController.text);
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a postcode';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16.0),
                      _postcodeOptions.isNotEmpty
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text('Did you mean:'),
                                SizedBox(height: 8.0),
                                Wrap(
                                  spacing: 8.0,
                                  children: _postcodeOptions
                                      .map((option) => ElevatedButton(
                                            onPressed: () {
                                              setState(() {
                                                _postcodeController.text =
                                                    option;
                                                _postcodeOptions.clear();
                                              });
                                            },
                                            child: Text(option),
                                          ))
                                      .toList(),
                                ),
                                SizedBox(height: 16.0),
                              ],
                            )
                          : Container(),
                      TextFormField(
                        controller: _hourlyRateController,
                        decoration: InputDecoration(
                          labelText: 'Hourly Rate',
                          suffixText: 'GBP',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an hourly rate';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16.0),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          labelText: 'Description',
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a description';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16.0),
                      GestureDetector(
                        onTap: _getImage,
                        child: Container(
                          height: 200.0,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8.0),
                            image: _image != null
                                ? DecorationImage(
                                    image: FileImage(_image!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child:
                              _image == null ? Icon(Icons.add_a_photo) : null,
                        ),
                      ),
                      SizedBox(height: 16.0),
                      ElevatedButton(
                        onPressed: _submitForm,
                        child: Text('Save Changes'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

// class _EditParkingSpaceState extends State<EditParkingSpace> {
//   final _formKey = GlobalKey<FormState>();
//   final _addressController = TextEditingController();
//   final _postcodeController = TextEditingController();
//   final _hourlyRateController = TextEditingController();
//   final _descriptionController = TextEditingController();
//   final _postcodeOptions = <String>[];
//   final picker = ImagePicker();
//   bool _isLoading = false;

//   File? _image;

//   @override
//   void initState() {
//     super.initState();
//     _addressController.text = widget.parking['address'];
//     _postcodeController.text = widget.parking['postcode'];
//     _hourlyRateController.text = widget.parking['hourlyRate'].toString();
//     _descriptionController.text = widget.parking['description'];

//     print(widget.parking['p_image']);
//   }

//   void _fetchPostcodeOptions(String input) async {
//     final url =
//         Uri.parse('https://api.postcodes.io/postcodes/$input/autocomplete');
//     final response = await http.get(url);
//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);
//       if (data['result'] != null) {
//         final options = List<String>.from(data['result']);
//         setState(() {
//           _postcodeOptions.clear();
//           _postcodeOptions.addAll(options);
//         });
//       }
//     }
//   }

//   Future<void> _getImage() async {
//     final action = await showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('Select Image Source'),
//           content: SingleChildScrollView(
//             child: ListBody(
//               children: <Widget>[
//                 Text('Choose an option:'),
//                 ListTile(
//                   leading: Icon(Icons.camera),
//                   title: Text('Camera'),
//                   onTap: () {
//                     Navigator.pop(context, 'camera');
//                   },
//                 ),
//                 ListTile(
//                   leading: Icon(Icons.image),
//                   title: Text('Gallery'),
//                   onTap: () {
//                     Navigator.pop(context, 'gallery');
//                   },
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//     if (action != null) {
//       final pickedFile = await picker.getImage(
//         source: action == 'camera' ? ImageSource.camera : ImageSource.gallery,
//       );

//       setState(() {
//         if (pickedFile != null) {
//           _image = File(pickedFile.path);
//         }
//       });
//     }
//     if (action != null) {
//       final pickedFile = await picker.getImage(
//         source: action == 'camera' ? ImageSource.camera : ImageSource.gallery,
//       );

//       setState(() {
//         if (pickedFile != null) {
//           _image = File(pickedFile.path);
//         }
//       });
//     }
//   }

//   void _submitForm() {
//     if (_formKey.currentState!.validate()) {
// // Perform form submission logic here
//     }
//   }

//   @override
//   void dispose() {
//     _addressController.dispose();
//     _postcodeController.dispose();
//     _hourlyRateController.dispose();
//     _descriptionController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     _image = File(widget.parking['p_image']);
//     return Scaffold(
//         appBar: AppBar(
//           title: Text('Edit Parking Space'),
//         ),
//         body: _isLoading
//             ? Center(
//                 child: CircularProgressIndicator(),
//               )
//             : SingleChildScrollView(
//                 child: Container(
//                   padding: EdgeInsets.all(16.0),
//                   child: Form(
//                     key: _formKey,
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.stretch,
//                       children: [
//                         TextFormField(
//                           controller: _addressController,
//                           decoration: InputDecoration(
//                             labelText: 'Address',
//                           ),
//                           validator: (value) {
//                             if (value == null || value.isEmpty) {
//                               return 'Please enter an address';
//                             }
//                             return null;
//                           },
//                         ),
//                         SizedBox(height: 16.0),
//                         TextFormField(
//                           controller: _postcodeController,
//                           decoration: InputDecoration(
//                             labelText: 'Postcode',
//                           ),
//                           onChanged: (value) {
//                             _fetchPostcodeOptions(value);
//                           },
//                           validator: (value) {
//                             if (value == null || value.isEmpty) {
//                               return 'Please enter a postcode';
//                             }
//                             return null;
//                           },
//                         ),
//                         SizedBox(height: 16.0),
//                         SizedBox(height: 16.0),
//                         TextFormField(
//                           controller: _hourlyRateController,
//                           decoration: InputDecoration(
//                             labelText: 'Hourly Rate',
//                           ),
//                           keyboardType: TextInputType.number,
//                           validator: (value) {
//                             if (value == null || value.isEmpty) {
//                               return 'Please enter an hourly rate';
//                             }
//                             return null;
//                           },
//                         ),
//                         SizedBox(height: 16.0),
//                         TextFormField(
//                           controller: _descriptionController,
//                           decoration: InputDecoration(
//                             labelText: 'Description',
//                           ),
//                           maxLines: null,
//                           validator: (value) {
//                             if (value == null || value.isEmpty) {
//                               return 'Please enter a description';
//                             }
//                             return null;
//                           },
//                         ),
//                         SizedBox(height: 16.0),
//                         ElevatedButton(
//                           onPressed: _submitForm,
//                           child: Text('Save Changes'),
//                         ),
//                         if (_image != null)
//                           Container(
//                             height: 200.0,
//                             width: double.infinity,
//                             decoration: BoxDecoration(
//                               image: DecorationImage(
//                                 image: FileImage(_image!),
//                                 fit: BoxFit.cover,
//                               ),
//                             ),
//                           ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//         floatingActionButton: FloatingActionButton(
//           onPressed: _getImage,
//           child: Icon(Icons.camera_alt),
//         ));
//   }
// }
// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:image_picker/image_picker.dart';

// class EditParkingSpace extends StatefulWidget {
//   final Map<String, dynamic> parking;

//   EditParkingSpace({required this.parking});

//   @override
//   _EditParkingSpaceState createState() => _EditParkingSpaceState();
// }
