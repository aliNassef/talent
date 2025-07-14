import 'dart:async';
import 'package:sqflite/sqflite.dart';
import '../../../models/expense/analytic_account/analytic_account.dart';
import '../../db_provider.dart';

class AnalyticAccountDao {
  final dbProvider = DatabaseProvider.db;

  Future<List<AnalyticAccount>> getAnalyticAccountList() async {
    print('getAnalyticAccountList------------------------'); //To Remove log
    var db = await dbProvider.database;
    var result = await db!.rawQuery("SELECT * FROM analyticAccount");
    List<AnalyticAccount> list = result.isNotEmpty
        ? result.map((u) => AnalyticAccount.fromJson(u)).toList()
        : [];
    print('result ${result.toList()}'); //To Remove log
    return list;
  }

  Future<AnalyticAccount> getSingleAnalyticAccount(int id) async {
    print('getSingleAnalyticAccount------------------------'); //To Remove log
    var db = await dbProvider.database;
    var result = await db!.rawQuery(
        "SELECT * FROM analyticAccount WHERE analyticAccountId = $id");
    List<AnalyticAccount> list = result.isNotEmpty
        ? result.map((u) => AnalyticAccount.fromJson(u)).toList()
        : [];
    print('result ${result.toList()}'); //To Remove log
    AnalyticAccount analyticAccount = list[0];
    print('AnalyticAccount -${analyticAccount}');
    return analyticAccount;
  }

  Future insertAnalyticAccount(
      List<AnalyticAccount> AnalyticAccountList) async {
    print('insertAnalyticAccount-----$AnalyticAccountList'); //To Remove log

    final db = await dbProvider.database;
    Batch batch = db!.batch();

    for (int i = 0; i < AnalyticAccountList.length; i++) {
      batch.insert("analyticAccount", AnalyticAccountList[i].toJson());
    }
    await batch.commit(noResult: true);

    return "success";
  }

  updateAnalyticAccount(AnalyticAccount analyticAccount) async {
    print('updateAnalyticAccount------${analyticAccount.toJson()}'); //To Remove log
    Database? db = await dbProvider.database;
    final result = await db!.update(
      'analyticAccount',
      analyticAccount.toJson(),
      where: "id = ?",
      whereArgs: [analyticAccount.id],
    );
    print("result******* $result"); //To Remove log
    return result;
  }

  deleteAnalyticAccountRecords() async {
    print('deleteAnalyticAccountRecords-----------');
    Database? db = await dbProvider.database;
    var result = db!.rawQuery('Delete from analyticAccount');
    print('result-----$result');
  }
}
