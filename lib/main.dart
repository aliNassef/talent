import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:platform_device_id/platform_device_id.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'app/root.dart';
import 'utility/utils/share_component.dart';
import 'dart:async';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

final StreamController<String?> selectNotificationStream =
    StreamController<String?>.broadcast();

const String navigationActionId = 'id_3';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  sharePref = await SharedPreferences.getInstance();
  deviceIMEI = '111'; //await PlatformDeviceId.getDeviceId();
  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ar')],
      path: 'assets/traanslations',
      fallbackLocale: const Locale('en'),
      child: const Root(),
    ),
  );
}
