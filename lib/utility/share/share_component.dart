import 'dart:async';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class ShareComponentClass {
  InternetConnectionStatus? connection_status;
  late DeviceInfoPlugin deviceInfoPlugin;
  late AndroidDeviceInfo androidDeviceInfo;

  Future<AndroidDeviceInfo> readDeviceId() async {
    print('readDeviceId----------');
    deviceInfoPlugin = DeviceInfoPlugin();
    androidDeviceInfo = await deviceInfoPlugin.androidInfo;
    print(
      'androidDeviceInfo----------$androidDeviceInfo  : ${androidDeviceInfo.id}',
    );

    // deviceIdentifier = androidDeviceInfo.androidId;
    return androidDeviceInfo;
  }
}
