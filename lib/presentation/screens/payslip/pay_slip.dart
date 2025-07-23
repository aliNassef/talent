import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:talent/presentation/screens/payslip/pay_slip_list_page.dart';
import 'package:talent/utility/share/app_strings.dart';
import 'package:talent/utility/style/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/api/pay_slip_api.dart';
import '../../../data/database/dao/employee_dao.dart';
import '../../../data/models/employee/employee.dart';
import '../../../data/models/pay_slip/pay_slip.dart';

// ignore: must_be_immutable
class PaySlipScreen extends StatefulWidget {
  // ignore: prefer_typing_uninitialized_variables
  var startDate;
  // ignore: prefer_typing_uninitialized_variables
  var endDate;
  PaySlipModel paySlipModel;
  PaySlipScreen(this.startDate, this.endDate, this.paySlipModel, {super.key});

  @override
  State<PaySlipScreen> createState() => _PaySlipScreenState();
}

class _PaySlipScreenState extends State<PaySlipScreen> {
  int p = 0;
  var paySlipApi = PaySlipAPI();
  NumberFormat numberFormat = NumberFormat("#,###.00", "en_US");
  // ignore: prefer_typing_uninitialized_variables
  var pref;
  int? userId;
  Employee? employee;
  var employeeDao = EmployeeDao();
  // ignore: prefer_typing_uninitialized_variables
  var password;
  bool createPassword = false;
  double grossEarning = 0;
  double grossDeduction = 0;
  PaySlipModel? paySlipModel;

