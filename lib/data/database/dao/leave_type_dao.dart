import 'dart:async';
import 'package:sqflite/sqflite.dart';
import '../../models/leave_type/leave_type.dart';
import '../db_provider.dart';

class LeaveTypeDao {
  //LeaveType
  final dbProvider = DatabaseProvider.db;

  Future<List<LeaveType>> getLeaveTypeList() async {
    print('getLeaveTypeList------------------------'); //To Remove log
    var db = await dbProvider.database;
    var result = await db!.rawQuery("SELECT * FROM leaveType ORDER BY id DESC");
    List<LeaveType> list = result.isNotEmpty
        ? result.map((u) => LeaveType.fromJson(u)).toList()
        : [];
    print('result ${result.toList()}'); //To Remove log
    return list;
  }

  Future<LeaveType> getSingleLeaveTypeById(int id) async {
    print('getSingleLeaveType------ $id'); //To Remove log
    var db = await dbProvider.database;
    var result;
    result = await db!.rawQuery("SELECT * FROM leaveType WHERE leaveTypeId = $id");

    print('result ${result.toList()}'); //To Remove log
    LeaveType leaveType = result[0];
    return leaveType;
  }

   Future<LeaveType> getSingleLeaveTypeByCode(String code) async {
    print('getSingleLeaveTypeByCode------ $code'); //To Remove log
    var db = await dbProvider.database;
    var result;
    result = await db!.rawQuery("SELECT * FROM leaveType WHERE leave_type = '$code'");

    print('result ${result.toList()}'); //To Remove log
    LeaveType leaveType = result[0];
    return leaveType;
  }


  Future insertLeaveType(List<LeaveType> LeaveTypeList) async {
    print('insertLeaveType-----$LeaveTypeList'); //To Remove log

    final db = await dbProvider.database;
    Batch batch = db!.batch();

    for (int i = 0; i < LeaveTypeList.length; i++) {
      batch.insert("leaveType", LeaveTypeList[i].toJson());
    }
    await batch.commit(noResult: true);

    return "success";
  }

  insertSingleLeaveType(LeaveType LeaveType) async {
    print('insertSingleLeaveType------------- $LeaveType'); //To Remove log
    final db = await dbProvider.database;
    final result = await db!.insert("leaveType", LeaveType.toJson());
    print('result----------- $result'); //To Remove log
    return result;
  }

  updateLeaveType(LeaveType LeaveType) async {
    print('updateLeaveType------${LeaveType.toJson()}'); //To Remove log
    Database? db = await dbProvider.database;
    final result = await db!.update(
      'leaveType',
      LeaveType.toJson(),
      where: "id = ?",
      whereArgs: [LeaveType.id],
    );
    print("result******* $result"); //To Remove log
    return result;
  }

  Future<int> deleteLeaveTypeRecords() async {
    print('deleteLeaveTypeRecords-----------');
    Database? db = await dbProvider.database;
    var result = db!.rawDelete('Delete from leaveType');
    print('result-----$result');
    return result;
  }
}
