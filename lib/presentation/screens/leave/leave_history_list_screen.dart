import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:talent/data/database/dao/attachment_dao.dart';
import 'package:talent/data/database/dao/leave_dao.dart';
import 'package:talent/presentation/screens/leave/leave_dashboard.dart';
import 'package:talent/utility/style/theme.dart' as Style;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/api/leave_api.dart';
import '../../../data/database/dao/employee_dao.dart';
import '../../../data/helper/constant.dart';
import '../../../data/models/employee/employee.dart';
import '../../../data/models/leave/leave.dart';
import '../../../utility/style/theme.dart';
import '../../widgets/custom_event_dialog.dart';
// import '../../widgets/drawer_body.dart';
import '../../widgets/no_data.dart';
import '../dashboard/dashboard_main.dart';
import 'leave_detail_screen.dart';
import 'leave_request_screen.dart';

class LeaveHistoryListScreen extends StatefulWidget {
  _LeaveHistoryListScreenState createState() => _LeaveHistoryListScreenState();
}

class _LeaveHistoryListScreenState extends State<LeaveHistoryListScreen> {
  //API
  var leaveApi = LeaveAPI();

//Dao
  var leaveDao = LeaveDao();
  var employeeDao = EmployeeDao();
  var attachmentDao = AttachmentDao();

  Employee? employee;

//Variable
  var pref;
  var userId;
  FToast? toast;
  bool waitingFlag = false;
  String? leaveReasonStr;
  bool noMoreToShow = false;
  bool loading = false;
  List<Leave> leaveList = [];
  final ScrollController _scrollController = ScrollController();
  bool doneRefresh = false;
  ValueNotifier<bool> isDialOpen = ValueNotifier(false);

  @override
  initState() {
    super.initState();
    toast = FToast();
    toast!.init(context);
    // for (int i = 0; i < menuActive.length; i++) {
    //   menuActive[i] = false;
    // }
    // menuActive[6] = true;
    _loadData();
  }

  _loadData() async {
    pref = await SharedPreferences.getInstance();
    userId = await pref.getInt('uid');

    employee = await employeeDao.getSingleEmployeeById(userId!);
    loading = true;
    leaveList = [];
    leaveList = await leaveDao.getLeaveList();

    setState(() {});

    await bindData();
  }

  Future bindData() async {
    bool checkInternet = await InternetConnectionChecker.instance.hasConnection;
    if (checkInternet == false) {
      if (!mounted) return;
      showDialog(context: context, builder: (_) => CustomEventDialog());
      return;
    }
    leaveList = [];
    await leaveApi.getLeaveList();
    leaveList = [];
    leaveList = await leaveDao.getLeaveList();

    print('leave list 2--------${leaveList.length}');

    if (leaveList.isEmpty) {
      noMoreToShow = true;
      loading = false;
    } else {
      noMoreToShow = false;
      loading = false;
    }

    setState(() {});
  }

  void dispose() {
    super.dispose();
  }

