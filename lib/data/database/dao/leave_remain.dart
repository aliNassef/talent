import 'dart:async';
import 'package:sqflite/sqflite.dart';
import '../../models/leave_remain/leave_remain.dart';
import '../db_provider.dart';

class LeaveRemainDao {
  //LeaveRemain
  final dbProvider = DatabaseProvider.db;

  Future<List<LeaveRemain>> getLeaveRemainList() async {
    print('getLeaveRemainList------------------------'); //To Remove log
    var db = await dbProvider.database;
    var result =
        await db!.rawQuery("SELECT * FROM leaveRemain ORDER BY id DESC");
    List<LeaveRemain> list = result.isNotEmpty
        ? result.map((u) => LeaveRemain.fromJson(u)).toList()
        : [];
    print('result ${result.toList()}'); //To Remove log
    return list;
  }

  Future<LeaveRemain> getSingleLeaveRemainById(int id) async {
    print('getSingleLeaveRemain------ $id'); //To Remove log
    var db = await dbProvider.database;
    var result;
    result = await db!
        .rawQuery("SELECT * FROM leaveRemain WHERE leaveRemainId = $id");

    print('result ${result.toList()}'); //To Remove log
    LeaveRemain leaveRemain = result[0];
    return leaveRemain;
  }

  Future<LeaveRemain> getSingleLeaveRemainByLeaveTypeId(int leaveTypeId) async {
    print(
        'getSingleLeaveRemainByLeaveTypeId------ $leaveTypeId'); //To Remove log
    var db = await dbProvider.database;
    var result;
    result = await db!.rawQuery(
        "SELECT * FROM leaveRemain WHERE leaveRemainId = $leaveTypeId");

    print('result ${result.toList()}'); //To Remove log
    LeaveRemain leaveRemain = LeaveRemain.fromJson(result[0]);
    return leaveRemain;
  }

  Future<LeaveRemain> getSingleLeaveRemainByCode(String code) async {
    print('getSingleLeaveRe main------ $code'); //To Remove log
    var db = await dbProvider.database;
    var result;
    result =
        await db!.rawQuery("SELECT * FROM leaveRemain WHERE code = '$code'");

    print('result ${result.toList()}'); //To Remove log
    LeaveRemain leaveRemain = LeaveRemain.fromJson(result[0]);
    return leaveRemain;
  }

  Future insertLeaveRemain(List<LeaveRemain> LeaveRemainList) async {
    print('insertLeaveRemain-----$LeaveRemainList'); //To Remove log

    final db = await dbProvider.database;
    Batch batch = db!.batch();

    for (int i = 0; i < LeaveRemainList.length; i++) {
      batch.insert("leaveRemain", LeaveRemainList[i].toJson());
    }
    await batch.commit(noResult: true);

    return "success";
  }

  insertSingleLeaveRemain(LeaveRemain LeaveRemain) async {
    print('insertSingleLeaveRemain------------- $LeaveRemain'); //To Remove log
    final db = await dbProvider.database;
    final result = await db!.insert("leaveRemain", LeaveRemain.toJson());
    print('result----------- $result'); //To Remove log
    return result;
  }

  updateLeaveRemain(LeaveRemain LeaveRemain) async {
    print('updateLeaveRemain------${LeaveRemain.toJson()}'); //To Remove log
    Database? db = await dbProvider.database;
    final result = await db!.update(
      'leaveRemain',
      LeaveRemain.toJson(),
      where: "id = ?",
      whereArgs: [LeaveRemain.id],
    );
    print("result******* $result"); //To Remove log
    return result;
  }

  Future<int> deleteLeaveRemainRecords() async {
    print('deleteLeaveRemainRecords-----------');
    Database? db = await dbProvider.database;
    var result = db!.rawDelete('Delete from leaveRemain');
    print('result-----$result');
    return result;
  }
}
