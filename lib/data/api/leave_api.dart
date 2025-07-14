import 'package:easy_localization/easy_localization.dart';
import 'package:http/http.dart' as http;
import 'package:talent/data/database/dao/holiday_dao.dart';
import 'package:talent/data/database/dao/leave_reason_dao.dart';
import 'package:talent/data/database/dao/leave_remain.dart';
import 'package:talent/data/database/dao/leave_type_dao.dart';
import 'package:talent/data/models/leave/leave.dart';
import 'package:talent/data/models/leave_remain/leave_remain.dart';
import 'package:talent/data/models/leave_type/leave_type.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/dao/leave_dao.dart';
import '../models/holiday/holiday.dart';
import '../models/leave_reason/leave_reason.dart';

class LeaveAPI {
  var pref;
  var urlLink;
  var header_cookie;
  var database;
  int? uid;
  int? companyId;
  var leaveDao = LeaveDao();
  var leaveTypeDao = LeaveTypeDao();
  var leaveRemainDao = LeaveRemainDao();
  var leaveReasonDao = LeaveReasonDao();
  var holidayDao = HolidayDao();

  Future<dynamic> getLeaveList() async {
    pref = await SharedPreferences.getInstance();
    urlLink = await pref.getString('url');
    header_cookie = await pref.getString('header_cookie');
    database = await pref.getString('database');
    uid = await pref.getInt('uid');
    var insertResult;
    List<Map<String, dynamic>> listData = [];
    List<Leave> leaveList = [];

    //var param = {"user_id": uid};
    var param;
    
    var url = Uri.parse('$urlLink' + 'api/get/leave');
    await leaveDao.deleteLeaveRecords();

    param = {"domain": "[('user_id','=',$uid)]", "month": 2};

    try {
      var res = await http.post(url,
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'cookie': header_cookie,
            'db_name': database,
          },
          body: json.encode(param));
      if (res.statusCode == 200) {
        Map<String, dynamic> result = json.decode(res.body);
      

        List list = result['result'];

        for (var element in list) {
          Leave leave = Leave(
              int.parse(element['id'].toString()),
              element['name'],
              element['state'],
              int.parse(element['user_id'].toString()),
              int.parse(element['holiday_status_id'].toString()),
              element['leave_type_name'],
              int.parse(element['employee_id'].toString()),
              0, //department_id
              element['request_date'],
              element['date_from'],
              element['date_to'],
              double.parse(element['number_of_days'].toString()),
              element['request_date_from'],
              element['request_date_to'],
              0, //hiddenStateId
              '', //request_date_from_period
              element['request_unit_half'] == true ? 1 : 0,
              '', //holiday_type
              0,
              0, //leave reason Id
              element['reason_type'],
              element['emergency_contact'],
              element['pending-tasks'],
              element['employee_name'],
              '', //previous_timeoff
              element['previous_timeoff_duration'].toString(),
              element['name'],
              0, //approveById
              '', //approveByName
              '',
              element['write_date'],
              '',
              '');

          leaveList.add(leave);
        }

        insertResult = await leaveDao.insertLeave(leaveList); //success
      } else {
        insertResult = 'Something Wrong';
      }
    } catch (err) {
      insertResult = err.toString();
      // you can show error alert here
    }

