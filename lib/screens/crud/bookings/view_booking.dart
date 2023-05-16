import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';
import 'package:sparepark/models/booking_model.dart';
import 'package:sparepark/screens/crud/bookings/payment.dart';
import 'package:sparepark/shared/booking_db_helper.dart';
import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

DateTime roundToNearest15Minutes(DateTime dateTime) {
  final minutes = dateTime.minute;
  final roundedMinutes = (minutes / 15).round() * 15;
  return DateTime(dateTime.year, dateTime.month, dateTime.day, dateTime.hour,
      roundedMinutes);
}

class ViewBooking extends StatefulWidget {
  const ViewBooking({
    Key? key,
    required this.cpsId,
    required this.startDateTime,
    required this.endDateTime,
  }) : super(key: key);

  final String cpsId;
  final DateTime startDateTime;
  final DateTime endDateTime;

  @override
  _ViewBookingState createState() => _ViewBookingState();
}

class _ViewBookingState extends State<ViewBooking> {
  double _hourlyRate = 10;

  late User? currentUser;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    // Get the current user when the widget is first created
    currentUser = FirebaseAuth.instance.currentUser;
  }

  Completer<GoogleMapController> _controller = Completer();
  static final CameraPosition _kInitialPosition = CameraPosition(
    target: LatLng(51.5074, 0.1278),
    zoom: 12,
  );

  Set<Marker> _markers = {};

  double get total {
    final hours = widget.endDateTime.difference(widget.startDateTime).inHours;
    return hours * _hourlyRate;
  }

  void onSubmit() async {
    // Create a new booking model object
    // Create a new booking model object
    BookingModel booking = BookingModel(
      b_id: '', // Set b_id as an empty string initially
      p_id: widget.cpsId,
      u_id: currentUser!.uid,
      start_date_time: widget.startDateTime,
      end_date_time: widget.endDateTime,
      b_total: total,
      reg_date: DateTime.now(),
    );

    // Add the booking to Firebase
    final DocumentReference bookingRef = await FirebaseFirestore.instance
        .collection('bookings')
        .add(booking.toJson());

    // Update the b_id field with the actual booking ID assigned by Firebase
    await bookingRef.update({'b_id': bookingRef.id});

    // Show a success message with the booking ID
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Booking ${bookingRef.id} created successfully'),
      ),
    );
    final String bookingId = bookingRef.id;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Payment(
          b_id: bookingId,
          total: total,
        ),
      ),
    );
  }

  Future<Marker> _getMarker() async {
    final spaceDoc = await FirebaseFirestore.instance
        .collection('parking_spaces')
        .doc(widget.cpsId)
        .get();

    final spaceData = spaceDoc.data() as Map<String, dynamic>;

    final latitude = spaceData['latitude'] as double;
    final longitude = spaceData['longitude'] as double;

    final ByteData data = await rootBundle.load('assets/carpark1.jpg');
    final Uint8List resizedBytes = await _resizeImage(data, 200, 150);

    final BitmapDescriptor bitmapDescriptor =
        BitmapDescriptor.fromBytes(resizedBytes);

    return Marker(
      markerId: MarkerId(widget.cpsId),
      position: LatLng(latitude, longitude),
      infoWindow: InfoWindow(
        title: widget.cpsId,
        snippet: 'This is a parking space',
      ),
      icon: bitmapDescriptor,
    );
  }

  Future<Uint8List> _resizeImage(
      ByteData data, int targetWidth, int targetHeight) async {
    final ui.Codec codec =
        await ui.instantiateImageCodec(data.buffer.asUint8List());
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    final ui.Image image = frameInfo.image;

    final ui.Image resizedImage = await _resize(
        ui.window.devicePixelRatio, image, targetWidth, targetHeight);
    final ByteData? resizedByteData =
        await resizedImage.toByteData(format: ui.ImageByteFormat.png);
    return resizedByteData!.buffer.asUint8List();
  }

  Future<ui.Image> _resize(double devicePixelRatio, ui.Image image,
      int targetWidth, int targetHeight) async {
    final ui.Paint paint = ui.Paint()..filterQuality = ui.FilterQuality.high;
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);
    canvas.scale(devicePixelRatio, devicePixelRatio);
    canvas.drawImageRect(
        image,
        ui.Rect.fromLTRB(0, 0, image.width.toDouble(), image.height.toDouble()),
        ui.Rect.fromLTRB(0, 0, targetWidth.toDouble(), targetHeight.toDouble()),
        paint);
    final ui.Picture picture = recorder.endRecording();
    return picture.toImage(targetWidth * devicePixelRatio.toInt(),
        targetHeight * devicePixelRatio.toInt());
  }

  void _onMapCreated(GoogleMapController controller) async {
    _controller.complete(controller);

    final marker = await _getMarker();

    setState(() {
      _markers.add(marker);
    });

    final cameraPosition = CameraPosition(
      target: marker.position,
      zoom: 16,
    );
    controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }

  @override
  Widget build(BuildContext context) {
    print(widget.cpsId);

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              initialCameraPosition: _kInitialPosition,
              onMapCreated: _onMapCreated,
              markers: _markers,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(0, 0, 8, 0),
                        child: Container(
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
                                DateFormat('HH:mm dd MMM yy')
                                    .format(widget.startDateTime),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(8, 0, 0, 0),
                        child: Container(
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
                                DateFormat('HH:mm dd MMM yy')
                                    .format(widget.endDateTime),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Text(
                  'Total: £${total.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: onSubmit,
                  child: Text('Submit Booking'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
