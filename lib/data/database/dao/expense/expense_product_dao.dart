import 'dart:async';
import 'package:sqflite/sqflite.dart';
import '../../../models/expense/expense_product/expense_product.dart';
import '../../db_provider.dart';


class ExpenseProductDao {
   final dbProvider = DatabaseProvider.db;

  Future<List<ExpenseProduct>> getExpenseProductList() async {
    print('getExpenseProductList------------------------'); //To Remove log
    var db = await dbProvider.database;
    var result = await db!.rawQuery("SELECT * FROM expenseProduct");
    List<ExpenseProduct> list = result.isNotEmpty
        ? result.map((u) => ExpenseProduct.fromJson(u)).toList()
        : [];
    print('result ${result.toList()}'); //To Remove log
    return list;
  }

  
  Future<ExpenseProduct> getSingleExpenseProduct(int id) async {
    print('getSingleExpense------------------------'); //To Remove log
    var db = await dbProvider.database;
    var result = await db!
        .rawQuery("SELECT * FROM expenseProduct WHERE expenseProductId = $id");
    List<ExpenseProduct> list = result.isNotEmpty
        ? result.map((u) => ExpenseProduct.fromJson(u)).toList()
        : [];
    print('result ${result.toList()}'); //To Remove log
    ExpenseProduct expense = list[0];
    print('expense -${expense}');
    return expense;
  }

  Future insertExpenseProduct(List<ExpenseProduct> expenseProductList) async {
    print('insertExpense-----$expenseProductList'); //To Remove log

    final db = await dbProvider.database;
    Batch batch = db!.batch();

    for (int i = 0; i < expenseProductList.length; i++) {
      batch.insert("expenseProduct", expenseProductList[i].toJson());
    }
    await batch.commit(noResult: true);

    return "success";
  }

  updateExpense(ExpenseProduct expense) async {
    print('updateExpense------${expense.toJson()}'); //To Remove log
    Database? db = await dbProvider.database;
    final result = await db!.update(
      'expenseProduct',
      expense.toJson(),
      where: "id = ?",
      whereArgs: [expense.id],
    );
    print("result******* $result"); //To Remove log
    return result;
  }

  deleteExpenseRecords() async {
    print('deleteExpenseRecords-----------');
    Database? db = await dbProvider.database;
    var result = db!.rawQuery('Delete from expenseProduct');
    print('result-----$result');
  }
}
