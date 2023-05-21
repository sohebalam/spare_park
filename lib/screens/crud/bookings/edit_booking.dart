import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:custom_map_markers/custom_map_markers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:ui' as ui;

import 'package:intl/intl.dart';
import 'package:sparepark/models/booking_model.dart';
import 'package:sparepark/screens/crud/bookings/payment.dart';
import 'package:sparepark/shared/style/contstants.dart';

class EditBooking extends StatefulWidget {
  EditBooking({
    Key? key,
    required this.cpsId,
    required this.image,
    required this.postcode,
    required this.address,
    required this.startDateTime,
    required this.endDateTime,
    required bookingId,
  }) : super(key: key);

  final String cpsId;
  final String image;
  final String postcode;
  final String address;
  DateTime startDateTime;
  DateTime endDateTime;

  @override
  State<EditBooking> createState() => _EditBookingState();
}

class _EditBookingState extends State<EditBooking> {
  late List<MarkerData> _customMarkers = [];
  late GoogleMapController _mapController;
  double _hourlyRate = 10;
  late User? currentUser;
  bool isLoading = false;

  double get total {
    final hours = widget.endDateTime.difference(widget.startDateTime).inHours;
    return hours * _hourlyRate;
  }

  @override
  void initState() {
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser;
    _fetchMarkerData();
  }

  void onSubmit() async {
    isLoading = true;
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
    isLoading = false;
  }

  Future<void> _fetchMarkerData() async {
    final spaceDoc = await FirebaseFirestore.instance
        .collection('parking_spaces')
        .doc(widget.cpsId)
        .get();

    final spaceData = spaceDoc.data() as Map<String, dynamic>;

    final latitude = spaceData['latitude'] as double;
    final longitude = spaceData['longitude'] as double;
    final hourlyRate =
        spaceData['hourlyRate'] as double; // Fetch hourlyRate from database

    setState(() {
      _hourlyRate = hourlyRate; // Update the hourlyRate value
    });

    final markerId = MarkerId(widget.cpsId);
    final marker = Marker(
      markerId: markerId,
      position: LatLng(latitude, longitude),
      icon: BitmapDescriptor.defaultMarker,
      infoWindow: InfoWindow(
        title: widget.address,
        snippet: widget.postcode,
      ),
    );

    final resizedBytes = await _loadImageData(widget.image);
    final customMarker = MarkerData(
      marker: marker,
      child: _customMarker(resizedBytes, Constants().primaryColor),
    );

    setState(() {
      _customMarkers = [customMarker];
    });
  }

  Future<Uint8List> _loadImageData(String imagePath) async {
    if (imagePath.isEmpty) {
      // Load a local image instead
      final ByteData localImageData =
          await rootBundle.load('assets/carpark1.jpg');
      return localImageData.buffer.asUint8List();
    }

    try {
      final response = await http.get(Uri.parse(imagePath));
      final data = response.bodyBytes;
      final compressedData = await FlutterImageCompress.compressWithList(
        data,
        minHeight: 200,
        minWidth: 150,
        quality: 90,
      );
      return Uint8List.fromList(compressedData);
    } catch (e) {
      // Handle the exception and return an empty marker
      print('Error loading image: $e');
      return Uint8List(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    widget.startDateTime = roundToNearest15Minutes(widget.startDateTime);
    widget.endDateTime = roundToNearest15Minutes(widget.endDateTime);

    TextEditingController startDateController = TextEditingController(
      text: DateFormat('HH:mm dd MMM yy').format(widget.startDateTime),
    );
    TextEditingController endDateController = TextEditingController(
      text: DateFormat('HH:mm dd MMM yy').format(widget.endDateTime),
    );

    startDateController.text =
        DateFormat('HH:mm dd MMM yy').format(widget.startDateTime);
    endDateController.text =
        DateFormat('HH:mm dd MMM yy').format(widget.endDateTime);

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: CustomGoogleMapMarkerBuilder(
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
          ),
          Padding(
            padding: const EdgeInsets.all(6.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Text(
                              'Start',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            padding: EdgeInsets.symmetric(
                                vertical: 0, horizontal: 16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: startDateController,
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      // labelText: 'Start Date',
                                    ),
                                    onTap: () {
                                      DatePicker.showDateTimePicker(
                                        context,
                                        showTitleActions: true,
                                        minTime: DateTime.now(),
                                        maxTime: DateTime(2100),
                                        onChanged: (date) {},
                                        onConfirm: (date) {
                                          setState(() {
                                            widget.startDateTime = date;
                                            startDateController.text =
                                                DateFormat('HH:mm dd MMM yy')
                                                    .format(date);

                                            // Set the endDateTime as one hour after the startDateTime
                                            widget.endDateTime =
                                                date.add(Duration(hours: 1));
                                            endDateController.text =
                                                DateFormat('HH:mm dd MMM yy')
                                                    .format(widget.endDateTime);
                                          });
                                        },
                                        currentTime: widget.startDateTime,
                                        locale: LocaleType.en,
                                      );
                                    },
                                  ),
                                ),
                                Icon(Icons.keyboard_arrow_down),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8), // Adjust the spacing as desired
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Text(
                              'End',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            padding: EdgeInsets.symmetric(
                                vertical: 0, horizontal: 16),
                            child: Row(children: [
                              Expanded(
                                child: TextFormField(
                                  controller: endDateController,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    // labelText: 'End Date',
                                  ),
                                  onTap: () {
                                    DatePicker.showDateTimePicker(
                                      context,
                                      showTitleActions: true,
                                      minTime: DateTime.now(),
                                      maxTime: DateTime(2100),
                                      onChanged: (date) {},
                                      onConfirm: (date) {
                                        setState(() {
                                          widget.endDateTime = date;
                                          endDateController.text =
                                              DateFormat('HH:mm dd MMM yy')
                                                  .format(date);
                                        });
                                      },
                                      currentTime: widget.endDateTime,
                                      locale: LocaleType.en,
                                    );
                                  },
                                ),
                              ),
                              Icon(Icons.keyboard_arrow_down),
                            ]),
                          ),
                        ],
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
                  onPressed: isLoading ? null : onSubmit,
                  child: Text('Submit Booking'),
                ),
              ],
            ),
          ),
        ],
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

DateTime roundToNearest15Minutes(DateTime dateTime) {
  final minutes = dateTime.minute;
  final roundedMinutes = (minutes / 15).round() * 15;
  return DateTime(dateTime.year, dateTime.month, dateTime.day, dateTime.hour,
      roundedMinutes);
}
