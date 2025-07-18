import 'dart:developer';

import 'package:intl/intl.dart';

class DateUtil {
  getDateFormat(DateTime dateTime) {
    DateFormat formatter = DateFormat('EEEE, MMM d y');
    String formatted = formatter.format(dateTime);
    log(formatted);
    return formatted;
  }

  getOvertimeDateFormat() {
    var df = DateFormat("EEE, d MMM yyyy HH:mm:ss z");
    var date = df.parse("Tue, 15 Nov 1994 08:12:31 PST");
    log(df.format(date));
  }

  getCurrentDate() {
    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final String formatted = formatter.format(now);
    return formatted;
  }

  getChosenDate(DateTime dateTime) {
     final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final String formatted = formatter.format(dateTime);
    return formatted;
  }

  getTodayDate() {
    var now =   DateTime.now();
    var formatter = DateFormat('yyyy-MM-dd');
    String formattedDate = formatter.format(now);
    return formattedDate;
  }

  getTodayDateDMY() {
    var now = DateTime.now();
    var formatter = DateFormat('dd-MM-yyyy');
    String formattedDate = formatter.format(now);
    return formattedDate;
  }

  getSqlDateTime(DateTime? date, String dateFormat) {
    String dateStr = '';
    if (date != null) {
      var formatter = DateFormat(dateFormat);
      dateStr = formatter.format(date);
    }
    return dateStr;
  }

  calculateWorkingHours(String startTime, String endTime) {
    NumberFormat numberFormat = NumberFormat('#', 'en_US');
    String workingHours = "";
    String mills = (double.parse(endTime) - double.parse(startTime)).toString();
    List<String> hours = mills.split(".");

    if (hours.length > 1) {
      String hour = hours[0];
      String min = "0.${hours[1]}";
      String minutes = numberFormat.format(double.parse(min) * 60);
      workingHours = "$hour:$minutes";
    }

    return workingHours;
  }

  convertToDMY(String dateStr) {
    DateTime dateTime = DateTime.parse(dateStr);
    DateFormat format = DateFormat('dd-MM-yyyy');
    return format.format(dateTime);
  }
}
