import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../database/dao/expense/expense_product_dao.dart';
import '../models/expense/expense_product/expense_product.dart';

class ExpenseProductAPI {
  var pref;
  var urlLink;
  var expenseProductDao = ExpenseProductDao();
 
  var database;
  var header_cookie;
  String createResult = '';

  Future<dynamic> getExpenseProductListOnline() async {
    pref = await SharedPreferences.getInstance();
    urlLink = await pref.getString('url');
    database = await pref.getString('database');
    header_cookie = await pref.getString('header_cookie');
    var isLoginned = await pref.getString('isLoginned');
    var insertResult;
    var updateResult;

    List<Map<String, dynamic>> listData = [];
     List<ExpenseProduct> expenseProductList = [];

    var url;

    await expenseProductDao.deleteExpenseRecords();

    // url = Uri.parse('$urlLink' +
    //     'api/get/expense_product?domain=[(\'can_be_expensed\', \'=\', \'True\')]');
    url = Uri.parse('$urlLink' + 'api/get/expense_product');

    var domainParam = "[ [ 'can_be_expensed',  '=', 'True' ] ]";

    var param = {'domain': domainParam};
    await http
        .post(url,
            headers: {
              'Accept': 'application/json',
              'Content-type': 'application/json',
              'db_name': database,
              'cookie': header_cookie,
            },
            body: json.encode({}))
        .then((res) async {
      if (res.statusCode == 200) {
        Map<String, dynamic> result = json.decode(res.body);
        List<dynamic> list = result['result'];
      

        for (var element in list) {
          ExpenseProduct expenseProduct =
              ExpenseProduct(element['id'], element['name']);

          expenseProductList.add(expenseProduct);
        }
        if (expenseProductList.isNotEmpty) {
          insertResult = await await expenseProductDao
              .insertExpenseProduct(expenseProductList);
        }

        if (updateResult != null) {
          insertResult = 'success';
        }
      } else {
        insertResult = 'Something Wrong';
      }
    }).catchError((e) {
      insertResult = e.toString();
    });
    return insertResult;
  }
}
