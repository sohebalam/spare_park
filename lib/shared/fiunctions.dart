DateTime roundToNearest15Minutes(DateTime dateTime) {
  final minutes = dateTime.minute;
  final roundedMinutes = (minutes / 15).round() * 15;
  return DateTime(dateTime.year, dateTime.month, dateTime.day, dateTime.hour,
      roundedMinutes);
}

String formatDateTime(DateTime dateTime) {
  String day = dateTime.day.toString().padLeft(2, '0');
  String month = dateTime.month.toString().padLeft(2, '0');
  String year = dateTime.year.toString();
  String hour = dateTime.hour.toString().padLeft(2, '0');
  String minute = dateTime.minute.toString().padLeft(2, '0');
  return '$day/$month/$year $hour:$minute';
}
