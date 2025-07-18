import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:talent/data/database/dao/expense/expense_dao.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talent/utility/share/app_strings.dart';
import '../../../data/api/analytic_account_api.dart';
import '../../../data/api/expense_api.dart';
import '../../../data/api/expense_product_api.dart';
import '../../../data/api/expense_tax_api.dart';
import '../../../data/database/dao/employee_dao.dart';
import '../../../data/models/employee/employee.dart';
import '../../../data/models/expense/expense/expense.dart';
import '../../../utility/style/theme.dart';
import '../../widgets/custom_event_dialog.dart';
import '../../widgets/no_data.dart';
import '../dashboard/dashboard_main.dart';
import 'expense_history_detail.dart';
import 'expense_request_page.dart';

class ExpenseListPage extends StatefulWidget {
  const ExpenseListPage({Key? key}) : super(key: key);

  @override
  State<ExpenseListPage> createState() => _ExpenseListPageState();
}

class _ExpenseListPageState extends State<ExpenseListPage> {
  List<Expense> expenseList = [];
  var expenseDao = ExpenseDao();
  bool noMoreToShow = false;
  // ignore: prefer_typing_uninitialized_variables
  var userId;
  // ignore: non_constant_identifier_names
  int data_storage_period = 0;
  FToast? toast;
  // ignore: prefer_typing_uninitialized_variables
  var pref;
  // ignore: prefer_typing_uninitialized_variables
  var uid;
  var employeeDao = EmployeeDao();

  Employee? employee;
  bool loading = false;
  var expenseApi = ExpenseAPI();
  bool doneRefresh = false;
  // ignore: prefer_typing_uninitialized_variables
  var password;
  bool createPassword = false;
  ValueNotifier<bool> isDialOpen = ValueNotifier(false);

  var analyticAccountAPI = AnalyticAccountAPI();
  var expProductApi = ExpenseProductAPI();
  var expenseTaxApi = ExpenseTaxAPI();

  @override
  void initState() {
    super.initState();
    toast = FToast();
    toast!.init(context);
    loadData();
  }

  @override
  void dispose() {
    isDialOpen.dispose();

    super.dispose();
  }

  loadData() async {
    // await analyticAccountAPI.getAnalyticAccountList();
    pref = await SharedPreferences.getInstance();
    uid = await pref.getInt('uid');
    employee = await employeeDao.getSingleEmployeeById(uid);

    password = await pref.getString('password');
    if (password == null || password == '') {
      createPassword = true;
    }

    expenseList = await expenseDao.getExpenseList();
    log('expenseList  1--------  ${expenseList.length}');
    // await analyticAccountAPI.getAnalyticAccountList();
    setState(() {});
    await bindData();
  }

  Future bindData() async {
    log('bindData--------');
    bool checkInternet = await InternetConnectionChecker.instance.hasConnection;
    if (checkInternet == false) {
      // ignore: use_build_context_synchronously
      showDialog(context: context, builder: (_) => CustomEventDialog());
      return;
    }
    expenseList = [];
    await expenseApi.getExpenseListOnline();

    await expProductApi.getExpenseProductListOnline();

    await expenseTaxApi.getExpenseTaxListOnline();

    // expenseList = [];
    log('expenseList  22222--------${expenseList.length}');
    expenseList = await expenseDao.getExpenseList();

    log('expenseList  2--------${expenseList.length}');

    if (expenseList.isEmpty) {
      noMoreToShow = true;
      loading = false;
    } else {
      noMoreToShow = false;
      loading = false;
    }

    setState(() {});
  }

  Future refreshList() async {
    bool checkInternet = await InternetConnectionChecker.instance.hasConnection;
    if (checkInternet == false) {
      // ignore: use_build_context_synchronously
      showDialog(context: context, builder: (_) => CustomEventDialog());
      return;
    }
    EasyLoading.show(status: 'Fetching data...........');
    doneRefresh = true;
    // setState(() {});
    //await expenseDao.deleteExpenseRecords();

    await bindData();
    doneRefresh = false;
    EasyLoading.dismiss();
    setState(() {});
  }

