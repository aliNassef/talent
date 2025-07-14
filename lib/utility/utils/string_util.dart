// import 'package:intl/intl.dart';

// class StringUtils{
//   static String isStringNull(var obj) {
//     return obj == null? '' : obj.toString();
//   }

//   static int isIntNull(var obj) {
//     return obj == null? 0 : int.parse(obj.toString());
//   }

//   static double isDoubleNull(var obj) {
//     return obj == null? 0 : double.parse(obj.toString());
//   }

//   static bool isBooleanNull(var obj) {
//     return obj == null? false : obj.toString().toLowerCase() == 'true';
//   }

//   static String stringHourFormat(String millis) {
//     NumberFormat numberFormat =NumberFormat('##.##','en_US');
//     String workingHours = "";
//     List<String> hours = millis.split(".");
//     if(hours.length > 1) {
//       String hour = hours[0];
//       String min = '0.' +hours[1];
//       String minutes = '';
//       if(min == '0.0') {
//         minutes = '00';
//       }
//       minutes = numberFormat.format(double.parse(min) * 60);
//       if (double.parse(minutes) < 10) {
//         minutes = "0" + minutes;
//       }

//       workingHours = hour + ":" + minutes;
//     }
//     return workingHours;
//   }
// }