import 'dart:async';
import 'package:sqflite/sqflite.dart';

import '../../models/holiday/holiday.dart';
import '../db_provider.dart';

class HolidayDao {
  //Holiday
  final dbProvider = DatabaseProvider.db;

  Future<List<Holiday>> getHolidayList() async {
    print('getHolidayList------------------------'); //To Remove log
    var db = await dbProvider.database;
    var result = await db!.rawQuery("SELECT * FROM holiday ORDER BY id ASC");
    List<Holiday> list = result.isNotEmpty
        ? result.map((u) => Holiday.fromJson(u)).toList()
        : [];
    print('result ${result.toList()}'); //To Remove log
    return list;
  }

  Future<Holiday> getSingleHoliday(int id) async {
    print('getSingleHoliday------ $id'); //To Remove log
    var db = await dbProvider.database;
    var result;
    result = await db!.rawQuery("SELECT * FROM holiday WHERE holidayId = $id");

    print('result ${result.toList()}'); //To Remove log
    Holiday holiday = result[0];
    return holiday;
  }

  Future insertHoliday(List<Holiday> HolidayList) async {
    print('insertHoliday-----$HolidayList'); //To Remove log

    final db = await dbProvider.database;
    Batch batch = db!.batch();

    for (int i = 0; i < HolidayList.length; i++) {
      batch.insert("holiday", HolidayList[i].toJson());
    }
    await batch.commit(noResult: true);

    return "success";
  }

  insertSingleHoliday(Holiday holiday) async {
    print('insertSingleHoliday------------- $Holiday'); //To Remove log
    final db = await dbProvider.database;
    final result = await db!.insert("holiday", holiday.toJson());
    print('result----------- $result'); //To Remove log
    return result;
  }

  updateHoliday(Holiday holiday) async {
    print('updateHoliday------${holiday.toJson()}'); //To Remove log
    Database? db = await dbProvider.database;
    final result = await db!.update(
      'holiday',
      holiday.toJson(),
      where: "id = ?",
      whereArgs: [holiday.id],
    );
    print("result******* $result"); //To Remove log
    return result;
  }

  Future<int> deleteHolidayRecords() async {
    print('deleteHolidayRecords-----------');
    Database? db = await dbProvider.database;
    var result = db!.rawDelete('Delete from holiday');
    print('result-----$result');
    return result;
  }
}