  @override
  void initState() {
    super.initState();

    loadData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  loadData() async {
    pref = await SharedPreferences.getInstance();
    userId = await pref.getInt('uid');
    employee = await employeeDao.getSingleEmployeeById(userId!);
    paySlipModel = widget.paySlipModel;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) {
              return const PaySlipListScreen();
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
          elevation: 0,
          backgroundColor: ColorObj.mainColor,
          title: Text(AppStrings.paySlip.tr(), style: const TextStyle(fontSize: 16)),
        ),
        body: paySlipModel != null
            ? ListView.builder(
                itemCount: 1,
                itemBuilder: (context, page) {
                  grossEarning = 0;
                  grossDeduction = 0;
                  for (int i = 0; i < paySlipModel!.payLineList.length; i++) {
                    if ((paySlipModel!.payLineList[i]['category_name'] ==
                                'Allowance' ||
                            paySlipModel!.payLineList[i]['category_name'] ==
                                'Basic') &&
                        paySlipModel!.payLineList[i]['total'] > 0) {
                      grossEarning =
                          grossEarning +
                          double.parse(
                            paySlipModel!.payLineList[i]['total'].toString(),
                          );
                    }

                    if ((paySlipModel!.payLineList[i]['category_name'] ==
                            'Deduction') &&
                        paySlipModel!.payLineList[i]['total'] > 0) {
                      grossDeduction =
                          grossDeduction +
                          double.parse(
                            paySlipModel!.payLineList[i]['total'].toString(),
                          );
                    }
                  }

                  return paySlipModel!.dateFrom == widget.startDate &&
                          paySlipModel!.dateTo == widget.endDate
                      ? Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      shape: BoxShape.rectangle,
                                      border: Border.all(color: Colors.grey),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                        left: 8.0,
                                        right: 8.0,
                                        top: 10,
                                        bottom: 10,
                                      ),
                                      child: Text(
                                        AppStrings.salarySlip.tr(),
                                        style:
                                            boldXLBlackText, //boldLargeWhiteText
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: double.infinity,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.rectangle,
                                      border: Border(
                                        bottom: BorderSide(
                                          width: 1,
                                          color: Colors.grey,
                                        ),
                                        left: BorderSide(
                                          width: 1,
                                          color: Colors.grey,
                                        ),
                                        right: BorderSide(
                                          width: 1,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                    child: IntrinsicHeight(
                                      child: Row(
                                        children: [
                                          Expanded(
                                            flex: 2,
                                            child: Container(
                                              padding: const EdgeInsets.all(
                                                8.0,
                                              ),
                                              child: Text(
                                                AppStrings.reference.tr(),
                                                style: normalMediumBalckText,
                                              ),
                                            ),
                                          ),
                                          const VerticalDivider(
                                            color: Colors.grey,
                                            thickness: 1,
                                          ),
                                          Expanded(
                                            flex: 3,
                                            child: Container(
                                              padding: const EdgeInsets.only(
                                                right: 10.0,
                                                top: 8,
                                                bottom: 8,
                                              ),
                                              child: Text(
                                                paySlipModel!.refrence,
                                                style: normalMediumBalckText,
                                                textAlign: TextAlign.right,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: double.infinity,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.rectangle,
                                      border: Border(
                                        bottom: BorderSide(
                                          width: 1,
                                          color: Colors.grey,
                                        ),
                                        left: BorderSide(
                                          width: 1,
                                          color: Colors.grey,
                                        ),
                                        right: BorderSide(
                                          width: 1,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                    child: IntrinsicHeight(
                                      child: Row(
                                        children: [
                                          Expanded(
                                            flex: 2,
                                            child: Container(
                                              padding: const EdgeInsets.all(
                                                8.0,
                                              ),
                                              child: Text(
                                                AppStrings.employeeName.tr(),
                                                style: normalMediumBalckText,
                                              ),
                                            ),
                                          ),
                                          const VerticalDivider(
                                            color: Colors.grey,
                                            thickness: 1,
                                          ),
                                          Expanded(
                                            flex: 3,
                                            child: Container(
                                              padding: const EdgeInsets.only(
                                                right: 10.0,
                                                top: 8,
                                                bottom: 8,
                                              ),
                                              child: Text(
                                                paySlipModel!.employeeName,
                                                style: normalMediumBalckText,
                                                textAlign: TextAlign.right,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: double.infinity,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.rectangle,
                                      border: Border(
                                        bottom: BorderSide(
                                          width: 1,
                                          color: Colors.grey,
                                        ),
                                        left: BorderSide(
                                          width: 1,
                                          color: Colors.grey,
                                        ),
                                        right: BorderSide(
                                          width: 1,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                    child: IntrinsicHeight(
                                      child: Row(
                                        children: [
                                          Expanded(
                                            flex: 2,
                                            child: Container(
                                              padding: const EdgeInsets.all(
                                                8.0,
                                              ),
                                              child: Text(
                                                AppStrings.employeeCode.tr(),
                                                style: normalMediumBalckText,
                                              ),
                                            ),
                                          ),
                                          const VerticalDivider(
                                            color: Colors.grey,
                                            thickness: 1,
                                          ),
                                          Expanded(
                                            flex: 3,
                                            child: Container(
                                              padding: const EdgeInsets.only(
                                                right: 10.0,
                                                top: 8,
                                                bottom: 8,
                                              ),
                                              child: Text(
                                                paySlipModel!.registerNum,
                                                style: normalMediumBalckText,
                                                textAlign: TextAlign.right,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: double.infinity,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.rectangle,
                                      border: Border(
                                        bottom: BorderSide(
                                          width: 1,
                                          color: Colors.grey,
                                        ),
                                        left: BorderSide(
                                          width: 1,
                                          color: Colors.grey,
                                        ),
                                        right: BorderSide(
                                          width: 1,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                    child: IntrinsicHeight(
                                      child: Row(
                                        children: [
                                          Expanded(
                                            flex: 2,
                                            child: Container(
                                              padding: const EdgeInsets.all(
                                                8.0,
                                              ),
                                              child: Text(
                                                AppStrings.department.tr(),
                                                style: normalMediumBalckText,
                                              ),
                                            ),
                                          ),
                                          const VerticalDivider(
                                            color: Colors.grey,
                                            thickness: 1,
                                          ),
                                          Expanded(
                                            flex: 3,
                                            child: Container(
                                              padding: const EdgeInsets.only(
                                                right: 10.0,
                                                top: 8,
                                                bottom: 8,
                                              ),
                                              child: Text(
                                                paySlipModel!.department
                                                    .toString(),
                                                style: normalMediumBalckText,
                                                textAlign: TextAlign.right,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: double.infinity,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.rectangle,
                                      border: Border(
                                        bottom: BorderSide(
                                          width: 1,
                                          color: Colors.grey,
                                        ),
                                        left: BorderSide(
                                          width: 1,
                                          color: Colors.grey,
                                        ),
                                        right: BorderSide(
                                          width: 1,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                    child: IntrinsicHeight(
                                      child: Row(
                                        children: [
                                          Expanded(
                                            flex: 2,
                                            child: Container(
                                              padding: const EdgeInsets.all(
                                                8.0,
                                              ),
                                              child: Text(
                                                AppStrings.position.tr(),
                                                style: normalMediumBalckText,
                                              ),
                                            ),
                                          ),
                                          const VerticalDivider(
                                            color: Colors.grey,
                                            thickness: 1,
                                          ),
                                          Expanded(
                                            flex: 3,
                                            child: Container(
                                              padding: const EdgeInsets.only(
                                                right: 10.0,
                                                top: 8,
                                                bottom: 8,
                                              ),
                                              child: Text(
                                                paySlipModel!.position,
                                                style: normalMediumBalckText,
                                                textAlign: TextAlign.right,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  Container(
                                    width: double.infinity,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.rectangle, //0xff437C17
                                      //  color: Color(0xff018506), //0xff518dd3  Color(0xff5a8bce)   387C44
                                      color: Color(0xff017220),
                                      border: Border(
                                        bottom: BorderSide(
                                          width: 1,
                                          color: Colors.grey,
                                        ),
                                        left: BorderSide(
                                          width: 1,
                                          color: Colors.grey,
                                        ),
                                        right: BorderSide(
                                          width: 1,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(
                                        8.0,
                                      ), //0xff4682B4
                                      child: Text(
                                        AppStrings.grossSalary.tr(),
                                        style: boldLargeWhiteText,
                                      ),
                                    ),
                                  ),
                                  for (var i in paySlipModel!.payLineList) ...[
                                    if ((i['category_name'] == 'Basic' ||
                                            i['category_name'] ==
                                                'Hourly Rate' ||
                                            i['category_name'] == 'Allowance' ||
                                            i['category_name'] ==
                                                'Daily Rate') &&
                                        i['total'] > 0) ...[
                                      Container(
                                        width: double.infinity,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.rectangle,
                                          border: Border(
                                            bottom: BorderSide(
                                              width: 1,
                                              color: Colors.grey,
                                            ),
                                            left: BorderSide(
                                              width: 1,
                                              color: Colors.grey,
                                            ),
                                            right: BorderSide(
                                              width: 1,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ),
                                        child: IntrinsicHeight(
                                          child: Row(
                                            children: [
                                              Expanded(
                                                flex: 2,
                                                child: Container(
                                                  padding: const EdgeInsets.all(
                                                    8.0,
                                                  ),
                                                  child: Text(
                                                    i['name'],
                                                    style:
                                                        normalMediumBalckText,
                                                  ),
                                                ),
                                              ),
                                              const VerticalDivider(
                                                color: Colors.grey,
                                                thickness: 1,
                                              ),
                                              Expanded(
                                                flex: 3,
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        right: 10.0,
                                                        top: 8,
                                                        bottom: 8,
                                                      ),
                                                  child: Text(
                                                    numberFormat.format(
                                                      double.parse(
                                                        i['total']
                                                            .toString()
                                                            .split(' ')[0],
                                                      ),
                                                    ),
                                                    textAlign: TextAlign.right,
                                                    style:
                                                        normalMediumBalckText,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                  Container(
                                    width: double.infinity,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.rectangle,
                                      border: Border(
                                        bottom: BorderSide(
                                          width: 1,
                                          color: Colors.grey,
                                        ),
                                        left: BorderSide(
                                          width: 1,
                                          color: Colors.grey,
                                        ),
                                        right: BorderSide(
                                          width: 1,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                    child: IntrinsicHeight(
                                      child: Row(
                                        children: [
                                          Expanded(
                                            flex: 2,
                                            child: Container(
                                              padding: const EdgeInsets.all(
                                                8.0,
                                              ),
                                              child: Text(
                                                AppStrings.grossEarning.tr(),
                                                style: boldMediumBlackText,
                                              ),
                                            ),
                                          ),
                                          const VerticalDivider(
                                            color: Colors.grey,
                                            thickness: 1,
                                          ),
                                          Expanded(
                                            flex: 3,
                                            child: Container(
                                              padding: const EdgeInsets.all(
                                                8.0,
                                              ),
                                              child: Text(
                                                numberFormat.format(
                                                  grossEarning,
                                                ),
                                                style: boldMediumBlackText,
                                                textAlign: TextAlign.right,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: double.infinity,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.rectangle,
                                      color: Color.fromARGB(
                                        255,
                                        175,
                                        4,
                                        4,
                                      ), //0xff4682B4  0xfffa81811
                                      border: Border(
                                        bottom: BorderSide(
                                          width: 1,
                                          color: Colors.grey,
                                        ),
                                        left: BorderSide(
                                          width: 1,
                                          color: Colors.grey,
                                        ),
                                        right: BorderSide(
                                          width: 1,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        AppStrings.deduction.tr(),
                                        style: boldLargeWhiteText,
                                      ),
                                    ),
                                  ),
                                  for (var i in paySlipModel!.payLineList) ...[
                                    if (i['category_name'] == 'Deduction' &&
                                        double.parse(i['amount'].toString()) >
                                            0) ...[
                                      Container(
                                        width: double.infinity,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.rectangle,
                                          border: Border(
                                            bottom: BorderSide(
                                              width: 1,
                                              color: Colors.grey,
                                            ),
                                            left: BorderSide(
                                              width: 1,
                                              color: Colors.grey,
                                            ),
                                            right: BorderSide(
                                              width: 1,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ),
                                        child: IntrinsicHeight(
                                          child: Row(
                                            children: [
                                              Expanded(
                                                flex: 2,
                                                child: Container(
                                                  padding: const EdgeInsets.all(
                                                    8.0,
                                                  ),
                                                  child: Text(
                                                    i['name'],
                                                    style:
                                                        normalMediumBalckText,
                                                  ),
                                                ),
                                              ),
                                              const VerticalDivider(
                                                color: Colors.grey,
                                                thickness: 1,
                                              ),
                                              Expanded(
                                                flex: 3,
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        right: 10.0,
                                                        top: 8,
                                                        bottom: 8,
                                                      ),
                                                  child: Text(
                                                    numberFormat.format(
                                                      double.parse(
                                                        i['total']
                                                            .toString()
                                                            .split(' ')[0],
                                                      ),
                                                    ),
                                                    textAlign: TextAlign.right,
                                                    style:
                                                        normalMediumBalckText,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                  Container(
                                    width: double.infinity,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.rectangle,
                                      border: Border(
                                        bottom: BorderSide(
                                          width: 1,
                                          color: Colors.grey,
                                        ),
                                        left: BorderSide(
                                          width: 1,
                                          color: Colors.grey,
                                        ),
                                        right: BorderSide(
                                          width: 1,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                    child: IntrinsicHeight(
                                      child: Row(
                                        children: [
                                          Expanded(
                                            flex: 2,
                                            child: Container(
                                              padding: const EdgeInsets.all(
                                                8.0,
                                              ),
                                              child: Text(
                                                AppStrings.grossDeduction.tr(),
                                                style: boldMediumBlackText,
                                              ),
                                            ),
                                          ),
                                          const VerticalDivider(
                                            color: Colors.grey,
                                            thickness: 1,
                                          ),
                                          Expanded(
                                            flex: 3,
                                            child: Container(
                                              padding: const EdgeInsets.all(
                                                8.0,
                                              ),
                                              child: Text(
                                                numberFormat.format(
                                                  grossDeduction,
                                                ),
                                                style: boldMediumBlackText,
                                                textAlign: TextAlign.right,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.rectangle,
                                      color: Colors.grey[300],
                                      border: const Border(
                                        bottom: BorderSide(
                                          width: 1,
                                          color: Colors.grey,
                                        ),
                                        left: BorderSide(
                                          width: 1,
                                          color: Colors.grey,
                                        ),
                                        right: BorderSide(
                                          width: 1,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                    child: IntrinsicHeight(
                                      child: Row(
                                        children: [
                                          Expanded(
                                            flex: 2,
                                            child: Container(
                                              padding: const EdgeInsets.all(
                                                8.0,
                                              ),
                                              child: Text(
                                                AppStrings.netAmount.tr(),
                                                style: boldLargeBlackText,
                                              ),
                                            ),
                                          ),
                                          const VerticalDivider(
                                            color: Colors.grey,
                                            thickness: 1,
                                          ),
                                          Expanded(
                                            flex: 3,
                                            child: Container(
                                              padding: const EdgeInsets.all(
                                                8.0,
                                              ),
                                              child: Text(
                                                numberFormat.format(
                                                  paySlipModel!.net,
                                                ),
                                                style: boldXLBlackText,
                                                textAlign: TextAlign.right,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : Container();
                },
              )
            : Container(),
      ),
    );
  }
}
