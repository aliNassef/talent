import 'dart:async';
import 'package:sqflite/sqflite.dart';

import '../../models/attendance/attendance.dart';
import '../db_provider.dart';

class AttendanceDao {
  //Attendance
  final dbProvider = DatabaseProvider.db;

  Future<List<Attendance>> getAttendanceList() async {
    print('getAttendanceList------------------------'); //To Remove log
    var db = await dbProvider.database;
    var result =
        await db!.rawQuery("SELECT * FROM attendance ORDER BY id ASC");
    List<Attendance> list = result.isNotEmpty
        ? result.map((u) => Attendance.fromJson(u)).toList()
        : [];
    print('result ${result.toList()}'); //To Remove log
    return list;
  }

  Future<Attendance> getSingleAttendanceById(int id) async {
    print('getSingleAttendance------ $id'); //To Remove log
    var db = await dbProvider.database;
    var result;
    result = await db!.rawQuery("SELECT * FROM attendance WHERE id = $id");

    print('result ${result.toList()}'); //To Remove log
    Attendance attendance = Attendance.fromJson(result.toList()[0]);
    return attendance;
  }

  Future<dynamic> getTodayAttendance(String date) async {
    print('getTodayAttendance------------------------'); //To Remove log
    var db = await dbProvider.database;
    var result =
        await db!.rawQuery("SELECT * FROM attendance WHERE date = '$date'");
    List<Attendance> list = result.isNotEmpty
        ? result.map((u) => Attendance.fromJson(u)).toList()
        : [];
    print('list --------${list}'); //To Remove log
    if (list == [] || list.length <= 0)
      return null;
    else {
      Attendance attendance = list[0];
      return attendance;
    }
  }

  Future<dynamic> getTodayAttendanceCheckForCheckIn(String date) async {
    print('getTodayAttendance------------------------'); //To Remove log
    var db = await dbProvider.database;
    var result = await db!.rawQuery(
        "SELECT * FROM attendance WHERE date = '$date' AND check_in_datetime != '' ");
    List<Attendance> list = result.isNotEmpty
        ? result.map((u) => Attendance.fromJson(u)).toList()
        : [];
    print('list --------${list}'); //To Remove log
    if (list == [] || list.length <= 0)
      return null;
    else {
      Attendance attendance = list[0];
      return attendance;
    }
  }

  Future<dynamic> getTodayAttendanceAlreadyCheckIn(String date) async {
    print('getTodayAttendance------------------------'); //To Remove log
    var db = await dbProvider.database;
    var result = await db!.rawQuery(
        "SELECT * FROM attendance WHERE date = '$date' AND check_in_datetime != '' AND check_out_datetime == '' ");
    List<Attendance> list = result.isNotEmpty
        ? result.map((u) => Attendance.fromJson(u)).toList()
        : [];
    print('list --------${list}'); //To Remove log
    if (list == [] || list.length <= 0)
      return null;
    else {
      Attendance attendance = list[0];
      return attendance;
    }
  }

  // Future<Attendance?> getTodayAttendance(String date) async {
  //   print('getSingleAttendance------ $date'); //To Remove log
  //   Attendance? attendance;
  //   var db = await dbProvider.database;
  //   var result;
  //   result =
  //       await db!.rawQuery("SELECT * FROM attendance WHERE date = '$date'");

  //   print(
  //       'result list ${result.toList()} : ${result.toList().runtimeType.toString()}'); //To Remove log
  //   print(
  //       'result ${result} : ${result.runtimeType.toString()}'); //To Remove log
  //   List list = [];
  //   list = result;
  //   print('list---$list');
  //   if (list.length <= 0) {
  //     print('if------');
  //     attendance = null;
  //   } else {
  //     print('else------');
  //     attendance = Attendance.fromJson(list[0]);
  //     // attendance = Attendance.fromJson(result.toList()[0]);
  //   }

  //   return attendance;
  // }

  Future insertAttendance(List<Attendance> AttendanceList) async {
    print('insertAttendance-----$AttendanceList'); //To Remove log

    final db = await dbProvider.database;
    Batch batch = db!.batch();

    for (int i = 0; i < AttendanceList.length; i++) {
      batch.insert("attendance", AttendanceList[i].toJson());
    }
    await batch.commit(noResult: true);

    return "success";
  }

  insertSingleAttendance(Attendance Attendance) async {
    print('insertSingleAttendance------------- $Attendance'); //To Remove log
    final db = await dbProvider.database;
    final result = await db!.insert("attendance", Attendance.toJson());
    print('result----------- $result'); //To Remove log
    return result;
  }

  updateAttendance(Attendance Attendance) async {
    print('updateAttendance------${Attendance.toJson()}'); //To Remove log
    Database? db = await dbProvider.database;
    final result = await db!.update(
      'attendance',
      Attendance.toJson(),
      where: "id = ?",
      whereArgs: [Attendance.id],
    );
    print("result******* $result"); //To Remove log
    return result;
  }

  Future<int> deleteAttendanceRecords() async {
    print('deleteAttendanceRecords-----------');
    Database? db = await dbProvider.database;
    var result = db!.rawDelete('Delete from attendance');
    print('result-----$result');
    return result;
  }
}
