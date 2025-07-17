import 'dart:async';
import 'dart:developer';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class ShareComponentClass {
  InternetConnectionStatus? connectionStatus;
  late DeviceInfoPlugin deviceInfoPlugin;
  late AndroidDeviceInfo androidDeviceInfo;

  Future<AndroidDeviceInfo> readDeviceId() async {
    log('readDeviceId----------');
    deviceInfoPlugin = DeviceInfoPlugin();
    androidDeviceInfo = await deviceInfoPlugin.androidInfo;
    log(
      'androidDeviceInfo----------$androidDeviceInfo  : ${androidDeviceInfo.id}',
    );
    return androidDeviceInfo;
  }
}
