import 'dart:async';
import 'package:sqflite/sqflite.dart';

import '../../models/payslip/payslip.dart';
import '../db_provider.dart';

class PayslipDao {
  //Payslip
  final dbProvider = DatabaseProvider.db;

  Future<List<Payslip>> getPayslipList() async {
    print('getPayslipList------------------------'); //To Remove log
    var db = await dbProvider.database;
    var result = await db!.rawQuery("SELECT * FROM paySlip ORDER BY id DESC");
    List<Payslip> list = result.isNotEmpty
        ? result.map((u) => Payslip.fromJson(u)).toList()
        : [];
    print('result ${result.toList()}'); //To Remove log
    return list;
  }

  
  Future<List<Payslip>> getAllPayslips() async {
    print('getPayslipList------------------------'); //To Remove log
    var db = await dbProvider.database;
    var result = await db!.rawQuery("SELECT * FROM paySlip ORDER BY id DESC");
    List<Payslip> list = result.isNotEmpty
        ? result.map((u) => Payslip.fromJson(u)).toList()
        : [];
    print('result ${result.toList()}'); //To Remove log
    return list;
  }

  Future<Payslip> getSinglePayslip(int id) async {
    print('getSinglePayslip------ $id'); //To Remove log
    var db = await dbProvider.database;
    var result;
    result = await db!.rawQuery("SELECT * FROM paySlip WHERE payslipId = $id");

    print('result ${result.toList()}'); //To Remove log
    Payslip payslip = result[0];
    return payslip;
  }

  Future insertPayslip(List<Payslip> PayslipList) async {
    print('insertPayslip-----$PayslipList'); //To Remove log

    final db = await dbProvider.database;
    Batch batch = db!.batch();

    for (int i = 0; i < PayslipList.length; i++) {
      batch.insert("paySlip", PayslipList[i].toJson());
    }
    await batch.commit(noResult: true);

    return "success";
  }

  insertSinglePayslip(Payslip Payslip) async {
    print('insertSinglePayslip------------- $Payslip'); //To Remove log
    final db = await dbProvider.database;
    final result = await db!.insert("paySlip", Payslip.toJson());
    print('result----------- $result'); //To Remove log
    return result;
  }

  updatePayslip(Payslip Payslip) async {
    print('updatePayslip------${Payslip.toJson()}'); //To Remove log
    Database? db = await dbProvider.database;
    final result = await db!.update(
      'paySlip',
      Payslip.toJson(),
      where: "id = ?",
      whereArgs: [Payslip.id],
    );
    print("result******* $result"); //To Remove log
    return result;
  }

  Future<int> deletePayslipRecords() async {
    print('deletePayslipRecords-----------');
    Database? db = await dbProvider.database;
    var result = db!.rawDelete('Delete from paySlip');
    print('result-----$result');
    return result;
  }
}
