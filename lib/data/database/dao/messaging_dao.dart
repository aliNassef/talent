import 'dart:async';
import 'package:sqflite/sqflite.dart';
import '../../models/messaging/messaging.dart';
import '../db_provider.dart';

class MessagingDao {
  //Messaging
  final dbProvider = DatabaseProvider.db;

  Future<List<Messaging>> getMessagingList(String state) async {
    print('getMessagingList------------------------'); //To Remove log
    var db = await dbProvider.database;
    var result = await db!.rawQuery("SELECT * FROM Messaging WHERE state = '$state' ORDER BY id DESC");
    List<Messaging> list = result.isNotEmpty
        ? result.map((u) => Messaging.fromJson(u)).toList()
        : [];
    print('result ${result.toList()}'); //To Remove log
    return list;
  }

  Future<Messaging> getSingleMessaging(int id) async {
    print('getSingleMessaging------ $id'); //To Remove log
    var db = await dbProvider.database;
    var result;
    result = await db!.rawQuery("SELECT * FROM Messaging WHERE id = $id");

    print('result ${result.toList()}'); //To Remove log
    Messaging messaging = result[0];
    return messaging;
  }

  Future insertMessaging(List<Messaging> MessagingList) async {
    print('insertMessaging-----$MessagingList'); //To Remove log

    final db = await dbProvider.database;
    Batch batch = db!.batch();

    for (int i = 0; i < MessagingList.length; i++) {
      batch.insert("Messaging", MessagingList[i].toJson());
    }
    await batch.commit(noResult: true);

    return "success";
  }

  insertSingleMessaging(Messaging Messaging) async {
    print('insertSingleMessaging------------- $Messaging'); //To Remove log
    final db = await dbProvider.database;
    final result = await db!.insert("Messaging", Messaging.toJson());
    print('result----------- $result'); //To Remove log
    return result;
  }

  updateMessaging(Messaging Messaging) async {
    print('updateMessaging------${Messaging.toJson()}'); //To Remove log
    Database? db = await dbProvider.database;
    final result = await db!.update(
      'Messaging',
      Messaging.toJson(),
      where: "id = ?",
      whereArgs: [Messaging.id],
    );
    print("result******* $result"); //To Remove log
    return result;
  }

  Future<int> deleteMessagingRecords() async {
    print('deleteMessagingRecords-----------');
    Database? db = await dbProvider.database;
    var result = db!.rawDelete('Delete from Messaging');
    print('result-----$result');
    return result;
  }
}
