import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:custom_map_markers/custom_map_markers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:ui' as ui;

class MyHomePage extends StatefulWidget {
  MyHomePage({
    Key? key,
    required this.cpsId,
    required this.image,
  }) : super(key: key);

  final String cpsId;
  final String image;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late List<MarkerData> _customMarkers = [];
  late GoogleMapController _mapController;

  @override
  void initState() {
    super.initState();
    _fetchMarkerData();
  }

  Future<void> _fetchMarkerData() async {
    final spaceDoc = await FirebaseFirestore.instance
        .collection('parking_spaces')
        .doc(widget.cpsId)
        .get();

    final spaceData = spaceDoc.data() as Map<String, dynamic>;

    final latitude = spaceData['latitude'] as double;
    final longitude = spaceData['longitude'] as double;
    final markerId = MarkerId(widget.cpsId);
    final marker = Marker(
      markerId: markerId,
      position: LatLng(latitude, longitude),
      icon: BitmapDescriptor.defaultMarker,
    );

    final resizedImage = await _resizeImage(widget.image, 200, 150);
    final customMarker = MarkerData(
      marker: marker,
      child: _customMarker(resizedImage, Colors.red),
    );

    setState(() {
      _customMarkers = [customMarker];
    });
  }

  Future<Uint8List> _loadImageData(String imagePath) async {
    final response = await http.get(Uri.parse(imagePath));
    final data = response.bodyBytes;

    final compressedData = await FlutterImageCompress.compressWithList(
      data,
      minHeight: 200,
      minWidth: 150,
      quality: 90,
    );

    return Uint8List.fromList(compressedData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            if (_customMarkers.isNotEmpty) {
              _customMarkers.removeLast();
            }
          });
        },
      ),
      body: CustomGoogleMapMarkerBuilder(
        customMarkers: _customMarkers,
        builder: (BuildContext context, Set<Marker>? markers) {
          if (markers == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(51.654827, -0.083599),
              zoom: 14.4746,
            ),
            markers: markers,
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
              _animateToMarker();
            },
          );
        },
      ),
    );
  }

  void _animateToMarker() {
    if (_customMarkers.isNotEmpty) {
      final marker = _customMarkers.first.marker;
      _mapController.animateCamera(
        CameraUpdate.newLatLngZoom(marker.position, 14.0),
      );
    }
  }

  Future<Uint8List> _resizeImage(
      String imagePath, int width, int height) async {
    final response = await http.get(Uri.parse(imagePath));
    final data = response.bodyBytes;
    final compressedData = await FlutterImageCompress.compressWithList(
      data,
      minHeight: height,
      minWidth: width,
      quality: 90,
    );
    return Uint8List.fromList(compressedData);
  }

  Widget _customMarker(Uint8List imageData, Color color) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Icon(
          Icons.add_location,
          color: color,
          size: 200,
        ),
        Positioned(
          left: 50,
          top: -50,
          bottom: 0,
          child: Align(
            alignment: Alignment.center,
            child: ClipOval(
              child: Image.memory(
                imageData,
                width: 100,
                height: 100,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
