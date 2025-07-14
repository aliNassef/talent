import 'dart:async';
import 'package:sqflite/sqflite.dart';
import '../../models/payslip_line/payslip_line.dart';
import '../db_provider.dart';

class PayslipLineDao {
  //PayslipLine
  final dbProvider = DatabaseProvider.db;

  Future<List<PayslipLine>> getPayslipLineList() async {
    print('getPayslipLineList------------------------'); //To Remove log
    var db = await dbProvider.database;
    var result = await db!.rawQuery("SELECT * FROM paySlipLine ORDER BY id DESC");
    List<PayslipLine> list = result.isNotEmpty
        ? result.map((u) => PayslipLine.fromJson(u)).toList()
        : [];
    print('result ${result.toList()}'); //To Remove log
    return list;
  }

    Future<List<PayslipLine>> getPayslipLineListBySlipId(int hdrSlipId) async {
    print('getPayslipLineList------------------------'); //To Remove log
    var db = await dbProvider.database;
    var result = await db!.rawQuery("SELECT * FROM paySlipLine WHERE payslip_id = $hdrSlipId ORDER BY id DESC");
    List<PayslipLine> list = result.isNotEmpty
        ? result.map((u) => PayslipLine.fromJson(u)).toList()
        : [];
    print('result ${result.toList()}'); //To Remove log
    return list;
  }

  Future<PayslipLine> getSinglePayslipLineById(int id) async {
    print('getSinglePayslipLine------ $id'); //To Remove log
    var db = await dbProvider.database;
    var result;
    result = await db!.rawQuery("SELECT * FROM paySlipLine WHERE payslipLineId = $id");

    print('result ${result.toList()}'); //To Remove log
    PayslipLine payslipLine = result[0];
    return payslipLine;
  }

  Future insertPayslipLine(List<PayslipLine> PayslipLineList) async {
    print('insertPayslipLine-----$PayslipLineList'); //To Remove log

    final db = await dbProvider.database;
    Batch batch = db!.batch();

    for (int i = 0; i < PayslipLineList.length; i++) {
      batch.insert("paySlipLine", PayslipLineList[i].toJson());
    }
    await batch.commit(noResult: true);

    return "success";
  }

  insertSinglePayslipLine(PayslipLine PayslipLine) async {
    print('insertSinglePayslipLine------------- $PayslipLine'); //To Remove log
    final db = await dbProvider.database;
    final result = await db!.insert("paySlipLine", PayslipLine.toJson());
    print('result----------- $result'); //To Remove log
    return result;
  }

  updatePayslipLine(PayslipLine PayslipLine) async {
    print('updatePayslipLine------${PayslipLine.toJson()}'); //To Remove log
    Database? db = await dbProvider.database;
    final result = await db!.update(
      'paySlipLine',
      PayslipLine.toJson(),
      where: "id = ?",
      whereArgs: [PayslipLine.id],
    );
    print("result******* $result"); //To Remove log
    return result;
  }

  Future<int> deletePayslipLineRecords() async {
    print('deletePayslipLineRecords-----------');
    Database? db = await dbProvider.database;
    var result = db!.rawDelete('Delete from paySlipLine');
    print('result-----$result');
    return result;
  }
}
