import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:intl/intl.dart';
import 'package:talent/presentation/screens/payslip/pay_slip_list_page.dart';
import 'package:talent/presentation/widgets/no_data.dart';
import 'package:talent/utility/style/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/api/pay_slip_api.dart';
import '../../../data/database/dao/employee_dao.dart';
import '../../../data/models/employee/employee.dart';
import '../../../data/models/pay_slip/pay_slip.dart';
// import '../../widgets/drawer_widget.dart';
// import '../../widgets/drawer_body.dart';

class PaySlipScreen extends StatefulWidget {
  var startDate;
  var endDate;
  PaySlipModel paySlipModel;
  PaySlipScreen(this.startDate, this.endDate, this.paySlipModel);

  @override
  State<PaySlipScreen> createState() => _PaySlipScreenState();
}

class _PaySlipScreenState extends State<PaySlipScreen> {
  int p = 0;
  var paySlipApi = PaySlipAPI();
  NumberFormat numberFormat = NumberFormat("#,###.00", "en_US");
  var pref;
  int? userId;
  Employee? employee;
  var employeeDao = EmployeeDao();
  var password;
  bool createPassword = false;
  double grossEarning = 0;
  double grossDeduction = 0;
  PaySlipModel? paySlipModel;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    loadData();
  }

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
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushAndRemoveUntil(context,
            MaterialPageRoute(builder: (BuildContext context) {
          return PaySlipListScreen();
        }), (r) {
          return false;
        });
        // Navigator.pop(context);

        return false;
      },
      child: Scaffold(
          appBar: AppBar(
            elevation: 0,
            backgroundColor: ColorObj.mainColor,
            title: Text(
              "Pay Slip",
              style: TextStyle(fontSize: 16),
            ),
          ),
          body: paySlipModel != null
              ? ListView.builder(
                  itemCount: 1,
                  itemBuilder: (context, page) {
                    print(
                        'paySlipModel!.idNumber------------${paySlipModel!.idNumber}  : ${widget.startDate}');
                    DateTime startDate = DateTime.parse(paySlipModel!.dateFrom);
                    DateTime endDate = DateTime.parse(paySlipModel!.dateTo);
                    double totalDeduction = 0;
                    grossEarning = 0;
                    grossDeduction = 0;
                    for (int i = 0; i < paySlipModel!.payLineList.length; i++) {
                      if ((paySlipModel!.payLineList[i]['category_name'] ==
                                  'Allowance' ||
                              paySlipModel!.payLineList[i]['category_name'] ==
                                  'Basic') &&
                          paySlipModel!.payLineList[i]['total'] > 0)
                        grossEarning = grossEarning +
                            double.parse(paySlipModel!.payLineList[i]['total']
                                .toString());

                      if ((paySlipModel!.payLineList[i]['category_name'] ==
                              'Deduction') &&
                          paySlipModel!.payLineList[i]['total'] > 0) {
                        grossDeduction = grossDeduction +
                            double.parse(paySlipModel!.payLineList[i]['total']
                                .toString());
                      }
                    }

                    return paySlipModel!.dateFrom == widget.startDate &&
                            paySlipModel!.dateTo == widget.endDate
                        ? Container(
                            //  height: MediaQuery.of(context).size.height,
                            child: Column(
                              // mainAxisSize: MainAxisSize.max,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  // decoration: BoxDecoration(
                                  //     border: Border.all(color: ColorObj.mainColor, width: 3)),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Center(
                                      //     child: const Text(
                                      //   "Asia Matrix",
                                      //   style: TextStyle(
                                      //       color: Colors.black,
                                      //       fontSize: 17,
                                      //       fontWeight: FontWeight.bold),
                                      // )),
                                      // SizedBox(
                                      //   height: 7,
                                      // ),
                                      // MediaQuery.of(context).size.width > 400
                                      //     ? Center(
                                      //         child: Text(
                                      //           "Room(1005), Building(B) , Delta Plaza,Shwegondaing Road,\nBahan Township,Yangon,\nMyanmar YANGON (MM) 11201 MYANMAR",
                                      //           style: TextStyle(
                                      //               fontSize: 14,
                                      //               color: ColorObj.greyColor8),
                                      //           // overflow: TextOverflow.ellipsis,
                                      //         ),
                                      //       )
                                      //     : Center(
                                      //         child: Text(
                                      //           "Room(1005), Building(B) ,\nDelta Plaza,Shwegondaing Road,\nBahan Township,Yangon,\nMyanmar YANGON (MM)\n11201 MYANMAR",
                                      //           style: TextStyle(
                                      //               fontSize: 14,
                                      //               color: ColorObj.greyColor8),
                                      //           // overflow: TextOverflow.ellipsis,
                                      //         ),
                                      //       ),
                                      // SizedBox(
                                      //   height: 10,
                                      // ),
                                      Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                            color: Colors.grey[300],
                                            //color: Color(0xff2d70be),//5a8bce  0xff105fcc
                                            shape: BoxShape.rectangle,
                                            border:
                                                Border.all(color: Colors.grey)),
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 8.0,
                                              right: 8.0,
                                              top: 10,
                                              bottom: 10),
                                          child: Text(
                                            'Salary Slip',
                                            style:
                                                boldXLBlackText, //boldLargeWhiteText
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.rectangle,
                                          border: Border(
                                              bottom: BorderSide(
                                                  width: 1, color: Colors.grey),
                                              left: BorderSide(
                                                  width: 1, color: Colors.grey),
                                              right: BorderSide(
                                                  width: 1,
                                                  color: Colors.grey)),
                                        ),
                                        child: IntrinsicHeight(
                                          child: Row(
                                            children: [
                                              Expanded(
                                                flex: 2,
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Text(
                                                    'Reference',
                                                    style:
                                                        normalMediumBalckText,
                                                  ),
                                                ),
                                              ),
                                              VerticalDivider(
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
                                                          bottom: 8),
                                                  child: Text(
                                                    paySlipModel!.refrence,
                                                    style:
                                                        normalMediumBalckText,
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
                                          border: Border(
                                              bottom: BorderSide(
                                                  width: 1, color: Colors.grey),
                                              left: BorderSide(
                                                  width: 1, color: Colors.grey),
                                              right: BorderSide(
                                                  width: 1,
                                                  color: Colors.grey)),
                                        ),
                                        child: IntrinsicHeight(
                                          child: Row(
                                            children: [
                                              Expanded(
                                                flex: 2,
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Text(
                                                    'Employee Name',
                                                    style:
                                                        normalMediumBalckText,
                                                  ),
                                                ),
                                              ),
                                              VerticalDivider(
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
                                                          bottom: 8),
                                                  child: Text(
                                                    paySlipModel!.employeeName,
                                                    style:
                                                        normalMediumBalckText,
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
                                          border: Border(
                                              bottom: BorderSide(
                                                  width: 1, color: Colors.grey),
                                              left: BorderSide(
                                                  width: 1, color: Colors.grey),
                                              right: BorderSide(
                                                  width: 1,
                                                  color: Colors.grey)),
                                        ),
                                        child: IntrinsicHeight(
                                          child: Row(
                                            children: [
                                              Expanded(
                                                flex: 2,
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Text(
                                                    'Employee Code',
                                                    style:
                                                        normalMediumBalckText,
                                                  ),
                                                ),
                                              ),
                                              VerticalDivider(
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
                                                          bottom: 8),
                                                  child: Text(
                                                    paySlipModel!.registerNum,
                                                    style:
                                                        normalMediumBalckText,
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
                                          border: Border(
                                              bottom: BorderSide(
                                                  width: 1, color: Colors.grey),
                                              left: BorderSide(
                                                  width: 1, color: Colors.grey),
                                              right: BorderSide(
                                                  width: 1,
                                                  color: Colors.grey)),
                                        ),
                                        child: IntrinsicHeight(
                                          child: Row(
                                            children: [
                                              Expanded(
                                                flex: 2,
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Text(
                                                    'Department',
                                                    style:
                                                        normalMediumBalckText,
                                                  ),
                                                ),
                                              ),
                                              VerticalDivider(
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
                                                          bottom: 8),
                                                  child: Text(
                                                    paySlipModel!.department
                                                        .toString(),
                                                    style:
                                                        normalMediumBalckText,
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
                                          border: Border(
                                              bottom: BorderSide(
                                                  width: 1, color: Colors.grey),
                                              left: BorderSide(
                                                  width: 1, color: Colors.grey),
                                              right: BorderSide(
                                                  width: 1,
                                                  color: Colors.grey)),
                                        ),
                                        child: IntrinsicHeight(
                                          child: Row(
                                            children: [
                                              Expanded(
                                                flex: 2,
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Text(
                                                    'Position',
                                                    style:
                                                        normalMediumBalckText,
                                                  ),
                                                ),
                                              ),
                                              VerticalDivider(
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
                                                          bottom: 8),
                                                  child: Text(
                                                    paySlipModel!.position,
                                                    style:
                                                        normalMediumBalckText,
                                                    textAlign: TextAlign.right,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      // Container(
                                      //   width: double.infinity,
                                      //   decoration: BoxDecoration(
                                      //     shape: BoxShape.rectangle,
                                      //     border: Border(
                                      //         bottom: BorderSide(
                                      //             width: 1, color: Colors.grey),
                                      //         left: BorderSide(
                                      //             width: 1, color: Colors.grey),
                                      //         right: BorderSide(
                                      //             width: 1,
                                      //             color: Colors.grey)),
                                      //   ),
                                      //   child: IntrinsicHeight(
                                      //     child: Row(
                                      //       children: [
                                      //         Expanded(
                                      //           flex: 2,
                                      //           child: Container(
                                      //             padding:
                                      //                 const EdgeInsets.all(8.0),
                                      //             child: Text(
                                      //               'Job Grade',
                                      //               style:
                                      //                   normalMediumBalckText,
                                      //             ),
                                      //           ),
                                      //         ),
                                      //         VerticalDivider(
                                      //           color: Colors.grey,
                                      //           thickness: 1,
                                      //         ),
                                      //         Expanded(
                                      //           flex: 3,
                                      //           child: Container(
                                      //             padding:
                                      //                 const EdgeInsets.only(
                                      //                     right: 10.0,
                                      //                     top: 8,
                                      //                     bottom: 8),
                                      //             child: Text(
                                      //               paySlipModel!.job_grade
                                      //                   .toString(),
                                      //               style:
                                      //                   normalMediumBalckText,
                                      //               textAlign: TextAlign.right,
                                      //             ),
                                      //           ),
                                      //         ),
                                      //       ],
                                      //     ),
                                      //   ),
                                     
                                      // ),
                                   
                                      Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          shape:
                                              BoxShape.rectangle, //0xff437C17
                                          //  color: Color(0xff018506), //0xff518dd3  Color(0xff5a8bce)   387C44
                                          color: Color(0xff017220),
                                          border: Border(
                                              bottom: BorderSide(
                                                  width: 1, color: Colors.grey),
                                              left: BorderSide(
                                                  width: 1, color: Colors.grey),
                                              right: BorderSide(
                                                  width: 1,
                                                  color: Colors.grey)),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(
                                              8.0), //0xff4682B4
                                          child: Text(
                                            'Gross Salary',
                                            style: boldLargeWhiteText,
                                          ),
                                        ),
                                      ),
                                      for (var i
                                          in paySlipModel!.payLineList) ...[
                                        if ((i['category_name'] == 'Basic' ||
                                                i['category_name'] ==
                                                    'Hourly Rate' ||
                                                i['category_name'] ==
                                                    'Allowance' ||
                                                i['category_name'] ==
                                                    'Daily Rate') &&
                                            i['total'] > 0) ...[
                                          Container(
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.rectangle,
                                              border: Border(
                                                  bottom: BorderSide(
                                                      width: 1,
                                                      color: Colors.grey),
                                                  left: BorderSide(
                                                      width: 1,
                                                      color: Colors.grey),
                                                  right: BorderSide(
                                                      width: 1,
                                                      color: Colors.grey)),
                                            ),
                                            child: IntrinsicHeight(
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    flex: 2,
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Text(
                                                        i['name'],
                                                        style:
                                                            normalMediumBalckText,
                                                      ),
                                                    ),
                                                  ),
                                                  VerticalDivider(
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
                                                              bottom: 8),
                                                      child: Text(
                                                        numberFormat.format(
                                                            double.parse(i[
                                                                    'total']
                                                                .toString()
                                                                .split(
                                                                    ' ')[0])),
                                                        textAlign:
                                                            TextAlign.right,
                                                        style:
                                                            normalMediumBalckText,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ]
                                      ],
                                      Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.rectangle,
                                          border: Border(
                                              bottom: BorderSide(
                                                  width: 1, color: Colors.grey),
                                              left: BorderSide(
                                                  width: 1, color: Colors.grey),
                                              right: BorderSide(
                                                  width: 1,
                                                  color: Colors.grey)),
                                        ),
                                        child: IntrinsicHeight(
                                          child: Row(
                                            children: [
                                              Expanded(
                                                flex: 2,
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Text(
                                                    'Gross Earning',
                                                    style: boldMediumBlackText,
                                                  ),
                                                ),
                                              ),
                                              VerticalDivider(
                                                color: Colors.grey,
                                                thickness: 1,
                                              ),
                                              Expanded(
                                                flex: 3,
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Text(
                                                    numberFormat
                                                        .format(grossEarning),
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
                                          color: Color.fromARGB(255, 175, 4,
                                              4), //0xff4682B4  0xfffa81811
                                          border: Border(
                                              bottom: BorderSide(
                                                  width: 1, color: Colors.grey),
                                              left: BorderSide(
                                                  width: 1, color: Colors.grey),
                                              right: BorderSide(
                                                  width: 1,
                                                  color: Colors.grey)),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            'Deduction',
                                            style: boldLargeWhiteText,
                                          ),
                                        ),
                                      ),
                                      for (var i
                                          in paySlipModel!.payLineList) ...[
                                        if (i['category_name'] == 'Deduction' &&
                                            double.parse(
                                                    i['amount'].toString()) >
                                                0) ...[
                                          Container(
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.rectangle,
                                              border: Border(
                                                  bottom: BorderSide(
                                                      width: 1,
                                                      color: Colors.grey),
                                                  left: BorderSide(
                                                      width: 1,
                                                      color: Colors.grey),
                                                  right: BorderSide(
                                                      width: 1,
                                                      color: Colors.grey)),
                                            ),
                                            child: IntrinsicHeight(
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    flex: 2,
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Text(
                                                        i['name'],
                                                        style:
                                                            normalMediumBalckText,
                                                      ),
                                                    ),
                                                  ),
                                                  VerticalDivider(
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
                                                              bottom: 8),
                                                      child: Text(
                                                        numberFormat.format(
                                                            double.parse(i[
                                                                    'total']
                                                                .toString()
                                                                .split(
                                                                    ' ')[0])),
                                                        textAlign:
                                                            TextAlign.right,
                                                        style:
                                                            normalMediumBalckText,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ]
                                      ],
                                      Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.rectangle,
                                          border: Border(
                                              bottom: BorderSide(
                                                  width: 1, color: Colors.grey),
                                              left: BorderSide(
                                                  width: 1, color: Colors.grey),
                                              right: BorderSide(
                                                  width: 1,
                                                  color: Colors.grey)),
                                        ),
                                        child: IntrinsicHeight(
                                          child: Row(
                                            children: [
                                              Expanded(
                                                flex: 2,
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Text(
                                                    'Gross Deduction',
                                                    style: boldMediumBlackText,
                                                  ),
                                                ),
                                              ),
                                              VerticalDivider(
                                                color: Colors.grey,
                                                thickness: 1,
                                              ),
                                              Expanded(
                                                flex: 3,
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Text(
                                                    // numberFormat.format(
                                                    //     totalDeduction),
                                                    numberFormat
                                                        .format(grossDeduction),
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
                                          border: Border(
                                              bottom: BorderSide(
                                                  width: 1, color: Colors.grey),
                                              left: BorderSide(
                                                  width: 1, color: Colors.grey),
                                              right: BorderSide(
                                                  width: 1,
                                                  color: Colors.grey)),
                                        ),
                                        child: IntrinsicHeight(
                                          child: Row(
                                            children: [
                                              Expanded(
                                                flex: 2,
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Text(
                                                    'Net Amount',
                                                    style: boldLargeBlackText,
                                                  ),
                                                ),
                                              ),
                                              VerticalDivider(
                                                color: Colors.grey,
                                                thickness: 1,
                                              ),
                                              Expanded(
                                                flex: 3,
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Text(
                                                    numberFormat.format(
                                                        paySlipModel!.net),
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
                            ),
                          )
                        : Container();
                  })
              : Container()),
    );
  }
}
