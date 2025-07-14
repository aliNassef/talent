import 'dart:async';
import 'package:sqflite/sqflite.dart';

import '../../models/hours/hours.dart';
import '../db_provider.dart';

class HoursDao {
  //Hours
  final dbProvider = DatabaseProvider.db;

  Future<List<Hours>> getHoursList() async {
    print('getHoursList------------------------'); //To Remove log
    var db = await dbProvider.database;
    var result = await db!.rawQuery("SELECT * FROM hours ORDER BY id DESC");
    List<Hours> list = result.isNotEmpty
        ? result.map((u) => Hours.fromJson(u)).toList()
        : [];
    print('result ${result.toList()}'); //To Remove log
    return list;
  }

    Future<List<Hours>> getHoursListByType(String type) async {
    print('getHoursList------------------------'); //To Remove log
    var db = await dbProvider.database;
    var result = await db!.rawQuery("SELECT * FROM hours WHERE type = '$type' ORDER BY id DESC");
    List<Hours> list = result.isNotEmpty
        ? result.map((u) => Hours.fromJson(u)).toList()
        : [];
    print('result ${result.toList()}'); //To Remove log
    return list;
  }

  Future<Hours> getSingleHoursById(int id) async {
    print('getSingleHours------ $id'); //To Remove log
    var db = await dbProvider.database;
    var result;
    result = await db!.rawQuery("SELECT * FROM hours WHERE id = $id");

    print('result ${result.toList()}'); //To Remove log
    Hours hours = result[0];
    return hours;
  }

   Future<Hours> getSingleHoursByType(String type) async {
    print('getSingleHoursByType------ $type'); //To Remove log
    var db = await dbProvider.database;
    var result;
    result = await db!.rawQuery("SELECT * FROM hours WHERE type = '$type'");

    print('result ${result.toList()}'); //To Remove log
    Hours hours = result[0];
    return hours;
  }

  Future insertHours(List<Hours> HoursList) async {
    print('insertHours-----$HoursList'); //To Remove log

    final db = await dbProvider.database;
    Batch batch = db!.batch();

    for (int i = 0; i < HoursList.length; i++) {
      batch.insert("hours", HoursList[i].toJson());
    }
    await batch.commit(noResult: true);

    return "success";
  }

  insertSingleHours(Hours Hours) async {
    print('insertSingleHours------------- $Hours'); //To Remove log
    final db = await dbProvider.database;
    final result = await db!.insert("hours", Hours.toJson());
    print('result----------- $result'); //To Remove log
    return result;
  }

  updateHours(Hours Hours) async {
    print('updateHours------${Hours.toJson()}'); //To Remove log
    Database? db = await dbProvider.database;
    final result = await db!.update(
      'hours',
      Hours.toJson(),
      where: "id = ?",
      whereArgs: [Hours.id],
    );
    print("result******* $result"); //To Remove log
    return result;
  }

  Future<int> deleteHoursRecords() async {
    print('deleteHoursRecords-----------');
    Database? db = await dbProvider.database;
    var result = db!.rawDelete('Delete from hours');
    print('result-----$result');
    return result;
  }
}
