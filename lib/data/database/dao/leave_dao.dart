import 'dart:async';
import 'package:sqflite/sqflite.dart';

import '../../models/leave/leave.dart';
import '../db_provider.dart';

class LeaveDao {
  //Leave
  final dbProvider = DatabaseProvider.db;

  Future<List<Leave>> getLeaveList() async {
    print('getLeaveList------------------------'); //To Remove log
    var db = await dbProvider.database;
    var result = await db!.rawQuery("SELECT * FROM leave ORDER BY id ASC");
    List<Leave> list =
        result.isNotEmpty ? result.map((u) => Leave.fromJson(u)).toList() : [];
    print('result ${result.toList()}'); //To Remove log
    return list;
  }

  Future<List<Leave>> getLeaveListByUserId(int userId) async {
    print('getLeaveListByUserId------------------------'); //To Remove log
    var db = await dbProvider.database;
    var result = await db!.rawQuery(
        "SELECT * FROM leave WHERE user_id = $userId  ORDER BY id DESC");
    List<Leave> list =
        result.isNotEmpty ? result.map((u) => Leave.fromJson(u)).toList() : [];
    // print(
    //     'result ${result.toList()} length: ${result.toList().length}} '); //To Remove log
    return list;
  }

  Future<List<Leave>> getLeaveListByUserAndEmpId(int userId, int empId) async {
    print('getLeaveListByUserId------------------------'); //To Remove log
    var db = await dbProvider.database;
    var result = await db!.rawQuery(
        "SELECT * FROM leave WHERE user_id = $userId AND employee_id = $empId ORDER BY id DESC");
    List<Leave> list =
        result.isNotEmpty ? result.map((u) => Leave.fromJson(u)).toList() : [];
    print('result ${result.toList()}'); //To Remove log
    return list;
  }

   Future<List<Leave>> getLeaveListBySupervisor(int dept_id,int uid) async {
    print('getLeaveList------------------------'); //To Remove log
    var db = await dbProvider.database;
    var result = await db!.rawQuery(
        "SELECT * FROM leave where department_id =$dept_id and  user_id = $uid and (state = 'submit' or state='confirm') ORDER BY id DESC");
    List<Leave> list = result.isNotEmpty
        ? result.map((u) => Leave.fromJson(u)).toList()
        : [];
    print('result ${result.toList()}'); //To Remove log
    return list;
  }


  Future<List<Leave>> getLeaveListByManager(int dept_id,int uid) async {
    print('getLeaveList------------------------'); //To Remove log
    var db = await dbProvider.database;
    var result = await db!.rawQuery(
        "SELECT * FROM leave where department_id =$dept_id and user_id = $uid and (state='submit' or state='confirm' or state='approve') ORDER BY id DESC");
    List<Leave> list = result.isNotEmpty
        ? result.map((u) => Leave.fromJson(u)).toList()
        : [];
    print('result ${result.toList()}'); //To Remove log
    return list;
  }


  Future<List<Leave>> getLeaveListByHr(int uid) async {
    print('getLeaveList------------------------'); //To Remove log
    var db = await dbProvider.database;
    var result = await db!.rawQuery(
        "SELECT * FROM Leave where user_id = $uid and (state='submit' or state='confirm' or state='approve' or state='validate') ORDER BY id DESC");
    List<Leave> list = result.isNotEmpty
        ? result.map((u) => Leave.fromJson(u)).toList()
        : [];
    print('result ${result.toList()}'); //To Remove log
    return list;
  }

  Future<Leave> getSingleLeave(int id) async {
    print('getSingleLeave------ $id'); //To Remove log
    var db = await dbProvider.database;
    var result;
    result = await db!.rawQuery("SELECT * FROM leave WHERE leaveId = $id");

    print('result ${result.toList()}'); //To Remove log
    Leave leave = result[0];
    return leave;
  }

  Future insertLeave(List<Leave> LeaveList) async {
    //print('insertLeave-----$LeaveList'); //To Remove log

    final db = await dbProvider.database;
    Batch batch = db!.batch();

    for (int i = 0; i < LeaveList.length; i++) {
      batch.insert("leave", LeaveList[i].toJson());
    }
    await batch.commit(noResult: true);

    return "success";
  }

  insertSingleLeave(Leave Leave) async {
    print('insertSingleLeave------------- $Leave'); //To Remove log
    final db = await dbProvider.database;
    final result = await db!.insert("leave", Leave.toJson());
    print('result----------- $result'); //To Remove log
    return result;
  }

  updateLeave(Leave Leave) async {
    print('updateLeave------${Leave.toJson()}'); //To Remove log
    Database? db = await dbProvider.database;
    final result = await db!.update(
      'leave',
      Leave.toJson(),
      where: "id = ?",
      whereArgs: [Leave.id],
    );
    print("result******* $result"); //To Remove log
    return result;
  }

  Future<int> deleteLeaveRecords() async {
    print('deleteLeaveRecords-----------');
    Database? db = await dbProvider.database;
    var result = await db!.rawDelete('Delete from leave');
    print('result-----$result');
    return result;
  }
}
