import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:talent/data/database/dao/employee_dao.dart';
import 'package:talent/data/models/expense/expense/expense.dart';
import 'package:talent/utility/share/app_strings.dart';
import 'package:talent/utility/style/theme.dart' as style;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/models/employee/employee.dart';
import '../../../utility/style/theme.dart';
import '../../../utility/utils/size_config.dart';

// ignore: must_be_immutable
class ExpenseHistoryDetailScreen extends StatefulWidget {
  Expense expense;
  ExpenseHistoryDetailScreen(this.expense, {super.key});
  @override
  State<ExpenseHistoryDetailScreen> createState() =>
      // ignore: no_logic_in_create_state
      _ExpenseHistoryDetailScreenState(expense);
}

class _ExpenseHistoryDetailScreenState
    extends State<ExpenseHistoryDetailScreen> {
  Expense expense;

  _ExpenseHistoryDetailScreenState(this.expense);

  FToast? toast;
  Employee? employee;

  var employeeDao = EmployeeDao();

  // ignore: prefer_typing_uninitialized_variables
  var uid;
  // ignore: prefer_typing_uninitialized_variables
  var pref;

  // ignore: prefer_typing_uninitialized_variables
  var stateColor;
  var state = '';
  NumberFormat numberFormat = NumberFormat("#,###", "en_US");
  var amount = '';

  Color? textColor;

  @override
  void initState() {
    toast = FToast();
    toast!.init(context);
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _loadData() async {
    log('loadData---------${expense.toJson()}');

    pref = await SharedPreferences.getInstance();
    uid = await pref.getInt('uid');

    employee = await employeeDao.getSingleEmployeeById(uid);

    if (expense.total != null) {
      amount = numberFormat.format(expense.total);
    }

    if (expense.state == 'draft') {
      state = 'To Report';
      stateColor = Colors.grey[300];
      textColor = Colors.grey[800];
    }
    if (expense.state == 'submitted') {
      state = 'Submitted';
      stateColor = Colors.orange;
      textColor = Colors.white;
    }
    if (expense.state == 'reported') {
      state = 'To Submit';
      stateColor = const Color.fromARGB(255, 107, 103, 59);
      textColor = Colors.white;
    }
    if (expense.state == 'approved') {
      state = 'Approved';
      stateColor = Colors.cyan;
      textColor = Colors.white;
    }
    if (expense.state == 'done') {
      state = 'Paid';
      stateColor = Colors.green;
      textColor = Colors.white;
    }
    if (expense.state == 'refused') {
      state = 'Refused';
      stateColor = Colors.red;
      textColor = Colors.white;
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        await Navigator.pushReplacementNamed(context, '/expense');
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: style.ColorObj.mainColor,
          title: Text(AppStrings.expenseHistoryDetail.tr(), style: appBarTitleStyle),
          leading: InkWell(
            onTap: () async {
              await Navigator.pushReplacementNamed(context, '/expense');
            },
            child: const Icon(Icons.arrow_back, color: Colors.white),
          ),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: Container(
                height: MediaQuery.of(context).size.height - 80,
                padding: const EdgeInsets.all(10),
                child: Card(
                  elevation: 2,
                  shadowColor: Colors.blue,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: <Widget>[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  AppStrings.expenseProduct.tr(),
                                  style: normalMediumGreyText,
                                ),
                                const SizedBox(height: 15),
                                Text(
                                  expense.expenseProductName!,
                                  style: normalDoubleXLBalckText,
                                  overflow: TextOverflow.visible,
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 7,
                                    vertical: 1,
                                  ),
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: stateColor,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Center(
                                    child: Text(
                                      state.toString(),
                                      style: TextStyle(
                                        fontFamily: 'Regular',
                                        fontSize: 13,
                                        color: textColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: <Widget>[
                            Icon(
                              MdiIcons.alarm,
                              size: 65,
                              color: style.ColorObj.mainColor,
                            ),
                            const SizedBox(width: 14),
                            Text(expense.date!, style: style.boldXXLBlueText),
                          ],
                        ),
                        const SizedBox(height: 15),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Expanded(
                              flex: 1,
                              child: Text(
                                AppStrings.description.tr(),
                                style: normalLargeGreyText,
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                expense.description!,
                                style: normalLargeBalckText,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Expanded(
                              flex: 1,
                              child: Text(
                                AppStrings.amount.tr(),
                                style: normalLargeGreyText,
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                amount != '' ? '$amount  Kyats' : '',
                                style: normalLargeBalckText,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Expanded(
                              flex: 1,
                              child: Text(
                                AppStrings.paidBy.tr()  ,
                                style: normalLargeGreyText,
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                expense.paidBy == 'own_account'
                                    ? AppStrings.employeeToReimburse.tr()
                                    : AppStrings.company.tr(),
                                style: normalLargeBalckText,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Expanded(
                              flex: 1,
                              child: Text(
                                AppStrings.note.tr(),
                                style: normalLargeGreyText,
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                expense.note!,
                                style: normalLargeBalckText,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
