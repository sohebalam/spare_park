import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:flutter_google_places/flutter_google_places.dart';

import 'package:flutter/material.dart';

class CarParkSpace extends StatefulWidget {
  @override
  _CarParkSpaceState createState() => _CarParkSpaceState();
}

// class _CarParkSpaceState extends State<CarParkSpace> {
//   final _formKey = GlobalKey<FormState>();
//   final _addressController = TextEditingController();
//   final _postcodeController = TextEditingController();
//   final _hourlyRateController = TextEditingController();
//   final _spacesController = TextEditingController();
//   final _descriptionController = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     return Form(
//       key: _formKey,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           TextFormField(
//             controller: _addressController,
//             decoration: InputDecoration(
//               labelText: 'Address',
//             ),
//             validator: (value) {
//               if (value?.isEmpty ?? true) {
//                 return 'Please enter an address';
//               }
//               return null;
//             },
//           ),
//           TextFormField(
//             controller: _postcodeController,
//             decoration: InputDecoration(
//               labelText: 'Postcode',
//             ),
//             validator: (value) {
//               if (value?.isEmpty ?? true) {
//                 return 'Please enter a postcode';
//               }
//               return null;
//             },
//           ),
//           TextFormField(
//             controller: _hourlyRateController,
//             keyboardType: TextInputType.number,
//             decoration: InputDecoration(
//               labelText: 'Hourly rate',
//             ),
//             validator: (value) {
//               if (value?.isEmpty ?? true) {
//                 return 'Please enter an hourly rate';
//               }
//               return null;
//             },
//           ),
//           TextFormField(
//             controller: _spacesController,
//             keyboardType: TextInputType.number,
//             decoration: InputDecoration(
//               labelText: 'Number of parking spaces',
//             ),
//             validator: (value) {
//               if (value?.isEmpty ?? true) {
//                 return 'Please enter the number of parking spaces';
//               }
//               return null;
//             },
//           ),
//           TextFormField(
//             controller: _descriptionController,
//             decoration: InputDecoration(
//               labelText: 'Description (optional)',
//             ),
//           ),
//           SizedBox(height: 16),
//           ElevatedButton(
//             onPressed: _submitForm,
//             child: Text('Save'),
//           ),
//         ],
//       ),
//     );
//   }
// }

class _CarParkSpaceState extends State<CarParkSpace> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _postcodeController = TextEditingController();
  final _hourlyRateController = TextEditingController();
  final _spacesController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _placesApiClient =
      GoogleMapsPlaces(apiKey: 'AIzaSyCY8J7h0Q-5Q1UDP9aY0EOy_WZBPESNBBg');

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      print('Address: ${_addressController.text}');
      print('Postcode: ${_postcodeController.text}');
      print('Hourly Rate: ${_hourlyRateController.text}');
      print('Spaces: ${_spacesController.text}');
      print('Description: ${_descriptionController.text}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
          PlacesAutocompleteFormField(
            controller: _postcodeController,
            apiKey: 'AIzaSyCY8J7h0Q-5Q1UDP9aY0EOy_WZBPESNBBg',

            // mode: Mode.postalCode,
            inputDecoration: InputDecoration(
              labelText: 'Postcode',
            ),
            // validator: (value) {
            //   if (value.isEmpty ?? true) {
            //     return 'Please enter a postcode';
            //   }
            //   return null;
            // },
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
              labelText: 'Number of parking spaces',
            ),
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Please enter the number of parking spaces';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _descriptionController,
            decoration: InputDecoration(
              labelText: 'Description (optional)',
            ),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: _submitForm,
            child: Text('Save'),
          ),
        ],
      ),
    );
  }
}
