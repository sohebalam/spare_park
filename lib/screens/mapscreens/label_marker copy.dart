import 'dart:async';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/rendering.dart';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sparepark/screens/mapscreens/max_on_flutter.dart/custom_marker_widget.dart';
import 'package:sparepark/screens/mapscreens/directions_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:android_intent/android_intent.dart';
import 'package:label_marker/label_marker.dart';

class LabelResultsPage extends StatefulWidget {
  final LatLng location;
  final List<List<dynamic>> results;
  final double? latitude;
  final double? longitude;

  LabelResultsPage({
    required this.location,
    required this.results,
    this.latitude,
    this.longitude,
  });

  @override
  State<LabelResultsPage> createState() => _LabelResultsPageState();
}

class _LabelResultsPageState extends State<LabelResultsPage> {
  GoogleMapController? controller;
  final Map<String, Marker> _markers = {};
  bool _isLoaded = false;

  List<Map<String, dynamic>> data = [
    {
      'id': '1',
      'globalKey': GlobalKey(),
      'position': const LatLng(1.32, 103.80),
      'widget': const CustomMarkerWidget(price: 200),
    },
    {
      'id': '2',
      'globalKey': GlobalKey(),
      'position': const LatLng(1.323, 103.82),
      'widget': const CustomMarkerWidget(price: 100),
    },
    {
      'id': '1',
      'globalKey': GlobalKey(),
      'position': const LatLng(1.325, 103.80),
      'widget': const CustomMarkerWidget(price: 150),
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _onBuildCompleted());

    // Ensure that the Google Maps plugin has fully initialized before
    // attempting to animate the camera
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
            child: _isLoaded
                ? GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: widget.location,
                      zoom: 12.0,
                    ),
                    onMapCreated: (controller) {
                      this.controller = controller;
                    },
                    markers: _markers.values.toSet(),
                  )
                : ListView(
                    children: [
                      for (int i = 0; i < data.length; i++)
                        Transform.translate(
                          offset: Offset(
                            -MediaQuery.of(context).size.width * 2,
                            -MediaQuery.of(context).size.height * 2,
                          ),
                          child: RepaintBoundary(
                            key: data[i]['globalKey'],
                            child: data[i]['widget'],
                          ),
                        )
                    ],
                  ),

            // ListView(
            //     children: [
            //       for (int i = 0; i < data.length; i++)
            //         Transform.translate(
            //           offset: Offset(
            //             -MediaQuery.of(context).size.width * 2,
            //             -MediaQuery.of(context).size.height * 2,
            //           ),
            //           child: RepaintBoundary(
            //             key: data[i]['globalKey'],
            //             child: data[i]['widget'],
            //           ),
            //         )
            //     ],
            //   ),
          ),
        ],
      ),
    );
  }

  Future<void> _onBuildCompleted() async {
    await Future.wait(
      data.map((value) async {
        Marker marker = await _generateMarkersFromWidgets(value);
        _markers[marker.markerId.value] = marker;
      }),
    );
    setState(() => _isLoaded = true);
  }

  // Future<Marker> _generateMarkersFromWidgets(Map<String, dynamic> data) async {
  //   RenderRepaintBoundary boundary = data['globalKey']
  //       .currentContext
  //       ?.findRenderObject() as RenderRepaintBoundary;
  //   ui.Image image = await boundary.toImage(pixelRatio: 2);
  //   ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);

  //   return Marker(
  //     markerId: MarkerId(data['id']),
  //     position: data['position'],
  //     icon: BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List()),
  //   );
  // }
  Future<Marker> _generateMarkersFromWidgets(Map<String, dynamic> data) async {
    RenderRepaintBoundary? boundary = data['globalKey']
        .currentContext
        ?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) {
      throw Exception('Failed to load boundary');
    }
    ui.Image image = await boundary.toImage(pixelRatio: 2);
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    return Marker(
      markerId: MarkerId(data['id']),
      position: data['position'],
      icon: BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List()),
    );
  }
}
