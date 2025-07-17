import 'dart:developer';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../database/db_provider.dart';

class loginAPI {
  var pref;
  var header_cookie;
  var database;

  Future<dynamic> login(
    String username,
    String password,
    String deviceId,
    String deviceImei,
    String deviceName,
    String deviceModel,
  ) async {
    pref = await SharedPreferences.getInstance();
    var urlLink = 'https://sanidsa.odoo.com/api/auth';
    database = 'odoozaly-sanid-main-19183474';
    String? loginResult;

    var url1 = Uri.parse('https://sanidsa.odoo.com/api/auth');

    final body = {
      'username': username,
      'password': password,
      'device_imei': deviceImei,
      'device_vals': json.encode({
        'device_id': deviceId,
        'name': deviceName,
        'device_model': deviceModel,
      }),
    };

    log('loginAPI URL: $url1');
    log(
      'loginAPI: $username, $password, $deviceId, $deviceImei, $deviceName, $deviceModel',
    ); 
    try {
      final response = await http.post(
        url1,
        body: body,
        headers: {'db': database},
      );
      log('loginAPI Response: \\${response.body}');
      if (response.statusCode == 200) {
        Map<String, dynamic> list = json.decode(response.body);
        var cookie = response.headers['set-cookie'];
        header_cookie = cookie.toString().split(';')[0];
        await pref!.setString('header_cookie', header_cookie);
        if (list["success"] == true) {
          loginResult = 'success';
          await pref.setString(
            'is_new_device',
            list['is_new_device'].toString(),
          );
          await pref.setString('token', list["token"]);
          await pref.setString('jwt_token', list["jwt_token"]);
          await pref!.setInt('uid', int.parse(list["user_id"].toString()));
          await pref!.setString('user_name', list["user_name"]);
          await pref!.setString('company_name', list["company_name"]);
          await pref!.setInt(
            'company_id',
            int.parse(list["company_id"].toString()),
          );
          await pref!.setString('image', list["image"]);
          await pref!.setInt(
            'department_id',
            int.parse(list["department_id"].toString()),
          );
          await pref!.setString('department_name', list["department_name"]);
          await DatabaseProvider.db.database;
        } else {
          var error = list["error"];
          loginResult = error.toString();
        }
      } else if (response.statusCode == 403) {
        loginResult = 'Credential Error';
      } else {
        loginResult = 'Failed to login: \\${response.body}';
      }
    } catch (err) {
      log('loginAPI Error: $err');
      loginResult = err.toString();
    }
    return loginResult;
  }

  Future<dynamic> checkDevice(var deviceId) async {
    var checkResult = '';
    pref = await SharedPreferences.getInstance();
    var urlLink = await pref.getString('url');
    database = await pref.getString('database');
    header_cookie = await pref.getString('header_cookie');
    var userId = await pref!.getInt('uid');
    var param = {"imei_code": deviceId, "user_id": userId};
    var url = Uri.parse(
      '$urlLink'
      'check/device',
    );
    await http
        .post(
          url,
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'db': database,
            'cookie': header_cookie,
          },
          body: json.encode(param),
        )
        .then((res) async {
          if (res.statusCode == 200) {
            Map<String, dynamic> result = json.decode(res.body);
            if (result['result']['success'] == true) {
              var deviceState = result['result']['state'];
              checkResult = deviceState;
            } else {
              var deviceState = result['result']['error'];
              checkResult = deviceState;
            }
          }
        })
        .catchError((e) {
          checkResult = e.toString();
        });

    return checkResult;
  }
}
