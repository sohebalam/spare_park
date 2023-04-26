import 'dart:ui' as ui;

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ResultsPage extends StatefulWidget {
  final LatLng location;
  final List<List<dynamic>> results;
  final double? latitude;
  final double? longitude;
  const ResultsPage(
      {Key? key,
      required this.location,
      required this.results,
      this.latitude,
      this.longitude})
      : super(key: key);
  @override
  _ResultsPageState createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> {
  final Set<Marker> _markers = {};
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

  Future<void> _onMapCreated(GoogleMapController controller) async {
    // Add a marker for the location
    final locationMarker = Marker(
      markerId: MarkerId("location"),
      position: widget.location,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      infoWindow: InfoWindow(title: "Location"),
    );
    setState(() {
      _markers.add(locationMarker);
    });

    for (int i = 0; i < widget.results.length; i++) {
      final item = widget.results[i];
      final marker = Marker(
        markerId: MarkerId(i.toString()),
        position: LatLng(item[1], item[2]),
        icon: BitmapDescriptor.fromBytes(
          await _getBytesFromCanvas(item[3].toString()),
        ),
        infoWindow: InfoWindow(
          title: "${i + 1}",
        ),
      );
      setState(() {
        _markers.add(marker);
      });
    }
  }

  Future<Uint8List> _getBytesFromCanvas(String text) async {
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);
    const double width = 75;
    const double height = 50;

    // Draw the background shape
    final Paint paint = Paint()..color = Colors.black;
    const Radius radius = Radius.circular(20);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, width, height),
        radius,
      ),
      paint,
    );

    // Add the price text
    TextPainter painter = TextPainter(textDirection: TextDirection.ltr);
    painter.text = TextSpan(
      text: text,
      style: TextStyle(fontSize: 20, color: Colors.white),
    );
    painter.layout();
    painter.paint(
      canvas,
      Offset((width - painter.width) / 2, (height - painter.height) / 2),
    );

    // Draw the arrow
    const double arrowSize = 20.0;
    const double arrowHeadLength = 10.0;
    final Path path = Path()
      ..moveTo(width / 2 - arrowSize / 2, height)
      ..lineTo(width / 2 + arrowSize / 2, height)
      ..lineTo(width / 2, height + arrowHeadLength)
      ..close();
    canvas.drawPath(path, paint);

    final img = await recorder
        .endRecording()
        .toImage(width.floor(), (height + 10).floor());
    final data = await img.toByteData(format: ui.ImageByteFormat.png);
    return data!.buffer.asUint8List();
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     body: GoogleMap(
  //       onMapCreated: _onMapCreated,
  //       initialCameraPosition: CameraPosition(
  //         target: widget.location,
  //         zoom: 12.0,
  //       ),
  //       markers: _markers,
  //     ),
  //   );
  // }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: widget.location,
                zoom: 12.0,
              ),
              markers: _markers,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: widget.results.length,
              itemBuilder: (context, index) {
                final result = widget.results[index];
                final lat = result[1];
                final lng = result[2];
                return Card(
                  child: ListTile(
                    title: Text("£${(result[3].toString())}"),
                    subtitle: Text("Closest space ${(index + 1).toString()}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 80,
                          child: TextButton(
                            onPressed: () {
                              // Navigate to the selected location
                            },
                            child: Column(
                              children: [
                                Icon(Icons.directions),
                                SizedBox(height: 4),
                                Text("Navigate",
                                    style: TextStyle(fontSize: 10)),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 80,
                          child: TextButton(
                            onPressed: () {
                              // Book the selected space
                            },
                            child: Column(
                              children: [
                                Icon(Icons.bookmark),
                                SizedBox(height: 4),
                                Text("Book Now",
                                    style: TextStyle(fontSize: 10)),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 80,
                          child: TextButton(
                            onPressed: () {
                              // Show info for the selected space
                            },
                            child: Column(
                              children: [
                                Icon(Icons.info),
                                SizedBox(height: 4),
                                Text("Info", style: TextStyle(fontSize: 10)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
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
