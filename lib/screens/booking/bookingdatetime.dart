import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';
import 'package:sparepark/models/booking_model.dart';
import 'package:sparepark/shared/booking_db_helper.dart';

class BookingDateTime extends StatefulWidget {
  const BookingDateTime({Key? key, required this.cpsId}) : super(key: key);
  final String cpsId;
  @override
  _BookingDateTimeState createState() => _BookingDateTimeState();
}

class _BookingDateTimeState extends State<BookingDateTime> {
  DateTime? _selectedDateTimeStart;
  DateTime? _selectedDateTimeEnd;

  @override
  Widget build(BuildContext context) {
    print(widget.cpsId);

    return Scaffold(
      // appBar: AppBar(),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
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
                      // _selectedDateTimeStart = date;
                      _selectedDateTimeStart = roundToNearest15Minutes(date);
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
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedDateTimeStart != null
                          ? DateFormat('HH:mm dd MMM yy').format(
                              roundToNearest15Minutes(_selectedDateTimeStart!))
                          : "Select a date and time",
                    ),
                    Icon(Icons.keyboard_arrow_down),
                  ],
                ),
              ),
            ),
            SizedBox(width: 16),
            GestureDetector(
              onTap: () {
                if (_selectedDateTimeStart == null) {
                  return;
                }
                DatePicker.showDateTimePicker(
                  context,
                  showTitleActions: true,
                  minTime: _selectedDateTimeStart!.subtract(Duration(days: 5)),
                  maxTime: _selectedDateTimeStart!.add(Duration(days: 325)),
                  onConfirm: (date) {
                    if (date.isBefore(_selectedDateTimeStart!)) {
                      date = _selectedDateTimeStart!;
                    }
                    setState(() {
                      // Round the selected date time to the nearest 15 minutes
                      _selectedDateTimeEnd = roundToNearest15Minutes(date);
                      print(
                          "End Date Time: ${_selectedDateTimeEnd.toString()}");
                    });

                    // Save to the database when the end date time is selected
                    final bookingModel = BookingModel(
                      b_total: 25,
                      end_date_time: _selectedDateTimeEnd!,
                      p_id: '',
                      reg_date: null,
                      start_date_time: _selectedDateTimeStart!,
                    );
                    DB_Booking.create(bookingModel);
                  },
                  currentTime: _selectedDateTimeEnd ?? _selectedDateTimeStart!,
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(5),
                ),
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedDateTimeEnd != null
                          ? DateFormat('HH:mm dd MMM yy').format(
                              roundToNearest15Minutes(_selectedDateTimeEnd!))
                          : "Select a date and time",
                    ),
                    Icon(Icons.keyboard_arrow_down),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  DateTime roundToNearest15Minutes(DateTime dateTime) {
    final minutes = dateTime.minute;
    final roundedMinutes = (minutes / 15).round() * 15;
    return DateTime(dateTime.year, dateTime.month, dateTime.day, dateTime.hour,
        roundedMinutes);
  }
}
