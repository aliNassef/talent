import 'package:floor/floor.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:talent/data/database/dao/attendance_dao.dart';
import 'package:talent/data/models/attendance/attendance.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer';

class AttendanceAPI {
  var pref;
  var urlLink;
  var header_cookie;
  var database;
  var username;
  int? uid;
  int? companyId;
  var attendanceDao = AttendanceDao();

  Future<dynamic> getAttendanceList(int empId) async {
   
    pref = await SharedPreferences.getInstance();
    urlLink = await pref.getString('url');
    header_cookie = await pref.getString('header_cookie');
    database = await pref.getString('database');
    uid = await pref.getInt('uid');
    username = await pref.getString('user_name');
   
    var insertResult;
    List<Map<String, dynamic>> listData = [];
    List<Attendance> attendanceList = [];

    var param = {"domain": "[('employee_id','=',$empId)]", "month": 2};
    print(
        'header_cookie : $header_cookie : database : $database  : uid : $uid');
    await attendanceDao.deleteAttendanceRecords();

    var url = Uri.parse('$urlLink/api/get/attendance');
    await http
        .post(url,
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
              'cookie': header_cookie,
              'db': database,
            },
            body: json.encode(param))
        .then((res) async {
      if (res.statusCode == 200) {
        log(res.body);
        Map<String, dynamic> result = json.decode(res.body);
        List list = result['result'];
        //await attendanceDao.deleteAttendanceRecords();

        // if(list.isNotEmpty){
        //   await attendanceDao.deleteAttendanceRecords();
        // }

        for (var element in list) {
          Attendance attendance = Attendance(
              int.parse(element['id'].toString()),
              username,
              0,
              element['user_id'],
              element['date'],
              element['check_in_datetime'],
              element['check_out_datetime'],
              element['check_in_time'],
              element['check_out_time'],
              element['worked_hours'],
              0,
              0,
              0,
              0,
              '',
              '',
              '',
              '',
              element['write_date'],
              '',
              '',
              '');

          attendanceList.add(attendance);
        }

        insertResult = await attendanceDao.insertAttendance(attendanceList);
      } else {
        insertResult = 'Something Wrong';
      }
    }).catchError((e) {
      log(e.toString());
      insertResult = e.toString();
    });
    return insertResult;
  }

  Future<dynamic> getAttendanceSetting(int empId) async {
    pref = await SharedPreferences.getInstance();
    urlLink = await pref.getString('url');
    header_cookie = await pref.getString('header_cookie');
    database = await pref.getString('database');
    uid = await pref.getInt('uid');
    username = await pref.getString('user_name');
    var insertResult;
    List<Map<String, dynamic>> listData = [];
    List<Attendance> attendanceList = [];

    //  var param = {"domain": "[('employee_id','=',$empId)]", "month": 12};
    var url = Uri.parse('$urlLink' + 'api/get/attendance_setting');
    await http
        .post(url,
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
              'cookie': header_cookie,
              'db_name': database,
            },
            body: json.encode({}))
        .then((res) async {
      if (res.statusCode == 200) {
        Map<String, dynamic> result = json.decode(res.body);
        var distanceTemp = result['result']["records"]['map_distance'];
        double distance = double.parse(distanceTemp.toString());
        // print('insertRes-----------$insertResult');
        await pref.setString('attendanceDistance',
            result['result']["records"]['map_distance'].toString());
        await pref.setString(
            'office_lat', result['result']["records"]['latitude'].toString());
        await pref.setString(
            'office_long', result['result']["records"]['longitude'].toString());
      } else {
        insertResult = 'Something Wrong';
      }
    }).catchError((e) {
      insertResult = e.toString();
    });
    return insertResult;
  }

  Future<dynamic> getAttendanceListByFilter(
      String filterType, String startDate, String endDate) async {
    pref = await SharedPreferences.getInstance();
    urlLink = await pref.getString('url');
    header_cookie = await pref.getString('header_cookie');
    database = await pref.getString('database');
    uid = await pref.getInt('uid');
    username = await pref.getString('user_name');
    var insertResult;
    List<Map<String, dynamic>> listData = [];
    List<Attendance> attendanceList = [];

    var param = {
      "user_id": uid,
      "filter_type": '$filterType',
      'start_date': startDate,
      'end_date': endDate
    };
    await attendanceDao.deleteAttendanceRecords();

    var url = Uri.parse('$urlLink' + 'api/get/attendance_filter');
    await http
        .post(url,
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
              'cookie': header_cookie,
              'db_name': database,
            },
            body: json.encode(param))
        .then((res) async {
      if (res.statusCode == 200) {
        Map<String, dynamic> result = json.decode(res.body);
        List list = result['result'];
        int i = 1;

        list.forEach((element) {
          Attendance attendance = Attendance(
              int.parse(element['id'].toString()),
              username,
              0,
              element['user_id'],
              element['date'],
              element['check_in_datetime'],
              element['check_out_datetime'],
              element['check_in_time'],
              element['check_out_time'],
              element['worked_hours'],
              0,
              0,
              0,
              0,
              '',
              '',
              '',
              '',
              element['write_date'],
              '',
              '',
              '');

          attendanceList.add(attendance);
          i++;
        });

        insertResult = await attendanceDao.insertAttendance(attendanceList);
      } else {
        insertResult = 'Something Wrong';
      }
    }).catchError((e) {
      insertResult = e.toString();
    });
    return insertResult;
  }

  var createResult;
  Future<dynamic> createAttendance(Attendance attendance, var qrCode) async {
    pref = await SharedPreferences.getInstance();
    urlLink = await pref.getString('url');
    header_cookie = await pref.getString('header_cookie');
    database = await pref.getString('database');
    uid = await pref.getInt('uid');
    var url = Uri.parse('$urlLink' + 'api/create/attendance');
    var param = {
      "employee_id": attendance.employee_id,
      "check_in": attendance.check_in_datetime.toString(),
      "remarks": attendance.reason,
      "device_id": attendance.device_id,
      "in_latitude": attendance.in_latitude,
      "in_longitude": attendance.in_longitude,
    };
    var response = await http
        .post(url,
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
              'cookie': header_cookie,
              'db_name': database,
              // 'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: json.encode(param))
        .then((response) {
      if (response.statusCode == 200) {
        Map<String, dynamic> result = json.decode(response.body);
        if (result['result']['success'] == true) {
          var attendance_id = result['result']['attendance_id'];
          var message = result['result']['attendance_message'];
          createResult = {
            'result': 'success',
            'attendanceId': int.parse(attendance_id.toString()),
            'attendanceMessage': message,
          };
        } else {
          // var attendance_id = result['result']['attendance_id'];
          // var message = result['result']['error'];
          var message = result['result']['message'];
        
          createResult = {
            'result': 'fail',
            'attendanceId': null,
            'attendanceMessage': result['result']['message'],
          };
        }
      } else {
        createResult = {
          'result': 'fail',
          'attendanceId': null,
          'attendanceMessage': response.statusCode.toString(),
        };
      }
    }).catchError((e) {
      createResult = {
        'result': 'fail',
        'attendanceId': null,
        'attendanceMessage': e.toString() +
            ' \n \n Please check whether did you check out last day.',
      };
    });

    return createResult;
  }

  var updateResult;
  Future<dynamic> checkOutAttendance(Attendance attendance, var qrCode) async {
    pref = await SharedPreferences.getInstance();
    urlLink = await pref.getString('url');
    header_cookie = await pref.getString('header_cookie');
    database = await pref.getString('database');
    uid = await pref.getInt('uid');
    var url = Uri.parse('$urlLink' + 'api/update/attendance');
    // var attendanceId = await pref.getInt('attendanceId');

    var param = {
      "check_out": attendance.check_out_datetime.toString(),
      "attendance_id": attendance.attendanceId,
      'remarks': attendance.reason,
      "out_latitude": attendance.out_latitude,
      "out_longitude": attendance.out_longitude,
    };
    // return;

    var response = await http
        .post(url,
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
              'cookie': header_cookie,
              'db_name': database,
              // 'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: json.encode(param))
        .then((response) {
      if (response.statusCode == 200) {
        Map<String, dynamic> result = json.decode(response.body);
        if (result['result']['success'] == true) {
          var attendance_id = result['result']['attendance_id'];
          var message = result['result']['attendance_message'];
          updateResult = {
            'result': 'success',
            'attendanceId': int.parse(attendance_id.toString()),
            'attendanceMessage': message,
          };

          // var insertResult = customerDao.insertSingleCustomer(customerObj);
        } else {
          var message = result['result']['error'];
          updateResult = {
            'result': 'fail',
            'attendanceId': null,
            'attendanceMessage': message,
          };
        }
      } else {
        updateResult = {
          'result': 'fail',
          'attendanceId': null,
          'attendanceMessage': response.statusCode.toString(),
        };
      }
    }).catchError((e) {
      updateResult = {
        'result': 'fail',
        'attendanceId': null,
        'attendanceMessage': e.toString(),
      };
    });

    return updateResult;
  }
}
