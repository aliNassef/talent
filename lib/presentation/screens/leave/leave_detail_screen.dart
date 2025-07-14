import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:talent/data/api/leave_api.dart';
import 'package:talent/data/database/dao/attachment_dao.dart';
import 'package:talent/data/database/dao/employee_dao.dart';
import 'package:talent/data/database/dao/leave_dao.dart';
import 'package:talent/data/database/dao/leave_reason_dao.dart';
import 'package:talent/presentation/screens/leave/leave_history_list_screen.dart';
import 'package:talent/utility/style/theme.dart' as Style;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/models/attachment/attachment.dart';
import '../../../data/models/employee/employee.dart';
import '../../../data/models/leave/leave.dart';
import '../../../data/models/leave_reason/leave_reason.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../utility/style/theme.dart';
import '../../../utility/utils/size_config.dart';

class LeaveDetailScreen extends StatefulWidget {
  Leave leave;
  LeaveDetailScreen(this.leave);
  _LeaveDetailScreenState createState() => _LeaveDetailScreenState(leave);
}

class _LeaveDetailScreenState extends State<LeaveDetailScreen> {
  //API
  var leaveApi = LeaveAPI();

  //Dao
  var leaveDao = LeaveDao();
  var employeeDao = EmployeeDao();
  var attachmentDao = AttachmentDao();
  var leaveReasonDao = LeaveReasonDao();

  Leave leave;
  Employee? employee;

  //Variable
  var approvalState;
  var pref;
  var uid;
  var state = '';
  var userLevel;
  String? hourFrom, hourTo;

  FToast? toast;
  String? buttonText = 'Confirm';
  bool buttonFlag = false;
  String? duration;
  List<LeaveReason> leaveReason = [];
  List<Attachment>? attachments;
  Color? stateColor;
  Color? textColor;

  _LeaveDetailScreenState(this.leave);

  initState() {
    super.initState();
    toast = FToast();
    toast!.init(context);
    _loadData();
  }

   void dispose() {
   
    super.dispose();
  }

  _loadData() async {
    print('leave-----------${widget.leave.toJson()}');
    if (leave.state == "draft") {
      state = 'To Confirm';

      stateColor = Colors.grey[300];
      textColor = Colors.grey[800];
    } else if (leave.state == "confirm") {
      state = 'To Approve';

      stateColor = Colors.orange;
      textColor = Colors.white;
    } else if (leave.state == "validate1") {
      state = 'Second Approval';

      stateColor = Colors.cyan;
      textColor = Colors.white;
    } else if (leave.state == "validate") {
      state = 'Approved';

      stateColor = Colors.green;
      textColor = Colors.white;
    } else if (leave.state == "cancel") {
      state = "Cancelled";
      stateColor = Colors.red;
      textColor = Colors.white;
    } else if (leave.state == "refuse") {
      state = "Refused";
      stateColor = Colors.red;
      textColor = Colors.white;
    }
    duration =
        '${leave.number_of_days} days(s) (${leave.date_from} ~ ${leave.date_to})';
    pref = await SharedPreferences.getInstance();
    uid = await pref.getInt('uid');

    employee = await employeeDao.getSingleEmployeeById(uid);
  }

  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return WillPopScope(
      onWillPop: () async {
        await Navigator.of(context)
            .pushReplacement(MaterialPageRoute(builder: (context) {
          return LeaveHistoryListScreen();
        }));
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
            backgroundColor: Style.ColorObj.mainColor,
            title: Text('my_leave_history_detail'.tr()),
            leading: InkWell(
                onTap: () async {
                  await Navigator.of(context)
                      .pushReplacement(MaterialPageRoute(builder: (context) {
                    return LeaveHistoryListScreen();
                  }));
                },
                child: Container(
                    child: Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                )))),
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
                    padding: EdgeInsets.all(20),
                    child: Column(
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  'Type',
                                  style: normalMediumGreyText,
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                Text(
                                  leave != null ? leave.leave_type! : '',
                                  style: normalDoubleXLBalckText,
                                )
                              ],
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 7, vertical: 1),
                                  height: 20,
                                  decoration: BoxDecoration(
                                      color: stateColor,
                                      borderRadius: BorderRadius.circular(20)),
                                  child: Center(
                                    child: Text(
                                      state.toString(),
                                      style: TextStyle(
                                          fontFamily: 'Regular',
                                          fontSize: 13,
                                          color: textColor),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Row(
                          children: <Widget>[
                            Icon(
                              MdiIcons.alarm,
                              size: 65,
                              color: Style.ColorObj.mainColor,
                            ),
                            SizedBox(
                              width: 14,
                            ),
                            Expanded(
                              child: Text(
                                leave.write_date!.substring(0, 10),
                                style: Style.boldXXLBlueText,
                              ),
                            )
                          ],
                        ),
                        // SizedBox(
                        //   height: 15,
                        // ),
                        // Row(
                        //   crossAxisAlignment: CrossAxisAlignment.start,
                        //   children: <Widget>[
                        //     Expanded(
                        //       flex: 1,
                        //       child: Text(
                        //         '',
                        //         style: normalLargeGreyText,
                        //       ),
                        //     ),
                        //     Expanded(
                        //       flex: 1,
                        //       child: Text(
                        //         leave.employee_name!,
                        //         style: normalLargeBalckText,
                        //       ),
                        //     ),
                        //   ],
                        // ),
                        // SizedBox(
                        //   height: 15,
                        // ),
                        // Row(
                        //   crossAxisAlignment: CrossAxisAlignment.start,
                        //   children: <Widget>[
                        //     Expanded(
                        //       flex: 1,
                        //       child: Text(
                        //         'leave_type'.tr(),
                        //         style: normalLargeGreyText,
                        //       ),
                        //     ),
                        //     Expanded(
                        //       flex: 1,
                        //       child: Text(
                        //         leave != null ? leave.leave_type! : '',
                        //         // leave != null ? leave.leave_type!:'',
                        //         style: normalLargeBalckText,
                        //       ),
                        //     ),
                        //   ],
                        // ),
                        SizedBox(
                          height: 15,
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Expanded(
                              flex: 1,
                              child: Text(
                                'Leave Reason',
                                style: normalLargeGreyText,
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Flexible(
                                child: Text(
                                  leave != null ? leave.name! : '',
                                  style: normalLargeBalckText,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Expanded(
                              flex: 1,
                              child: Text(
                                'Duration',
                                style: normalLargeGreyText,
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                duration.toString(),
                                style: normalLargeBalckText,
                              ),
                            ),
                          ],
                        ),
                        Spacer(),
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
