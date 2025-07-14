import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

// import '../database/Dao/expense/expense_dao.dart';
import '../database/dao/expense/expense_dao.dart';
import '../models/expense/expense/expense.dart';

class ExpenseAPI {
  var pref;
  var urlLink;
  var expenseDao = ExpenseDao();

  var database;
  var header_cookie;
  String createResult = '';

  Future<dynamic> getExpenseListOnline() async {
    pref = await SharedPreferences.getInstance();
    urlLink = await pref.getString('url');
    database = await pref.getString('database');
    header_cookie = await pref.getString('header_cookie');
    var isLoginned = await pref.getString('isLoginned');
    int userId = await pref!.getInt('uid');
    var insertResult;
    var updateResult;

    List<Map<String, dynamic>> listData = [];
    List<Expense> expenseList = [];

    await expenseDao.deleteExpenseRecords();

    BaseOptions options = BaseOptions();
    options.connectTimeout = Duration(seconds: 30);
    options.receiveTimeout = Duration(seconds: 30); // to let download any response size

    options.headers = {
      'Accept': 'application/json',
      'Content-type': 'application/json',
      'db_name': database,
      'cookie': header_cookie,
    };

    var dio = Dio(options);

    var url;

    url = Uri.parse('$urlLink' + 'api/get/expense');

    var domainParam = "[ [ 'employee_id.user_id',  '=', $userId ] ]";

    var param = {'domain': domainParam, "month": 2};

    // var param = {};
    await dio
        .post(
      '$urlLink' + 'api/get/expense',
      data: jsonEncode(param),
    )
        .then((res) async {
      if (res.statusCode == 200) {


        List<dynamic> list = res.data['result'];
        // if(list.isNotEmpty){
        //   await expenseDao.deleteExpenseRecords();
        // }

        for (var element in list) {
          List imgList = element['attachments'];

          Expense expense = Expense(
              element['id'],
              element['name'],
              element['date'],
              element['reference'],
              element['product_id'],
              element['product_name'],
              0,
              // double.parse(element['amount'].toString()),
              1,
              double.parse(element['total_amount'].toString()),
              element['payment_mode'],
              element['description'],
              element['state'],
              1,
              // element['analytic_account_id5'],
              0,
              imgList.isNotEmpty ? imgList[0].toString() : '');

          expenseList.add(expense);
        }

        // if (expenseList.length > 0) {
        //   List<Expense> tempList = [];
        //   for (int i = expenseList.length - 1; i >= 0; i--) {
        //     tempList.add(expenseList[i]);
        //   }
        //   insertResult = await expenseDao.insertExpense(tempList);
        // }
        insertResult = await expenseDao.insertExpense(expenseList);
      } else {
        insertResult = 'Something Wrong';
      }
    }).catchError((e) {
      insertResult = e.toString();
    });
    return insertResult;
  }

  Future<dynamic> createExpense(Expense expense) async {
    pref = await SharedPreferences.getInstance();
    urlLink = await pref.getString('url');
    int userId = await pref!.getInt('uid');
    header_cookie = await pref.getString('header_cookie');
    var resultData;

    var url = Uri.parse('$urlLink' + 'api/create/expense');
    List stockList = [];
    // var param = {
    //   "name": expense.description, //description in odoo
    //   "description": expense.note, //note in odoo
    //   "product_id": expense.expenseProductId,
    //   "unit_amount": expense.unitPrice,
    //   "total_amount": expense.unitPrice,
    //   "reason": expense.note, //'adfffeww
    //   "date": expense.date,
    //   "user_id": userId,
    //   "payment_mode": expense.paidBy,
    //   "state": expense.state,
    //   "reference": expense.billRef,
    //   //"analytic_account_id": expense.analyticAccountId,
    //   "attachments": [
    //     [
    //       0,
    //       0,
    //       {"image_1920": expense.attachment}
    //     ]
    //   ]
    // };

    var param = {
      "name": expense.description, //description in odoo
      "description": expense.note, //note in odoo
      "product_id": expense.expenseProductId,
      "tax_ids":
          expense.analyticAccountId == 0 ? [] : [expense.analyticAccountId],
      "total_amount_currency": expense.unitPrice,
      "date": expense.date,
      "payment_mode": expense.paidBy,
      "state": 'submitted'
    };
    var response = await http
        .post(url,
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
              'cookie': header_cookie,
            },
            body: json.encode(param))
        .then((response) async {
      if (response.statusCode == 200) {
        Map<String, dynamic> result = json.decode(response.body);
        if (result['result']['success'] == true) {
          createResult = "Success";

          var createdId = result['result']['expense_id'];
          var message = result['result']['message'];
          resultData = {
            'result': createResult,
            'createdId': createdId,
            'message': message
          };
        } else {
          var message = result['result']['error'];
          resultData = {
            'result': 'fail',
            'createdId': null,
            'message': message
          };
          
        }
      } else {
        resultData = {
          'result': 'fail',
          'createdId': null,
          'message': response.statusCode.toString()
        };
      }
    }).catchError((e) {
      resultData = {
        'result': 'fail',
        'createdId': null,
        'message': e.toString()
      };
    });

    return resultData;
  }
}
