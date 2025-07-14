import 'dart:async';

import 'package:sqflite/sqflite.dart';

import '../../../models/expense/expense/expense.dart';
import '../../db_provider.dart';

class ExpenseDao {
  final dbProvider = DatabaseProvider.db;

  Future<List<Expense>> getExpenseList() async {
    print('getExpenseList------------------------'); //To Remove log
    var db = await dbProvider.database;
    var result = await db!.rawQuery("SELECT * FROM expense ORDER BY id ASC");
    List<Expense> list = result.isNotEmpty
        ? result.map((u) => Expense.fromJson(u)).toList()
        : [];
    print('result ${result.toList()}'); //To Remove log
    return list;
  }

  Future<List<Expense>> getExpenseListByAsc() async {
    print('getExpenseList------------------------'); //To Remove log
    var db = await dbProvider.database;
    var result = await db!.rawQuery("SELECT * FROM expense ORDER BY id ASC");
    List<Expense> list = result.isNotEmpty
        ? result.map((u) => Expense.fromJson(u)).toList()
        : [];
    print('result ${result.toList()}'); //To Remove log
    return list;
  }

  Future<List<Expense>> getMobileExpenseList() async {
    print('getExpenseList------------------------'); //To Remove log
    var db = await dbProvider.database;
    var result = await db!.rawQuery("SELECT * FROM expense WHERE isSync = 0");
    List<Expense> list = result.isNotEmpty
        ? result.map((u) => Expense.fromJson(u)).toList()
        : [];
    print('result ${result.toList()}'); //To Remove log
    return list;
  }

  Future<Expense> getSingleExpense(int id) async {
    print('getSingleExpense------------------------'); //To Remove log
    var db = await dbProvider.database;
    var result =
        await db!.rawQuery("SELECT * FROM expense WHERE expenseId = $id");
    List<Expense> list = result.isNotEmpty
        ? result.map((u) => Expense.fromJson(u)).toList()
        : [];
    print('result ${result.toList()}'); //To Remove log
    Expense expense = list[0];
    print('expense -${expense}');
    return expense;
  }

  Future insertExpense(List<Expense> expenseList) async {
    print('insertExpense-----$expenseList'); //To Remove log

    final db = await dbProvider.database;
    Batch batch = db!.batch();

    for (int i = 0; i < expenseList.length; i++) {
      batch.insert("expense", expenseList[i].toJson());
    }
    await batch.commit(noResult: true);

    return "success";
  }

  Future<int> insertSingleExpense(Expense expense) async {
    print('insertSingleExpense------------- $expense'); //To Remove log
    final db = await dbProvider.database;
    final result = await db!.insert("expense", expense.toJson());
    print('result----------- $result'); //To Remove log
    return result;
  }

  updateExpense(Expense expense) async {
    print('updateExpense------${expense.toJson()}'); //To Remove log
    Database? db = await dbProvider.database;
    final result = await db!.update(
      'expense',
      expense.toJson(),
      where: "id = ?",
      whereArgs: [expense.id],
    );
    print("result******* $result"); //To Remove log
    return result;
  }

  Future<int> deleteExpenseRecords() async {
    print('deleteExpenseRecords-----------');
    Database? db = await dbProvider.database;
    var result = db!.rawDelete('Delete from expense');
    print('result-----$result');
    return result;
  }

  Future<int> deleteExpenseRecordsById(int id) async {
    print('deleteExpenseRecordsById-----------');
    Database? db = await dbProvider.database;
    var result = db!.rawDelete('Delete from expense WHERE id = $id');
    print('result-----$result');
    return result;
  }

  Future<int> deleteSingleExpenseRecords(int id) async {
    print('deleteSingleOvertimeRecords-----------$id');
    Database? db = await dbProvider.database;
    var result = db!.rawDelete('Delete from expense WHERE id = $id');
    print('result-----$result');
    return result;
  }
}
