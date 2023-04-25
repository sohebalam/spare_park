import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sparepark/screens/mapscreens/directions_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:android_intent/android_intent.dart';
import 'package:label_marker/label_marker.dart';

class ResultsPage extends StatefulWidget {
  final LatLng location;
  final List<List<dynamic>> results;
  final double? latitude;
  final double? longitude;

  ResultsPage({
    required this.location,
    required this.results,
    this.latitude,
    this.longitude,
  });

  @override
  State<ResultsPage> createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> {
  GoogleMapController? controller;

  @override
  void initState() {
    super.initState();

    // Ensure that the Google Maps plugin has fully initialized before
    // attempting to animate the camera
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      final mostNortheastSpace = widget.results.reduce((curr, next) =>
          curr[1] > next[1] || (curr[1] == next[1] && curr[2] > next[2])
              ? curr
              : next);

      final mostSouthwestSpace = widget.results.reduce((curr, next) =>
          curr[1] < next[1] || (curr[1] == next[1] && curr[2] < next[2])
              ? curr
              : next);

      controller?.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            northeast: LatLng(mostNortheastSpace[1], mostNortheastSpace[2]),
            southwest: LatLng(mostSouthwestSpace[1], mostSouthwestSpace[2]),
          ),
          100.0,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Results'),
      ),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: widget.location,
                zoom: 12.0,
              ),
              onMapCreated: (controller) {
                this.controller = controller;
              },
              markers: {
                Marker(
                  markerId: MarkerId('location_marker'),
                  position: widget.location,
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueBlue,
                  ),
                ),
                if (widget.latitude != null && widget.longitude != null)
                  Marker(
                    markerId: MarkerId('current_location'),
                    position: LatLng(widget.latitude!, widget.longitude!),
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueGreen,
                    ),
                  ),
                for (int i = 0; i < widget.results.length; i++)
                  Marker(
                    markerId: MarkerId('result_$i'),
                    position:
                        LatLng(widget.results[i][1], widget.results[i][2]),
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueRed,
                    ),
                    infoWindow: InfoWindow(
                      title: 'Result ${i + 1}',
                    ),
                  ),
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: widget.results.length,
              itemBuilder: (context, index) {
                final result = widget.results[index];
                final lat = result[1];
                final lng = result[2];
                return GestureDetector(
                  onTap: () {
                    print(result[0]);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DirectionsPage(
                          currentLocation:
                              LatLng(widget.latitude!, widget.longitude!),
                          selectedLocation: LatLng(result[1], result[2]),
                          cpsId: result[0],
                        ),
                      ),
                    );
                  },
                  child: ListTile(
                    title: Text('Latitude: $lat, Longitude: $lng'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