  goToExpenseDetail(BuildContext context, Expense expenseObj) async {
    log('goToSREntry----${expenseObj.toJson()}');

    await Navigator.of(context)
        .pushReplacement(
          MaterialPageRoute(
            builder: (context) {
              return ExpenseHistoryDetailScreen(expenseObj);
            },
          ),
        )
        .then((value) {
          log('1');
          loadData();
        });
  }

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        if (isDialOpen.value) {
          isDialOpen.value = false;
          return false;
        }
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) {
              return const HomeScreen();
            },
          ),
          (r) {
            return false;
          },
        );
        // Navigator.pop(context);

        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: InkWell(
            onTap: () {
              if (!mounted) return;
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (BuildContext context) {
                    return const HomeScreen();
                  },
                ),
              );
            },
            child: const Icon(Icons.home),
          ),
          title: Text(AppStrings.expenseHistoryList, style: appBarTitleStyle),
          backgroundColor: ColorObj.mainColor,
          actions: [
            IgnorePointer(
              ignoring: doneRefresh,
              child: InkWell(
                onTap: () {
                  setState(() {
                    // expenseList = [];
                    noMoreToShow = false;
                  });

                  refreshList();
                },
                child: const Padding(
                  padding: EdgeInsets.only(right: 10.0),
                  child: Icon(Icons.refresh, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
        // drawer: drawerWidget(context, employee, odoo, createPassword),
        body: expenseList.isNotEmpty
            ? ListView.builder(
                key: const PageStorageKey<String>('ExpList'),
                itemCount: expenseList.length,
                itemBuilder: (BuildContext context, int index) {
                  Color? stateColor;
                  var state = '';
                  if (expenseList[index].state == 'draft') {
                    state = 'To Report';
                    stateColor = Colors.grey[300];
                  }
                  if (expenseList[index].state == 'submitted') {
                    state = 'Submitted';
                    stateColor = Colors.orange;
                  }
                  if (expenseList[index].state == 'reported') {
                    state = 'To Submit';
                    stateColor = const Color.fromARGB(255, 107, 103, 59);
                  }
                  if (expenseList[index].state == 'approved') {
                    state = 'Approved';
                    stateColor = Colors.cyan;
                  }
                  if (expenseList[index].state == 'done') {
                    state = 'Paid';
                    stateColor = Colors.green;
                  }
                  if (expenseList[index].state == 'refused') {
                    state = 'Refused';
                    stateColor = Colors.red;
                  }

                  return InkWell(
                    onTap: () {
                      goToExpenseDetail(context, expenseList[index]);
                    },
                    child: ExpenseRequestCard(
                      date: expenseList[index].date!,
                      day: expenseList[index].date!.substring(8, 10),
                      description: expenseList[index].description!,
                      expenseType: expenseList[index].expenseProductName!,
                      amount: expenseList[index].total!,
                      status: state,
                      statusColor: stateColor!,
                    ),
                  );
                },
              )
            : (noMoreToShow == true)
            ? noDataWidget()
            : const Center(child: CircularProgressIndicator()),
        floatingActionButton: SpeedDial(
          openCloseDial: isDialOpen,
          animatedIcon: AnimatedIcons.menu_close,
          children: [
            SpeedDialChild(
              backgroundColor: ColorObj.mainColor,
              child: const Icon(Icons.add, color: Colors.white),
              label: AppStrings.newExpense,
              onTap: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => ExpenseEntryPage()),
              ),
            ),
            SpeedDialChild(
              backgroundColor: ColorObj.mainColor,
              child: Icon(MdiIcons.cash, color: Colors.white),
              label: AppStrings.expenseHistoryList,
              onTap: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const ExpenseListPage()),
              ),
            ),
          ],
        ),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: Colors.grey, width: 0.5)),
          ),
          alignment: Alignment.center,
          height: 25,
          width: double.infinity,
          child: expenseList.isNotEmpty
              ? Text(
                  '${expenseList.length} ${AppStrings.recordsFound}',
                  style: normalMediumGreyText,
                )
              : Text(AppStrings.zeroRecordsFound,
                  style: normalMediumGreyText),
        ),
      ),
    );
  }
}

class ExpenseRequestCard extends StatelessWidget {
  final String date;
  final String day;
  final String description;
  final String expenseType;
  final double amount;
  final String status;
  final Color statusColor;

  const ExpenseRequestCard({
    super.key,
    required this.date,
    required this.day,
    required this.description,
    required this.expenseType,
    required this.amount,
    required this.status,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    NumberFormat numberFormat = NumberFormat("#,###", "en_US");
    var dateTime1 = DateFormat('yyyy-MM-dd').parse(date);

    final DateFormat format = DateFormat('MMM');

    var month = format.format(dateTime1);
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              // Use Column to stack the month and day containers
              children: [
                Container(
                  width: 60, // Adjust width as needed
                  height: 20, // Adjust height as needed
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(
                      255,
                      97,
                      96,
                      96,
                    ), // Darker grey for the month
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8.0),
                      topRight: Radius.circular(8.0),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      month,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.white, // Month text in white
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 60, // Adjust width as needed
                  height: 30, // Adjust height as needed
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(
                      255,
                      97,
                      96,
                      96,
                    ), // Lighter grey for the day
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(8.0),
                      bottomRight: Radius.circular(8.0),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      day,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(description, style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        expenseType,
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    numberFormat.format(amount).toString(),
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
