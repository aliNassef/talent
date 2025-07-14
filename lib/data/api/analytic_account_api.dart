import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../database/dao/expense/analytic_account_dao.dart';
import '../models/expense/analytic_account/analytic_account.dart';

class AnalyticAccountAPI {
  var pref;
  var urlLink;
  var header_cookie;
  var database;
  int? uid;
  int? companyId;

  Future<dynamic> getAnalyticAccountList() async {
    pref = await SharedPreferences.getInstance();
    urlLink = await pref.getString('url');
    header_cookie = await pref.getString('header_cookie');
    database = await pref.getString('database');
    uid = await pref.getInt('uid');
    var insertResult;
    var updateResult;
    List<Map<String, dynamic>> listData = [];
    var analyticAccountDao = AnalyticAccountDao();
    List<AnalyticAccount> analyticAccountList = [];

    await analyticAccountDao.deleteAnalyticAccountRecords();

    var param = {"domain": "[('user_id','=',$uid)]"};

    var url = Uri.parse(
      '$urlLink'
      'api/get/analytic_account',
    );

    await http
        .post(
          url,
          headers: {
            'Accept': 'application/json',
            'Content-type': 'application/json',
            'db_name': database,
            'cookie': header_cookie,
          },
          body: json.encode(param),
        )
        .then((res) async {
          if (res.statusCode == 200) {
            Map<String, dynamic> result = json.decode(res.body);

            List<dynamic> list = result['result'];

            for (var element in list) {
              AnalyticAccount analyticAccount = AnalyticAccount(
                element['id'],
                element['name'],
              );

              analyticAccountList.add(analyticAccount);
            }

            if (analyticAccountList.isNotEmpty) {
              insertResult = await await analyticAccountDao
                  .insertAnalyticAccount(analyticAccountList);
            }
          } else {
            insertResult = 'Something Wrong';
          }
        })
        .catchError((e) {
          insertResult = e.toString();
        });
    return insertResult;
  }
}
