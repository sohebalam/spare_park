import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:provider/provider.dart';
import 'package:sparepark/auth_screen.dart';
import 'package:sparepark/screens/crud/parking/register_car_parking.dart';
import 'package:sparepark/screens/mapscreens/results_page.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';
import 'package:sparepark/services/auth_service.dart';

import 'package:sparepark/shared/carpark_space_db_helper.dart';
import 'package:sparepark/shared/widgets/app_bar.dart';
import 'package:sparepark/shared/widgets/drawer.dart';

class MapHome extends StatefulWidget {
  const MapHome({Key? key}) : super(key: key);

  @override
  State<MapHome> createState() => _MapHomeState();
}

class _MapHomeState extends State<MapHome> {
  late GoogleMapController mapController;
  // DateTime? _selectedDateTimeStart;
  // DateTime? _selectedDateTimeEnd;
  DateTime _selectedDateTimeStart = roundToNearest15Minutes(DateTime.now());
  DateTime _selectedDateTimeEnd =
      roundToNearest15Minutes(DateTime.now().add(Duration(hours: 1)));
  LatLng _currentPosition = LatLng(0, 0);
  bool _isLoading = true;
  String? _selectedOption;
  final _placesApiClient =
      GoogleMapsPlaces(apiKey: 'AIzaSyCY8J7h0Q-5Q1UDP9aY0EOy_WZBPESNBBg');
  String _searchTerm = '';
  LatLng? location;
  @override
  void initState() {
    super.initState();
    getLocation();
    _selectedOption = 'Current Location';
  }

