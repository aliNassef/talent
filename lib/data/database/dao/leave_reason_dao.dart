import 'dart:async';
import 'package:sqflite/sqflite.dart';

import '../../models/leave_reason/leave_reason.dart';
import '../db_provider.dart';

class LeaveReasonDao {
  //LeaveReason
  final dbProvider = DatabaseProvider.db;

  Future<List<LeaveReason>> getLeaveReasonList() async {
    print('getLeaveReasonList------------------------'); //To Remove log
    var db = await dbProvider.database;
    var result = await db!.rawQuery("SELECT * FROM leaveReason ORDER BY id DESC");
    List<LeaveReason> list = result.isNotEmpty
        ? result.map((u) => LeaveReason.fromJson(u)).toList()
        : [];
    print('result ${result.toList()}'); //To Remove log
    return list;
  }

  Future<LeaveReason> getSingleLeaveReasonById(int id) async {
    print('getSingleLeaveReason------ $id'); //To Remove log
    var db = await dbProvider.database;
    var result;
    result = await db!.rawQuery("SELECT * FROM leaveReason WHERE leaveReasonId = $id");

    print('result ${result.toList()}'); //To Remove log
    LeaveReason leaveReason = result[0];
    return leaveReason;
  }

  Future insertLeaveReason(List<LeaveReason> LeaveReasonList) async {
    print('insertLeaveReason-----$LeaveReasonList'); //To Remove log

    final db = await dbProvider.database;
    Batch batch = db!.batch();

    for (int i = 0; i < LeaveReasonList.length; i++) {
      batch.insert("leaveReason", LeaveReasonList[i].toJson());
    }
    await batch.commit(noResult: true);

    return "success";
  }

  insertSingleLeaveReason(LeaveReason LeaveReason) async {
    print('insertSingleLeaveReason------------- $LeaveReason'); //To Remove log
    final db = await dbProvider.database;
    final result = await db!.insert("leaveReason", LeaveReason.toJson());
    print('result----------- $result'); //To Remove log
    return result;
  }

  updateLeaveReason(LeaveReason LeaveReason) async {
    print('updateLeaveReason------${LeaveReason.toJson()}'); //To Remove log
    Database? db = await dbProvider.database;
    final result = await db!.update(
      'leaveReason',
      LeaveReason.toJson(),
      where: "id = ?",
      whereArgs: [LeaveReason.id],
    );
    print("result******* $result"); //To Remove log
    return result;
  }

  Future<int> deleteLeaveReasonRecords() async {
    print('deleteLeaveReasonRecords-----------');
    Database? db = await dbProvider.database;
    var result = db!.rawDelete('Delete from leaveReason');
    print('result-----$result');
    return result;
  }
}
