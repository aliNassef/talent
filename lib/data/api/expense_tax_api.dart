import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../database/dao/expense/expense_product_dao.dart';
import '../database/dao/expense/expense_tax_dao.dart';
import '../models/expense/expense_product/expense_product.dart';
import '../models/expense/expense_tax/expense_tax.dart';

class ExpenseTaxAPI {
  var pref;
  var urlLink;
  var expenseTaxDao = ExpenseTaxDao();
  
  var database;
  var header_cookie;
  String createResult = '';

  Future<dynamic> getExpenseTaxListOnline() async {
    pref = await SharedPreferences.getInstance();
    urlLink = await pref.getString('url');
    database = await pref.getString('database');
    header_cookie = await pref.getString('header_cookie');
    var isLoginned = await pref.getString('isLoginned');
    var insertResult;
    var updateResult;

    List<Map<String, dynamic>> listData = [];

    List<ExpenseTax> expenseTaxList = [];

    var url;

    await expenseTaxDao.deleteExpenseRecords();

    
    // url = Uri.parse('$urlLink' +
    //     'api/get/expense_product?domain=[(\'can_be_expensed\', \'=\', \'True\')]');
    url = Uri.parse('$urlLink' + 'api/get/expense_tax');

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
            body: json.encode(param))
        .then((res) async {
      if (res.statusCode == 200) {
        Map<String, dynamic> result = json.decode(res.body);
        List<dynamic> list = result['result'];
       

        for (var element in list) {
          ExpenseTax expenseTax = ExpenseTax(
            element['id'],
            element['name'],
            element['description'],
            element['amount_type'],
            element['type_tax_use'],
            double.parse(element['amount'].toString()),
            element['tax_scope'] == false ? '' : element['tax_scope'],
            element['write_date'],
          );

          expenseTaxList.add(expenseTax);
        }
        if (expenseTaxList.isNotEmpty) {
          insertResult =
              await await expenseTaxDao.insertExpenseTax(expenseTaxList);
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
