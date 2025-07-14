import 'dart:async';

import 'package:sqflite/sqflite.dart';

import '../../models/notification/notification.dart';
import '../db_provider.dart';

class NotificationDao {
  //Notification
  final dbProvider = DatabaseProvider.db;

  Future<List<AppNotification>> getNotificationList() async {
    print('getNotificationList------------------------'); //To Remove log
    var db = await dbProvider.database;
    var result = await db!.rawQuery("SELECT * FROM notification ORDER BY id DESC");
    List<AppNotification> list = result.isNotEmpty
        ? result.map((u) => AppNotification.fromJson(u)).toList()
        : [];
    print('result ${result.toList()}'); //To Remove log
    return list;
  }

  Future<List<AppNotification>> getUnReadNotificationList() async {
    print('getNotificationList------------------------'); //To Remove log
    var db = await dbProvider.database;
    var result = await db!.rawQuery("SELECT * FROM notification WHERE isRead = 0");
    List<AppNotification> list = result.isNotEmpty
        ? result.map((u) => AppNotification.fromJson(u)).toList()
        : [];
    print('result ${result.toList()}'); //To Remove log
    return list;
  }


  Future<AppNotification> getSingleNotification(int id) async {
    print('getSingleNotification------ $id'); //To Remove log
    var db = await dbProvider.database;
    var result;
    result = await db!.rawQuery("SELECT * FROM notification WHERE id = $id");

    print('result ${result.toList()}'); //To Remove log
    AppNotification Notification = result[0];
    return Notification;
  }

  Future insertNotification(List<AppNotification> NotificationList) async {
    print('insertNotification-----$NotificationList'); //To Remove log

    final db = await dbProvider.database;
    Batch batch = db!.batch();

    for (int i = 0; i < NotificationList.length; i++) {
      batch.insert("notification", NotificationList[i].toJson());
    }
    await batch.commit(noResult: true);

    return "success";
  }

  insertSingleNotification(AppNotification appNotification) async {
    print(
        'insertSingleNotification------------- $appNotification'); //To Remove log
    final db = await dbProvider.database;
    final result = await db!.insert("notification", appNotification.toJson());
    print('result----------- $result'); //To Remove log
    return result;
  }

  updateNotification(AppNotification appNotification) async {
    print(
        'updateNotification------${appNotification.toJson()}'); //To Remove log
    Database? db = await dbProvider.database;
    final result = await db!.update(
      'notification',
      appNotification.toJson(),
      where: "id = ?",
      whereArgs: [appNotification.id],
    );
    print("result******* $result"); //To Remove log
    return result;
  }

  Future<int> deleteNotificationRecords() async {
    print('deleteNotificationRecords-----------');
    Database? db = await dbProvider.database;
    var result = db!.rawDelete('Delete from notification');
    print('result-----$result');
    return result;
  }
}
