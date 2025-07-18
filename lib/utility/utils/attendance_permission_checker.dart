import 'dart:developer';

import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AttendanceChecker {
  double allowedDistanceInKm = 1.0; // You can adjust this value
  double targetLatitude = 37.4219983; // Set your target latitude
  double targetLongitude = -122.084; // Set your target longitude

  // Function to check permission and location
  Future<bool> checkAttendancePermission() async {
    // Request location permission

    bool isLocationEnabled = await _checkLocationPermission();
    var pref = await SharedPreferences.getInstance();

    var attDistanceTemp = pref.getString('attendanceDistance');
    var officeLatTemp = pref.getString('office_lat');
    var officeLongTemp = pref.getString('office_long');

    log('office----$officeLatTemp $officeLongTemp  : $attDistanceTemp');

    allowedDistanceInKm = double.parse(attDistanceTemp.toString()) / 1000;
    targetLatitude = double.parse(officeLatTemp.toString());
    targetLongitude = double.parse(officeLongTemp.toString());

    if (!isLocationEnabled) {
      log("Location permission not granted or GPS is off");
      return false;
    }

    log(
      'target----${targetLatitude} ${targetLongitude}  : ${allowedDistanceInKm}',
    );
    // Get user's current position
    Position userPosition = await Geolocator.getCurrentPosition(
      // ignore: deprecated_member_use
      desiredAccuracy: LocationAccuracy.high,
    );

    log(
      'userPosition---${userPosition.latitude}  ${userPosition.longitude}  : ${userPosition.toJson()}',
    );

    double distanceInKm = Geolocator.distanceBetween(
      targetLatitude,
      targetLongitude,
      userPosition.latitude,
      userPosition.longitude,
    );

    log('distanceInMeters---$distanceInKm');

    log('allowedDistanceInKm----------$allowedDistanceInKm  : $distanceInKm');

    // Check if within allowed distance
    if (distanceInKm / 1000 <= allowedDistanceInKm) {
      log("Within allowed distance: $distanceInKm km");
      return true; // Attendance permission granted
    } else {
      log("Outside allowed distance: $distanceInKm km");
      return false; // Attendance permission denied
    }
  }

  // Function to check location permission
  Future<bool> _checkLocationPermission() async {
    if (await Permission.location.isGranted) {
      return true;
    } else {
      var status = await Permission.location.request();
      return status.isGranted;
    }
  }
}
