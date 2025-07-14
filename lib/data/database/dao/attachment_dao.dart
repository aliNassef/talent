import 'dart:async';
import 'package:sqflite/sqflite.dart';

import '../../models/attachment/attachment.dart';
import '../db_provider.dart';

class AttachmentDao {
  //Attachment
  final dbProvider = DatabaseProvider.db;

  Future<List<Attachment>> getAttachmentList() async {
    print('getAttachmentList------------------------'); //To Remove log
    var db = await dbProvider.database;
    var result =
        await db!.rawQuery("SELECT * FROM attachment ORDER BY id DESC");
    List<Attachment> list = result.isNotEmpty
        ? result.map((u) => Attachment.fromJson(u)).toList()
        : [];
    print('result ${result.toList()}'); //To Remove log
    return list;
  }

    Future<List<Attachment>> getAttachmentListById(int id) async {
    print('getAttachmentListById------------------------'); //To Remove log
    var db = await dbProvider.database;
    var result =
        await db!.rawQuery("SELECT * FROM attachment  WHERE attachmentId = $id ORDER BY id DESC");
    List<Attachment> list = result.isNotEmpty
        ? result.map((u) => Attachment.fromJson(u)).toList()
        : [];
    print('result ${result.toList()}'); //To Remove log
    return list;
  }

  Future<Attachment> getSingleAttachmentById(int id) async {
    print('getSingleAttachment------ $id'); //To Remove log
    var db = await dbProvider.database;
    var result;
    result = await db!.rawQuery("SELECT * FROM attachment WHERE attachmentId = $id");

    print('result ${result.toList()}'); //To Remove log
    Attachment attachment = result[0];
    return attachment;
  }

  Future insertAttachment(List<Attachment> attachmentList) async {
    print('insertAttachment-----$attachmentList'); //To Remove log

    final db = await dbProvider.database;
    Batch batch = db!.batch();

    for (int i = 0; i < attachmentList.length; i++) {
      batch.insert("attachment", attachmentList[i].toJson());
    }
    await batch.commit(noResult: true);

    return "success";
  }

  insertSingleAttachment(Attachment attachment) async {
    print('insertSingleAttachment------------- $Attachment'); //To Remove log
    final db = await dbProvider.database;
    final result = await db!.insert("attachment", attachment.toJson());
    print('result----------- $result'); //To Remove log
    return result;
  }

  updateAttachment(Attachment attachment) async {
    print('updateAttachment------${attachment.toJson()}'); //To Remove log
    Database? db = await dbProvider.database;
    final result = await db!.update(
      'attachment',
      attachment.toJson(),
      where: "id = ?",
      whereArgs: [attachment.id],
    );
    print("result******* $result"); //To Remove log
    return result;
  }

  Future<int> deleteAttachmentRecords() async {
    print('deleteAttachmentRecords-----------');
    Database? db = await dbProvider.database;
    var result = db!.rawDelete('Delete from attachment');
    print('result-----$result');
    return result;
  }
}
