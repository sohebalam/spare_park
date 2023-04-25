import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:sparepark/screens/label_marker.dart';
import 'package:sparepark/screens/mapscreens/label_marker.dart';
import 'package:sparepark/screens/mapscreens/results_page.dart';
import 'package:sparepark/shared/carpark_space_db_helper.dart';

class UserMapInfo extends StatefulWidget {
  const UserMapInfo({Key? key}) : super(key: key);

  @override
  State<UserMapInfo> createState() => _UserMapInfoState();
}

class _UserMapInfoState extends State<UserMapInfo> {
  late GoogleMapController mapController;

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
    double? latitude,
    double? longitude,
  ) async {
    final carParkService = DB_CarPark();
    final nearestSpaces = await carParkService.getNearestSpaces(
      latitude: latitude,
      longitude: longitude,
    );
    List<List<dynamic>> results = [];
    nearestSpaces.forEach((space) {
      results.add([
        space.id,
        space.latitude,
        space.longitude,
        space.hourlyRate,
      ]);
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultsPage(
          location: LatLng(latitude!, longitude!),
          results: results,
          latitude: _currentPosition.latitude,
          longitude: _currentPosition.longitude,
        ),
      ),
    );
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
      _newFunction(location?.latitude, location?.longitude);
    });
  }

  @override
  Widget build(BuildContext context) {
    final Set<Marker> _markers = {
      Marker(
        markerId: MarkerId('current_location'),
        position: _currentPosition,
      )
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Map'),
      ),
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
