import 'dart:async';
import 'dart:developer';
import 'package:sqflite/sqflite.dart';

import '../../models/employee/employee.dart';
import '../db_provider.dart';

class EmployeeDao {
  //Employee
  final dbProvider = DatabaseProvider.db;

  Future<List<Employee>> getEmployeeList() async {
    print('getEmployeeList------------------------'); //To Remove log
    var db = await dbProvider.database;
    var result = await db!.rawQuery("SELECT * FROM employee ORDER BY id DESC");
    List<Employee> list = result.isNotEmpty
        ? result.map((u) => Employee.fromJson(u)).toList()
        : [];
    print('result ${result.toList()}'); //To Remove log
    return list;
  }

  Future<List<Employee>> getEmployeeListByDepartment(String department) async {
    print('getEmployeeList------------------------'); //To Remove log
    var db = await dbProvider.database;
    var result = await db!.rawQuery(
      "SELECT * FROM employee WHERE department_name = '$department' ORDER BY id DESC",
    );
    List<Employee> list = result.isNotEmpty
        ? result.map((u) => Employee.fromJson(u)).toList()
        : [];
    print('result ${result.toList()}'); //To Remove log
    return list;
  }

  Future<List<Employee>> getEmployeeListByDistinctDepartment() async {
    print('getEmployeeList------------------------'); //To Remove log
    var db = await dbProvider.database;
    var result = await db!.rawQuery(
      "SELECT * FROM employee GROUP BY department_name ORDER BY id DESC",
    );
    List<Employee> list = result.isNotEmpty
        ? result.map((u) => Employee.fromJson(u)).toList()
        : [];
    print('result ${result.toList()}'); //To Remove log
    return list;
  }

  Future<List<Employee>> getUnReadEmployeeList() async {
    print('getEmployeeList------------------------'); //To Remove log
    var db = await dbProvider.database;
    var result = await db!.rawQuery("SELECT * FROM employee WHERE isRead = 0");
    List<Employee> list = result.isNotEmpty
        ? result.map((u) => Employee.fromJson(u)).toList()
        : [];
    print('result ${result.toList()}'); //To Remove log
    return list;
  }

  Future<Employee> getSingleEmployeeById(int id) async {
    print('getSingleEmployee------ $id'); //To Remove log
    var db = await dbProvider.database;
    List<Map<String, Object?>> result;
    result = await db!.rawQuery("SELECT * FROM employee WHERE user_id = $id");
    log(result.toString());

    Employee employee = Employee.fromJson(result.toList()[0]);
    return employee;
  }

  Future insertEmployee(List<Employee> EmployeeList) async {
    print('insertEmployee-----$EmployeeList'); //To Remove log

    final db = await dbProvider.database;
    Batch batch = db!.batch();

    for (int i = 0; i < EmployeeList.length; i++) {
      batch.insert("employee", EmployeeList[i].toJson());
    }
    await batch.commit(noResult: true);

    return "success";
  }

  insertSingleEmployee(Employee employee) async {
    print('insertSingleEmployee------------- $employee'); //To Remove log
    final db = await dbProvider.database;
    final result = await db!.insert("employee", employee.toJson());
    print('result----------- $result'); //To Remove log
    return result;
  }

  updateEmployee(Employee employee) async {
    print('updateEmployee------${employee.toJson()}'); //To Remove log
    Database? db = await dbProvider.database;
    final result = await db!.update(
      'employee',
      employee.toJson(),
      where: "id = ?",
      whereArgs: [employee.id],
    );
    print("result******* $result"); //To Remove log
    return result;
  }

  Future<int> deleteEmployeeRecords() async {
    print('deleteEmployeeRecords-----------');
    Database? db = await dbProvider.database;
    var result = db!.rawDelete('Delete from employee');
    print('result-----$result');
    return result;
  }
}
