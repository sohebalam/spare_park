import 'dart:ui' as ui;

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LabelResultsPage extends StatefulWidget {
  const LabelResultsPage({Key? key}) : super(key: key);
  @override
  _LabelResultsPageState createState() => _LabelResultsPageState();
}

class _LabelResultsPageState extends State<LabelResultsPage> {
  final List<Map<String, dynamic>> data = [
    {
      'id': '1',
      'globalKey': GlobalKey(),
      'position': const LatLng(1.329, 103.81),
      'price': '200',
    },
    {
      'id': '2',
      'globalKey': GlobalKey(),
      'position': const LatLng(1.323, 103.82),
      'price': '100',
    },
    {
      'id': '3',
      'globalKey': GlobalKey(),
      'position': const LatLng(1.325, 103.80),
      'price': '150',
    },
  ];

  final Set<Marker> _markers = {};

  Future<void> _onMapCreated(GoogleMapController controller) async {
    for (final item in data) {
      final marker = Marker(
        markerId: MarkerId(item['id']!),
        position: item['position'],
        icon: BitmapDescriptor.fromBytes(
          await _getBytesFromCanvas(item['price']),
        ),
        infoWindow: InfoWindow(
          title: item['price'],
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: const LatLng(1.32, 103.80),
          zoom: 11,
        ),
        markers: _markers,
      ),
    );
  }
}
