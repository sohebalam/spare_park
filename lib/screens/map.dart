import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class LocationPage extends StatefulWidget {
  @override
  _LocationPageState createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  LatLng _center = LatLng(0, 0);
  late GoogleMapController _mapController;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  void _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _center = LatLng(position.latitude, position.longitude);
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _moveCameraToMarker(LatLng markerPosition) {
    final double padding = 50;
    LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(markerPosition.latitude - (padding / 2),
          markerPosition.longitude - (padding / 2)),
      northeast: LatLng(markerPosition.latitude + (padding / 2),
          markerPosition.longitude + (padding / 2)),
    );
    _mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, padding));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Current Location'),
      ),
      body: Center(
        child: GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(
            target: _center,
            zoom: 15.0,
          ),
          markers: Set.from([
            Marker(
              markerId: MarkerId('current_location'),
              position: _center,
            ),
          ]),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _moveCameraToMarker(_center);
        },
        child: Icon(Icons.zoom_in),
      ),
    );
  }
}