  void _newFunction(
    double latitude,
    double longitude,
  ) async {
    final carParkService = DB_CarPark();
    final nearestSpaces = await DB_CarPark.getNearestSpaces(
      latitude: latitude,
      longitude: longitude,
      startdatetime: _selectedDateTimeStart,
      enddatetime: _selectedDateTimeEnd,
    );

    List<List<dynamic>> results = [];
    final currentUser = FirebaseAuth.instance.currentUser;

    nearestSpaces.forEach((space) {
      if (space.u_id != currentUser?.uid) {
        results.add([
          space.p_id,
          space.latitude,
          space.longitude,
          space.hourlyRate,
          space.u_id,
        ]);
      }
    });

    if (currentUser == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => AuthScreen(
                  prior_page: 'map_home',
                  location: LatLng(latitude!, longitude!),
                  results: results,
                  latitude: _currentPosition.latitude,
                  longitude: _currentPosition.longitude,
                  startdatetime: _selectedDateTimeStart,
                  enddatetime: _selectedDateTimeEnd,
                )),
      );
    } else {
      nearestSpaces.forEach((space) {
        if (space.u_id != currentUser.uid) {
          results.add([
            space.p_id,
            space.latitude,
            space.longitude,
            space.hourlyRate,
            space.u_id,
          ]);
        }
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultsPage(
            location: LatLng(latitude!, longitude!),
            results: results,
            latitude: _currentPosition.latitude,
            longitude: _currentPosition.longitude,
            startdatetime: _selectedDateTimeStart,
            enddatetime: _selectedDateTimeEnd,
          ),
        ),
      );
    }
  }

  getLocation() async {
    LocationPermission permission;
    permission = await Geolocator.requestPermission();

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    double lat = position.latitude;
    double long = position.longitude;

    LatLng location = LatLng(lat, long);

    setState(() {
      _currentPosition = location;
      _isLoading = false;
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  List<Prediction> _predictions = [];
  void _onDropdownChanged(String? value) {
    setState(() {
      _selectedOption = value;
    });

    if (_selectedOption == 'Current Location') {
      _newFunction(_currentPosition.latitude, _currentPosition.longitude);
    }
  }

  void _onSearchChanged(String value) async {
    if (value.isNotEmpty) {
      setState(() {
        _isLoading = true;
        _searchTerm = value;
      });

      PlacesAutocompleteResponse response =
          await _placesApiClient.autocomplete(_searchTerm);

      setState(() {
        _isLoading = false;
        _predictions = response.predictions;
      });
    } else {
      setState(() {
        _predictions = [];
      });
    }
  }

  void _onPredictionSelected(Prediction prediction) async {
    PlacesDetailsResponse details =
        await _placesApiClient.getDetailsByPlaceId(prediction.placeId ?? "");

    setState(() {
      location = LatLng(
        details.result.geometry?.location.lat ?? 0.0,
        details.result.geometry?.location.lng ?? 0.0,
      );
      _newFunction(location!.latitude, location!.longitude);
    });
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final isLoggedInStream = authService.user!.map((user) => user != null);
    final Set<Marker> _markers = {
      Marker(
        markerId: MarkerId('current_location'),
        position: _currentPosition,
      )
    };

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Map',
        isLoggedInStream: isLoggedInStream,
      ),
      drawer: AppDrawer(),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _currentPosition,
                zoom: 16.0,
              ),
              markers: _markers,
            ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(8.0),
        color: Colors.grey[300],
        height: MediaQuery.of(context).size.height / 3,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    DatePicker.showDateTimePicker(
                      context,
                      showTitleActions: true,
                      minTime: DateTime.now(),
                      maxTime: DateTime.now().add(Duration(days: 365)),
                      onChanged: (date) {},
                      onConfirm: (date) {
                        setState(() {
                          _selectedDateTimeStart = date;
                          _selectedDateTimeEnd = date.add(Duration(hours: 1));
                        });
                      },
                      currentTime: _selectedDateTimeStart,
                      locale: LocaleType.en,
                    );
                  },
                  child: Column(
                    children: [
                      Text(
                        'Start',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        padding:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _selectedDateTimeStart != null
                                  ? DateFormat('hh:mm a dd/MM/yy')
                                      .format(_selectedDateTimeStart)
                                  : 'Start',
                            ),
                            Icon(Icons.keyboard_arrow_down),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    DatePicker.showDateTimePicker(
                      context,
                      showTitleActions: true,
                      minTime: DateTime.now(),
                      maxTime: DateTime.now().add(Duration(days: 365)),
                      onChanged: (date) {},
                      onConfirm: (date) {
                        setState(() {
                          _selectedDateTimeEnd = date;
                        });
                        print(
                            'Start: ${DateFormat('hh:mm a dd/MM/yy').format(_selectedDateTimeStart)}');
                        print(
                            'End: ${DateFormat('hh:mm a dd/MM/yy').format(date)}');
                      },
                      currentTime: _selectedDateTimeEnd,
                      locale: LocaleType.en,
                    );
                  },
                  child: Column(
                    children: [
                      Text(
                        'End',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        padding:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _selectedDateTimeEnd != null
                                  ? DateFormat('hh:mm a dd/MM/yy')
                                      .format(_selectedDateTimeEnd)
                                  : 'End',
                            ),
                            Icon(Icons.keyboard_arrow_down),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            DropdownButtonFormField<String>(
              value: _selectedOption,
              items: <String>['Current Location'].map((String option) {
                return DropdownMenuItem(
                  value: option,
                  child: Row(
                    children: [
                      Icon(Icons.location_pin),
                      SizedBox(width: 8.0),
                      Text(option),
                    ],
                  ),
                );
              }).toList(),
              onChanged: _onDropdownChanged,
              decoration: InputDecoration(
                  // labelText: 'Select an option',
                  ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              decoration: InputDecoration(
                labelText: 'Search for another Location',
              ),
              onChanged: _onSearchChanged,
            ),
            _isLoading
                ? CircularProgressIndicator()
                : _predictions.isNotEmpty
                    ? Expanded(
                        child: ListView.builder(
                          itemCount: _predictions.length,
                          itemBuilder: (context, index) {
                            final prediction = _predictions[index];
                            return ListTile(
                              title: Text(prediction.description ?? ""),
                              onTap: () {
                                _onPredictionSelected(prediction);
                              },
                            );
                          },
                        ),
                      )
                    : SizedBox.shrink(),
            const SizedBox(height: 16.0),
          ],
        ),
      ),
    );
  }
}

DateTime roundToNearest15Minutes(DateTime dateTime) {
  final minutes = dateTime.minute;
  final roundedMinutes = (minutes / 15).round() * 15;
  return DateTime(dateTime.year, dateTime.month, dateTime.day, dateTime.hour,
      roundedMinutes);
}
