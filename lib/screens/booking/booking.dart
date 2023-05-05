import 'package:flutter/material.dart';

class BookingPage extends StatefulWidget {
  const BookingPage({Key? key, required this.cpsId}) : super(key: key);
  final String cpsId;
  @override
  _BookingPageState createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  late String _startDate;
  late String _startTime;
  late String _endDate;
  late String _endTime;

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Booking Page'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Start Date'),
              TextFormField(
                onSaved: (value) {
                  _startDate = value!;
                },
              ),
              SizedBox(height: 16.0),
              Text('Start Time'),
              TextFormField(
                onSaved: (value) {
                  _startTime = value!;
                },
              ),
              SizedBox(height: 16.0),
              Text('End Date'),
              TextFormField(
                onSaved: (value) {
                  _endDate = value!;
                },
              ),
              SizedBox(height: 16.0),
              Text('End Time'),
              TextFormField(
                onSaved: (value) {
                  _endTime = value!;
                },
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  _formKey.currentState?.save();
                  print('cpsId: ${widget.cpsId}');
                  print('Start Date: $_startDate');
                  print('Start Time: $_startTime');
                  print('End Date: $_endDate');
                  print('End Time: $_endTime');
                },
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
