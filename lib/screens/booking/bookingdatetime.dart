import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';
import 'package:sparepark/models/booking_model.dart';
import 'package:sparepark/shared/booking_db_helper.dart';

DateTime roundToNearest15Minutes(DateTime dateTime) {
  final minutes = dateTime.minute;
  final roundedMinutes = (minutes / 15).round() * 15;
  return DateTime(dateTime.year, dateTime.month, dateTime.day, dateTime.hour,
      roundedMinutes);
}

class BookingDateTime extends StatefulWidget {
  const BookingDateTime({Key? key, required this.cpsId}) : super(key: key);
  final String cpsId;

  @override
  _BookingDateTimeState createState() => _BookingDateTimeState();
}

class _BookingDateTimeState extends State<BookingDateTime> {
  DateTime? _selectedDateTimeStart;
  DateTime? _selectedDateTimeEnd;
  double _hourlyRate = 10;

  double get total {
    if (_selectedDateTimeStart != null && _selectedDateTimeEnd != null) {
      final hours =
          _selectedDateTimeEnd!.difference(_selectedDateTimeStart!).inHours;
      return hours * _hourlyRate;
    } else {
      return 0;
    }
  }

  void onSubmit() async {
    if (_selectedDateTimeStart != null && _selectedDateTimeEnd != null) {
      // Create a new booking model object
      final id = FirebaseFirestore.instance.collection('bookings').doc().id;
      BookingModel booking = BookingModel(
        b_id: id,
        p_id: widget.cpsId,
        u_id: "123",
        start_date_time: _selectedDateTimeStart,
        end_date_time: _selectedDateTimeEnd,
        b_total: total,
        reg_date: DateTime.now(),
      );

      // Add the booking to Firebase
      await FirebaseFirestore.instance
          .collection('bookings')
          .add(booking.toJson());

      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Booking created successfully'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    print(widget.cpsId);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      DatePicker.showDateTimePicker(
                        context,
                        showTitleActions: true,
                        minTime: DateTime.now().subtract(Duration(days: 5)),
                        maxTime: DateTime.now().add(Duration(days: 325)),
                        onConfirm: (date) {
                          if (_selectedDateTimeEnd != null &&
                              date.isAfter(_selectedDateTimeEnd!)) {
                            date = _selectedDateTimeEnd!;
                          }
                          setState(() {
                            _selectedDateTimeStart =
                                roundToNearest15Minutes(date);
                            print(
                                "Start Date Time: ${_selectedDateTimeStart.toString()}");
                          });
                        },
                        currentTime: _selectedDateTimeStart ?? DateTime.now(),
                      );
                    },
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
                            _selectedDateTimeStart != null
                                ? DateFormat('HH:mm dd MMM yy').format(
                                    roundToNearest15Minutes(
                                        _selectedDateTimeStart!))
                                : "Select a date and time",
                          ),
                          Icon(Icons.keyboard_arrow_down),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (_selectedDateTimeStart == null) {
                        return;
                      }
                      DatePicker.showDateTimePicker(
                        context,
                        showTitleActions: true,
                        minTime:
                            _selectedDateTimeStart!.subtract(Duration(days: 5)),
                        maxTime:
                            _selectedDateTimeStart!.add(Duration(days: 325)),
                        onConfirm: (date) {
                          if (date.isBefore(_selectedDateTimeStart!)) {
                            date = _selectedDateTimeStart!;
                          }
                          setState(() {
                            _selectedDateTimeEnd =
                                roundToNearest15Minutes(date);
                            print(
                                "End Date Time: ${_selectedDateTimeEnd.toString()}");
                          });
                        },
                        currentTime:
                            _selectedDateTimeEnd ?? _selectedDateTimeStart!,
                      );
                    },
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
                            _selectedDateTimeEnd != null
                                ? DateFormat('HH:mm dd MMM yy').format(
                                    roundToNearest15Minutes(
                                        _selectedDateTimeEnd!))
                                : "Select a date and time",
                          ),
                          Icon(Icons.keyboard_arrow_down),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text('Total: £$total'),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: onSubmit,
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