    return insertResult;
  }

  Future<dynamic> getLeaveTypeList() async {
    List<LeaveType> leaveTypeList = [];
    pref = await SharedPreferences.getInstance();
    urlLink = await pref.getString('url');
    header_cookie = await pref.getString('header_cookie');
    database = await pref.getString('database');
    uid = await pref.getInt('uid');
    var insertResult;
    List<Map<String, dynamic>> listData = [];
    List<Leave> leaveList = [];
    var param = {"user_id": uid};
    await leaveTypeDao.deleteLeaveTypeRecords();

    var url = Uri.parse('$urlLink' + 'api/get/leave_type');
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

         for (var element in list) {
          LeaveType leaveType = LeaveType(
              int.parse(element['leave_type_id'].toString()),
              element['name'],
              0,
              //int.parse(element['company_id'].toString()),
              0,
              //int.parse(element['responsible_id'].toString()),
              element['unpaid'] == true ? 1 : 0,
              double.parse(element['number_of_days'].toString()),
              element['request_unit'],
              element['holiday_type'],
              ''
              //element['leave_type_code']
              );
          leaveTypeList.add(leaveType);
        }

    

        insertResult = await leaveTypeDao.insertLeaveType(leaveTypeList);
      } else {
        insertResult = 'Something Wrong';
      }
    }).catchError((e) {
      insertResult = e.toString();
    });
    return insertResult;
  }

  Future<dynamic> getLeaveRemainingList() async {
    pref = await SharedPreferences.getInstance();
    urlLink = await pref.getString('url');
    header_cookie = await pref.getString('header_cookie');
    database = await pref.getString('database');
    uid = await pref.getInt('uid');
    var insertResult;
    List<Map<String, dynamic>> listData = [];
    List<Leave> leaveList = [];
    List<LeaveRemain> leaveRemainList = [];
    var param = {"user_id": uid};
    await leaveRemainDao.deleteLeaveRemainRecords();
    var url = Uri.parse('$urlLink' + 'api/get/remaining_days');
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
        List list = result['result'];

        // if (list.length > 0) {

        // }

        list.forEach((element) {
          LeaveRemain leaveRemain = LeaveRemain(
              int.parse(element['id'].toString()),
              element['name'],
              double.parse(element['remaining_days'].toString()),
              element['code'],
              double.parse(element['total_days'].toString()));
          leaveRemainList.add(leaveRemain);
        });

        insertResult = await leaveRemainDao.insertLeaveRemain(leaveRemainList);
      } else {
        insertResult = 'Something Wrong';
      }
    }).catchError((e) {
      insertResult = e.toString();
    });
    return insertResult;
  }

  Future<dynamic> getUpcomingHolidayList() async {
    List<Holiday> holidayList = [];
    pref = await SharedPreferences.getInstance();
    urlLink = await pref.getString('url');
    header_cookie = await pref.getString('header_cookie');
    database = await pref.getString('database');
    uid = await pref.getInt('uid');
    var insertResult;
    var todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    List<Map<String, dynamic>> listData = [];
    List<Leave> leaveList = [];
    // var param = {"user_id": uid,"domain":('date_from','>=',today_date)};

    // var param = {"domain": "[('date_from','>=',\"${todayDate.toString()}\")]"};

    var param = {"employee_id": uid};
    await holidayDao.deleteHolidayRecords();

    var url = Uri.parse('$urlLink' + 'api/get/public_holidays');
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

        list.forEach((element) {
          Holiday holiday = Holiday(
              int.parse(element['id'].toString()),
              element['holiday_name'],
              element['date_from'],
              element['date_to'],
              element['date_to']);
          holidayList.add(holiday);
        });

        insertResult = await holidayDao.insertHoliday(holidayList);
      } else {
        insertResult = 'Something Wrong';
      }
    }).catchError((e) {
      insertResult = e.toString();
    });
    return insertResult;
  }

  var createResult;
  Future<dynamic> createLeaveRequest(Leave leave) async {
    pref = await SharedPreferences.getInstance();
    urlLink = await pref.getString('url');
    header_cookie = await pref.getString('header_cookie');
    database = await pref.getString('database');
    uid = await pref.getInt('uid');
    var url = Uri.parse('$urlLink' + 'api/create/leave');
    var param = {
      "holiday_status_id": leave.holiday_status_id,
      "request_date_from": leave.request_date_from,
      "request_date_to": leave.request_unit_half == 1
          ? leave.request_date_from
          : leave.request_date_to,
      "request_unit_half": leave.request_unit_half == 1 ? true : false,
      "request_date_from_period": leave.request_date_from_period,
      "number_of_days":
          leave.request_unit_half == 1 ? 0.5 : leave.number_of_days,
      //"emergency_contact": "vvhj",
       //"name": leave.reason,
      "private_name": leave.reason,
      "employee_id": leave.employee_id,
      "medical_document": false
    };
    var response = await http
        .post(url,
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
              'cookie': header_cookie,
              'db_name': database,
            },
            body: json.encode(param))
        .then((response) {
      if (response.statusCode == 200) {
        Map<String, dynamic> result = json.decode(response.body);
        if (result['result']['success'] == true) {
          var leave_id = result['result']['leave_id'];
          var message = result['result']['message'];
          createResult = {
            'result': 'success',
            'leave_id': int.parse(leave_id.toString()),
            'message': message,
          };
        } else if (result['result']['success'] == false) {
          var message = result['result']['message'];

          createResult = {
            'result': 'fail',
            'leave_id': null,
            'message': message,
          };
        } else {
          var leave_id = result['result']['leave_id'];
          var message = result['result']['error'];
          createResult = {
            'result': 'fail',
            'leave_id': null,
            'message': message,
          };
        }
      } else {
        createResult = {
          'result': 'fail',
          'leave_id': null,
          'message': response.statusCode.toString(),
        };
      }
    }).catchError((e) {
      createResult = {
        'result': 'fail',
        'leave_id': null,
        'message': e.toString(),
      };
    });

    return createResult;
  }
}
