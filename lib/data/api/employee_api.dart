import 'package:http/http.dart' as http;
import 'package:talent/data/database/dao/employee_dao.dart';
import 'package:talent/data/models/employee_children/employee_children.dart';
import 'dart:convert';
import 'dart:developer';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/employee/employee.dart';

class EmployeeAPI {
  var pref;
  var urlLink;
  var header_cookie;
  var database;
  int? uid;
  int? companyId;
  var employeeDao = EmployeeDao();
  List<Employee> employeeList = [];
  List<EmployeeChildren> employeeChildrenList = [];

  Future<dynamic> getEmployeeList() async {
    pref = await SharedPreferences.getInstance();
    urlLink = await pref.getString('url');
    header_cookie = await pref.getString('header_cookie');
    const database1 = 'odoozaly-sanid-stg-21897440';
    uid = await pref.getInt('uid');
    var insertResult;
    List<Map<String, dynamic>> listData = [];

    //var param = {"user_id": uid};
    var param = {"domain": "[('user_id','=',$uid)]"};
    await employeeDao.deleteEmployeeRecords();

    var url = Uri.parse(
      '$urlLink'
      'api/get/employees',
    );
    log('getEmployeeList URL: $url');
    log('getEmployeeList Header Cookie: $header_cookie');
    log('getEmployeeList Database: odoozaly-sanid-main-19183474');
    log('getEmployeeList Param: $param');

    await http
        .post(
          url,
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'cookie': header_cookie,
            'db': 'odoozaly-sanid-stg-21897440',
          },
          body: json.encode(param),
        )
        .then((res) async {
          if (res.statusCode == 200) {
            log('getEmployeeList Response: ${res.body}');
            Map<String, dynamic> result = json.decode(res.body);
            List list = result['result'];
            list.forEach((element) async {
              Employee employee = Employee(
                int.parse(element['employee_id'].toString()),
                element['employee_name'],
                element['employee_code'],
                '', //element['employee_type']
                element['job_name'],
                element['mobile_phone'],
                element['work_phone'],
                element['parent_id'] != false
                    ? int.parse(element['employee_id'].toString())
                    : 0,
                element['department_id'], //parent_id
                element['department_name'],
                element['gender'],
                element['birthday'],
                element['email'],
                element['user_id'],
                element['job_grade_name'], //element['reg_number']
                element['image'],
                0, // element['work_schedule_id']
                0,
                0,
                element['approval_level'],
                element['write_date'],
              );
              log('Employee: ${employee.toString()}');
              employeeList.add(employee);
            });

            insertResult = await employeeDao.insertEmployee(employeeList);
          } else {
            insertResult = 'Something Wrong';
          }
        })
        .catchError((e) {
          insertResult = e.toString();
        });
    return insertResult;
  }
}
