import 'dart:developer';

import 'package:shared_preferences/shared_preferences.dart';

class Config {
  static const url = 'https://sanidsa.odoo.com/';
  static const database = 'odoozaly-sanid-main-19183474'; //internal_hr_uat_

  static loadConfigInfo() async {
    log('loadConfigInfo---------');
    var pref = await SharedPreferences.getInstance();
    var urlVar = pref.getString('url');
    var databaseVar = pref.getString('database');
    if (urlVar == '' || urlVar == null) {
      await pref.setString('url', url);
    }
    if (databaseVar == '' || databaseVar == null) {
      await pref.setString('database', database);
    }
  }
}