  Future<Null> refreshList() async {
    bool checkInternet = await InternetConnectionChecker.instance.hasConnection;
    if (checkInternet == false) {
      showDialog(context: context, builder: (_) => CustomEventDialog());
      return;
    }
    EasyLoading.show(status: 'Fetching data...........');
    doneRefresh = true;
    setState(() {});

    await bindData();
    doneRefresh = false;
    EasyLoading.dismiss();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (isDialOpen.value) {
          isDialOpen.value = false;
          return false;
        }
        Navigator.pushAndRemoveUntil(context,
            MaterialPageRoute(builder: (BuildContext context) {
          return HomeScreen();
        }), (r) {
          return false;
        });
        // Navigator.pop(context);

        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Style.ColorObj.mainColor,
          title: Text(
            'my_leave_history'.tr(),
            style: Style.appBarTitleStyle,
          ),
          leading: InkWell(
              onTap: () {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) {
                  return const HomeScreen();
                }));
              },
              child: const Padding(
                padding: EdgeInsets.only(right: 10.0),
                child: Icon(
                  Icons.home,
                  size: 25,
                  color: Colors.white,
                ),
              )),
          actions: [
            IgnorePointer(
              ignoring: doneRefresh,
              child: InkWell(
                  onTap: () {
                    setState(() {
                      // leaveList = [];
                      noMoreToShow = false;
                    });
                    refreshList();
                  },
                  child: const Padding(
                    padding: EdgeInsets.only(right: 10.0),
                    child: Icon(
                      Icons.refresh,
                      color: Colors.white,
                    ),
                  )),
            )
          ],
        ),
        body: leaveList.length > 0
            ? ListView.builder(
                itemCount: leaveList.length,
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                itemBuilder: (_, index) {
                  Leave leave = leaveList[index];

                  print('leave-------${leave.toJson()}');
                  String state = '';
                  String duration =
                      '${leave.number_of_days} days(s) (${leave.date_from} ~ ${leave.date_to})';
                  Color? stateColor;
                  Color? textColor;

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
                  return GestureDetector(
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => LeaveDetailScreen(leave))),
                    child: LeaveRequestCard(
                      date: leave.date_from!,
                      day: leave.date_from!.substring(8, 10),
                      reason: '',
                      leaveType: leave.leave_type!,
                      status: state,
                      statusColor: stateColor!,
                    ),

                    // Card(

                    //   elevation: 3,
                    //   shadowColor: Colors.blue,
                    //   child: Padding(
                    //     padding: EdgeInsets.all(15),
                    //     child: Row(
                    //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //       children: <Widget>[
                    //         Expanded(
                    //           child: Column(
                    //             mainAxisAlignment: MainAxisAlignment.start,
                    //             crossAxisAlignment: CrossAxisAlignment.start,
                    //             children: <Widget>[
                    //               Text(

                    //                 (leave.leaveReason).toString(),
                    //                 style: sectionHeaderTextStyle,
                    //               ),
                    //               SizedBox(
                    //                 height: 8,
                    //               ),
                    //               Text(

                    //                 (leave.leave_type).toString(),
                    //                 style: listRow1TextStyle,
                    //               ),
                    //               SizedBox(
                    //                 height: 8,
                    //               ),
                    //               Text(
                    //                 duration.toString(),
                    //                 style: listRow2TextStyle,
                    //               ),
                    //               SizedBox(
                    //                 height: 8,
                    //               ),
                    //               Text(
                    //                 leave.name!,
                    //                 style: listRow2TextStyle,
                    //                 overflow: TextOverflow.ellipsis,
                    //                 maxLines: 1,
                    //               )
                    //             ],
                    //           ),
                    //         ),
                    //         Column(
                    //           mainAxisAlignment: MainAxisAlignment.start,
                    //           children: <Widget>[
                    //             Container(
                    //               padding: EdgeInsets.symmetric(
                    //                   horizontal: 7, vertical: 1),
                    //               height: 20,
                    //               decoration: BoxDecoration(
                    //                   color: stateColor,
                    //                   borderRadius:
                    //                       BorderRadius.circular(20)),
                    //               child: Center(
                    //                 child: Text(
                    //                   state.toString(),
                    //                   style: TextStyle(
                    //                       fontFamily: 'Regular',
                    //                       fontSize: 13,
                    //                       color: textColor),
                    //                 ),
                    //               ),
                    //             ),
                    //           ],
                    //         )
                    //       ],
                    //     ),
                    //   ),
                    // ),
                  );
                },
              )
            : noMoreToShow
                ? noDataWidget()
                : Center(
                    child: Container(
                    child: CircularProgressIndicator(),
                  )),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(
                color: Colors.grey,
                width: 0.5,
              ),
            ),
          ),
          alignment: Alignment.center,
          height: 25,
          width: double.infinity,
          child: leaveList.length > 0
              ? Text(
                  '${leaveList.length} records found',
                  style: normalMediumGreyText,
                )
              : Text(
                  '0 records found',
                  style: normalMediumGreyText,
                ),
        ),
        floatingActionButton: SpeedDial(
          animatedIcon: AnimatedIcons.menu_close,
          openCloseDial: isDialOpen,
          children: [
            SpeedDialChild(
                backgroundColor: ColorObj.mainColor,
                child: Icon(
                  MdiIcons.calendarAccount,
                  color: Colors.white,
                ),
                label: 'new_leave_request'.tr(),
                onTap: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (builder) => LeaveRequestScreen()))),

            // SpeedDialChild(
            //     backgroundColor: ColorObj.mainColor,
            //     child: Icon(MdiIcons.beach, color: Colors.white),
            //     label: 'holiday'.tr(),
            //     onTap: () => Navigator.push(
            //         context,
            //         MaterialPageRoute(
            //             builder: (builder) => UpcomingHolidayScreen()))),
          ],
        ),
      ),
    );
  }
}

class LeaveRequestCard extends StatelessWidget {
  final String date;
  final String day;
  final String reason;
  final String leaveType;
  final String status;
  final Color statusColor;

  LeaveRequestCard({
    required this.date,
    required this.day,
    required this.reason,
    required this.leaveType,
    required this.status,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    var dateTime1 = DateFormat('yyyy-MM-dd').parse(date);

    final DateFormat format = DateFormat('MMM');

    var month = format.format(dateTime1);
   return Card(
      margin: EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column( // Use Column to stack the month and day containers
              children: [
                Container(
                  width: 60, // Adjust width as needed
                  height: 20, // Adjust height as needed
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 97, 96, 96), // Darker grey for the month
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
                  decoration: BoxDecoration(
                    color: Colors.grey[200], // Lighter grey for the day
                    borderRadius: const BorderRadius.only(
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
                  Text(
                    reason,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        leaveType,
                        style: const TextStyle(fontSize: 14,color: Colors.grey),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.2),
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}