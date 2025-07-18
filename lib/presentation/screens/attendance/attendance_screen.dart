import 'dart:async';
import 'dart:developer';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:talent/utility/share/app_strings.dart';
import 'package:talent/utility/style/theme.dart' as style;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/api/attendance_api.dart';
import '../../../data/database/dao/attendance_dao.dart';
import '../../../data/database/dao/employee_dao.dart';
import '../../../data/models/attendance/attendance.dart';
import '../../../data/models/employee/employee.dart';
import '../../../utility/style/theme.dart';
import '../../../utility/utils/size_config.dart';
import '../../widgets/custom_event_dialog.dart';
import '../../widgets/error_dialog.dart';
import '../../widgets/leave_time_picker.dart';
import '../../widgets/no_data.dart';
import '../../widgets/widgets.dart';
import '../dashboard/dashboard_main.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  AttendanceScreenState createState() => AttendanceScreenState();
}

class AttendanceScreenState extends State<AttendanceScreen> {
  //OdooUser? odooUser;
  Employee? employee;
  // ignore: prefer_typing_uninitialized_variables
  var database;
  var employeeDao = EmployeeDao();
  var attendanceDao = AttendanceDao();
  bool noMoreToShow = false;
  String filter = '';
  List<Attendance> attList = [];
  var attendanceApi = AttendanceAPI();
  bool isRead = false;
  // ignore: prefer_typing_uninitialized_variables
  var pref;
  late int uid;
  // ignore: prefer_typing_uninitialized_variables
  var userLevel;
  var startDate = '';
  var endDate = '';
  var todayDate = '';
  var chosenStartDate = '', chosenEndDate = '';
  DateTime selectedStartDate = DateTime.now();
  DateTime selectedEndDate = DateTime.now();
  // ignore: prefer_typing_uninitialized_variables
  var date;
  bool loading = false;
  double? lat, long;
  FToast? toast;
  // ignore: prefer_typing_uninitialized_variables
  var checkInOutTime;
  // ignore: prefer_typing_uninitialized_variables
  var lon;
  Attendance? lastAttendance;
  // ignore: prefer_typing_uninitialized_variables
  var address;
  // ignore: prefer_typing_uninitialized_variables
  var lastAttCheckDate;
  // ignore: prefer_typing_uninitialized_variables
  var code;
  late final DateTime init;
  late final DateTime lastDate;
  DateTime startTime = DateTime.now();
  DateTime endTime = DateTime.now();
  int totalDays = 0;
  bool selectTime = false;
  // ignore: prefer_typing_uninitialized_variables
  var password;
  bool createPassword = false;
  ValueNotifier<bool> isDialOpen = ValueNotifier(false);
  //QRViewController? controller;
  //Barcode? result;

  @override
  void initState() {
    super.initState();
    toast = FToast();
    toast!.init(context);

    lastDate = DateTime(3000);
    _loadData();
  }

  int totalDay() => totalDays = endTime.difference(startTime).inDays;

  _loadData() async {
    pref = await SharedPreferences.getInstance();
    uid = await pref.getInt('uid');
    employee = await employeeDao.getSingleEmployeeById(uid);
    todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    await checkIsCheckIn();

    password = await pref.getString('password');
    if (password == null || password == '') {
      createPassword = true;
    }

    attList = [];

    attList = await attendanceDao.getAttendanceList();

    setState(() {});

    bindData();
  }

  checkIsCheckIn() async {
    lastAttCheckDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    var tempAttendance = await attendanceDao.getTodayAttendance(
      lastAttCheckDate,
    );

    if (tempAttendance == null) {
      await pref.setBool('is_check_in', true);
    } else {
      lastAttendance = tempAttendance;
      if (lastAttendance!.check_out_time == '') {
        await pref.setBool('is_check_in', false);
      } else {
        await pref.setBool('is_check_in', true);
      }
    }

  }

  Future bindData() async {
    bool checkInternet = await InternetConnectionChecker.instance.hasConnection;
    if (checkInternet == false) {
      // ignore: use_build_context_synchronously
      showDialog(context: context, builder: (_) => CustomEventDialog());
      return;
    }
    attList = [];
    await attendanceApi.getAttendanceSetting(employee!.employee_id!);
    await attendanceApi.getAttendanceList(employee!.employee_id!);
    attList = [];
    attList = await attendanceDao.getAttendanceList();

    if (attList.isEmpty) {
      noMoreToShow = true;
      loading = false;
    } else {
      noMoreToShow = false;
      loading = false;
    }

    setState(() {});
  }

  Future<void> refreshList() async {
    bool checkInternet = await InternetConnectionChecker.instance.hasConnection;
    if (checkInternet == false) {
      // ignore: use_build_context_synchronously
      showDialog(context: context, builder: (_) => CustomEventDialog());
      return;
    }
    await bindData();
    EasyLoading.dismiss();
  }

  choiceAction(int result) {
    log('result--$result');

    switch (result) {
      case 0: //today
        filter = 'today';
        getAttendanceByFilter(filter, '', '');

        break;
      case 1: //this week
        filter = 'this_week';
        getAttendanceByFilter(filter, '', '');
        break;
      case 2: //this month
        filter = 'this_month';
        getAttendanceByFilter(filter, '', '');
        break;
      case 3: //this month
        filter = 'last_week';
        getAttendanceByFilter(filter, '', '');
        break;
      case 4: //this month
        filter = 'custom';

        setState(() {});
        Future.delayed(
          const Duration(seconds: 0),
          // ignore: use_build_context_synchronously
          () => dateRangeDialog(context),
        );

        break;
    }
  }

  /*fetch attendance by filter from server and then local database*/
  getAttendanceByFilter(String filter, String startDate, String endDate) async {
    log('getAttendanceByFilter--------------$startDate : $endDate');

    bool checkInternet = await InternetConnectionChecker.instance.hasConnection;
    if (checkInternet == false) {
      // ignore: use_build_context_synchronously
      showDialog(context: context, builder: (_) => CustomEventDialog());
      return;
    }

    await attendanceApi.getAttendanceListByFilter(filter, startDate, endDate);
    await bindData2();

    // ignore: use_build_context_synchronously
    if (filter == 'custom') Navigator.pop(context);
  }

  Future bindData2() async {
    bool checkInternet = await InternetConnectionChecker.instance.hasConnection;
    if (checkInternet == false) {
      // ignore: use_build_context_synchronously
      showDialog(context: context, builder: (_) => CustomEventDialog());
      return;
    }
    attList = [];
    attList = await attendanceDao.getAttendanceList();

    if (attList.isEmpty) {
      noMoreToShow = true;
      loading = false;
    } else {
      noMoreToShow = false;
      loading = false;
    }

    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
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
          title: Text(AppStrings.attendance, style: appBarTitleStyle),
          backgroundColor: style.ColorObj.mainColor,
          actions: [
            Padding(
              padding: const EdgeInsets.only(
                left: 10,
                top: 10,
                bottom: 10,
                right: 10,
              ),
              child: Row(
                children: [
                  InkWell(
                    onTap: () async {
                      EasyLoading.show(status: AppStrings.gettingCurrentLocation);

                      bool hasGPSPermission = false;

                      if (await Permission.location.isGranted) {
                        hasGPSPermission = true;
                      } else {
                        var status = await Permission.location.request();
                        hasGPSPermission = status.isGranted;
                      }

                      if (!hasGPSPermission) {
                        toast?.showToast(
                          child: Widgets().getWarningToast(
                            AppStrings.youAreNotAllowedToCheckInOutFromThisLocation,
                          ),
                          gravity: ToastGravity.BOTTOM,
                          toastDuration: const Duration(seconds: 3),
                        );
                      }

                      var location = await Geolocator.getCurrentPosition(
                        // ignore: deprecated_member_use
                        desiredAccuracy: LocationAccuracy.high,
                      );

                      EasyLoading.dismiss();

                      toast!.showToast(
                        child: Widgets().getInfoToast(
                          "Lat: ${location.latitude} \nLong: ${location.longitude}",
                        ),
                        gravity: ToastGravity.BOTTOM,
                        toastDuration: const Duration(seconds: 5),
                      );
                    },
                    child: const Padding(
                      padding: EdgeInsets.only(right: 15.0),
                      child: Icon(Icons.my_location, color: Colors.white),
                    ),
                  ),
                  InkWell(
                    onTap: () async {
                      bool checkInternet = await InternetConnectionChecker
                          .instance
                          .hasConnection;
                      if (checkInternet == false) {
                        showDialog(
                          // ignore: use_build_context_synchronously
                          context: context,
                          builder: (_) => CustomEventDialog(),
                        );
                        return;
                      }
                      setState(() {
                        attList = [];
                        noMoreToShow = false;
                      });
                      EasyLoading.show(status: AppStrings.fetchingData);
                      refreshList();
                    },
                    child: const Padding(
                      padding: EdgeInsets.only(right: 15.0),
                      child: Icon(Icons.refresh, color: Colors.white),
                    ),
                  ),
                  PopupMenuButton(
                    padding: const EdgeInsets.all(0),
                    child: Icon(MdiIcons.filterVariantPlus),
                    itemBuilder: (context) {
                      return [
                        PopupMenuItem(
                          onTap: () {
                            choiceAction(0);
                          },
                          height: 20,
                          padding: const EdgeInsets.only(left: 5, right: 5),
                          value: 0,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Icon(
                                      MdiIcons.calendarClock,
                                      color: ColorObj.mainColor,
                                    ),
                                  ),

                                  Expanded(
                                    flex: 4,
                                    child: Text(
                                      AppStrings.today,
                                      textAlign: TextAlign.left,
                                      style: listRow1TextStyle,
                                    ),
                                  ),
                                ],
                              ),
                              const PopupMenuDivider(),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          onTap: () {
                            choiceAction(1);
                          },
                          height: 20,
                          padding: const EdgeInsets.only(left: 5, right: 5),
                          value: 1,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Icon(
                                      MdiIcons.calendarRange,
                                      color: ColorObj.mainColor,
                                    ),
                                  ),

                                  Expanded(
                                    flex: 4,
                                    child: Text(
                                      AppStrings.thisWeek,
                                      textAlign: TextAlign.left,
                                      style: listRow1TextStyle,
                                    ),
                                  ),
                                ],
                              ),
                              const PopupMenuDivider(),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          onTap: () {
                            choiceAction(2);
                          },
                          height: 20,
                          padding: const EdgeInsets.only(left: 5, right: 5),
                          value: 2,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Icon(
                                      MdiIcons.calendarCheck,
                                      color: ColorObj.mainColor,
                                    ),
                                  ),
                                  // Expanded(
                                  //     flex: 1, child: Container()),
                                  Expanded(
                                    flex: 4,
                                    child: Text(
                                      AppStrings.thisMonth,
                                      textAlign: TextAlign.left,
                                      style: listRow1TextStyle,
                                    ),
                                  ),
                                ],
                              ),
                              const PopupMenuDivider(),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          onTap: () {
                            choiceAction(3);
                          },
                          height: 20,
                          padding: const EdgeInsets.only(left: 5, right: 5),
                          value: 3,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Icon(
                                      MdiIcons.calendarArrowLeft,
                                      color: ColorObj.mainColor,
                                    ),
                                  ),

                                  Expanded(
                                    flex: 4,
                                    child: Text(
                                      AppStrings.lastWeek,
                                      textAlign: TextAlign.left,
                                      style: listRow1TextStyle,
                                    ),
                                  ),
                                ],
                              ),
                              const PopupMenuDivider(),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          onTap: () {
                            choiceAction(4);
                          },
                          height: 20,
                          padding: const EdgeInsets.only(left: 5, right: 5),
                          value: 4,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Icon(
                                      MdiIcons.calendarEdit,
                                      color: ColorObj.mainColor,
                                    ),
                                  ),

                                  Expanded(
                                    flex: 4,
                                    child: Text(
                                      AppStrings.custom,
                                      textAlign: TextAlign.left,
                                      style: listRow1TextStyle,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ];
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        body: attList.isNotEmpty
            ? SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Container(
                            margin: const EdgeInsets.only(
                              left: 5,
                              right: 5,
                              top: 5,
                            ),
                            alignment: Alignment.center,
                            height: 42,
                            //  color: Color(0xff016976),
                            decoration: BoxDecoration(
                              color: const Color(0xff016976),
                              borderRadius: BorderRadius.circular(5),
                            ),

                            child: Text(
                              AppStrings.date,
                              textAlign: TextAlign.center,
                              style: style.tableHeadingStyle2,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Container(
                            margin: const EdgeInsets.only(
                              left: 5,
                              right: 5,
                              top: 5,
                            ),
                            alignment: Alignment.center,
                            height: 42,
                            //  color: Color(0xff016976),
                            decoration: BoxDecoration(
                              color: const Color(0xff016976),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                                AppStrings.checkIn,
                              textAlign: TextAlign.center,
                              style: style.tableHeadingStyle2,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Container(
                            margin: const EdgeInsets.only(
                              left: 5,
                              right: 5,
                              top: 5,
                            ),
                            alignment: Alignment.center,
                            height: 42,
                            //  color: Color(0xff016976),
                            decoration: BoxDecoration(
                              color: const Color(0xff016976),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              AppStrings.checkOut,
                              textAlign: TextAlign.center,
                              style: style.tableHeadingStyle2,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Container(
                            margin: const EdgeInsets.only(
                              left: 5,
                              right: 5,
                              top: 5,
                            ),
                            alignment: Alignment.center,
                            height: 42,
                            //  color: Color(0xff016976),
                            decoration: BoxDecoration(
                              color: const Color(0xff016976),
                              borderRadius: BorderRadius.circular(5),
                            ),

                            child: Text(
                              AppStrings.hours,
                              textAlign: TextAlign.center,
                              style: style.tableHeadingStyle2,
                            ),
                          ),
                        ),
                      ],
                    ),
                    ListView.builder(
                      itemCount: attList.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, i) {
                        return Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.rectangle,
                          ),
                          child: Card(
                            shadowColor: Colors.blue,
                            elevation: 2,
                            color: todayDate == attList[i].date
                                ? Colors.green
                                : Colors.white,
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    alignment: Alignment.center,
                                    height: 50,

                                    child: Text(
                                      attList[i].date!,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontFamily: 'Regular',
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: todayDate == attList[i].date
                                            ? Colors.white
                                            : const Color.fromARGB(
                                                255,
                                                54,
                                                113,
                                                143,
                                              ),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    alignment: Alignment.center,
                                    height: 40,
                                    child: Text(
                                      attList[i].check_in_time!,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontFamily: 'Regular',
                                        fontSize: 14,
                                        color: todayDate == attList[i].date
                                            ? Colors.white
                                            : Colors.grey[700],
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    alignment: Alignment.center,
                                    height: 40,
                                    child: Text(
                                      attList[i].check_out_time!,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontFamily: 'Regular',
                                        fontSize: 14,
                                        color: todayDate == attList[i].date
                                            ? Colors.white
                                            : Colors.grey[700],
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    alignment: Alignment.center,
                                    height: 40,
                                    child: Text(
                                      attList[i].working_hr!.toString(),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontFamily: 'Regular',
                                        fontSize: 14,
                                        color: todayDate == attList[i].date
                                            ? Colors.white
                                            : Colors.grey[700],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              )
            : noMoreToShow
            ? noDataWidget()
            : const Center(child: CircularProgressIndicator()),

        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: Colors.grey, width: 0.4)),
          ),
          alignment: Alignment.center,
          height: 25,
          width: double.infinity,
          child: attList.isNotEmpty
              ? Text(
                  '${attList.length} ${AppStrings.recordsFound}',
                  style: normalMediumGreyText,
                )
              : Text(AppStrings.zeroRecordsFound, style: normalMediumGreyText),
        ),
      ),
    );
  }

  /*widget */
  Widget attendanceDataScreen(Attendance attendance) {
    return Column(
      children: <Widget>[
        Row(
          children: [
            Expanded(flex: 1, child: Center(child: Text(attendance.date!))),
            Container(height: 25, width: 2, color: Colors.grey),
            Expanded(
              flex: 1,
              child: Center(child: Text(attendance.check_in_time!)),
            ),
            Container(height: 25, width: 2, color: Colors.grey),
            Expanded(
              flex: 1,
              child: Center(child: Text(attendance.check_out_time!)),
            ),
            Container(height: 25, width: 2, color: Colors.grey),
            Expanded(
              flex: 1,
              child: Center(child: Text(attendance.working_hr!.toString())),
            ),
          ],
        ),
        const Divider(color: Colors.grey, thickness: 1.5),
      ],
    );
  }

  dateRangeDialog(BuildContext context) async {
    log('dateRangeDialog-------${MediaQuery.of(context).size.width}');
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: SizedBox(
                //  padding: EdgeInsets.only(left:10,right: 10),
                width: MediaQuery.of(context).size.width * 0.7,
                height: MediaQuery.of(context).size.height * 0.40,
                child: Column(
                  children: [
                    Container(
                      //   padding: const EdgeInsets.only(left: 30),
                      alignment: Alignment.center,
                      // width: MediaQuery.of(context).size.width * 0.7,
                      height: MediaQuery.of(context).size.height * 0.07,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8),
                        ),
                        color: ColorObj.mainColor,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text(
                              AppStrings.chooseDate,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                              refreshList();
                            },
                            icon: const Icon(Icons.close, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    // SizedBox(
                    //   height: 40,
                    // ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.22,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            height: MediaQuery.of(context).size.height * 0.06,
                            child: TimePickerWidget(
                              //edit border radius in library
                              text: AppStrings.startDate,
                              timePicker: (t) {
                                setState(() {
                                  startTime = t;
                                  selectTime = true;
                                  totalDays = -1;
                                });
                              },
                              init: startTime,
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.03,
                          ),
                          Center(
                            child: SizedBox(
                              height: MediaQuery.of(context).size.height * 0.05,
                              child: Text(
                                AppStrings.to,
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: ColorObj.textColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.02,
                          ),

                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            height: MediaQuery.of(context).size.height * 0.06,
                            child: TimePickerWidget(
                              text: AppStrings.endDate,
                              timePicker: (t) {
                                setState(() {
                                  endTime = t;
                                  totalDays = totalDay();
                                  if (totalDays < 0) {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return ErrorDialog(
                                          title: AppStrings.endDateSelectError,
                                          content: Text(  
                                            AppStrings.pleaseSelectCorrectEndDate,
                                            style: const TextStyle(
                                              color: ColorObj.textColor,
                                              fontSize: 15,
                                            ),
                                          ),
                                          icon: Icons.warning,
                                        );
                                      },
                                    );
                                  }
                                });
                              },
                              init: endTime,
                              totalDays: totalDays,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // const SizedBox(
                    //   height: 40,
                    // ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.07,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          SizedBox(
                            width: 80,
                            child: TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                refreshList();
                              },
                              child: Text(
                                AppStrings.cancel,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 80,
                            // height: 30,
                            child: TextButton(
                              onPressed: () async {
                                log('confirm-total------$totalDays');
                                if (selectTime == false) {
                                  toast!.showToast(
                                    child: Widgets().getWarningToast(
                                      AppStrings.pleaseSelectStartDate,
                                    ),
                                    gravity: ToastGravity.BOTTOM,
                                    toastDuration: const Duration(seconds: 2),
                                  );
                                }

                                if (totalDays <= 0) {
                                  toast!.showToast(
                                    child: Widgets().getWarningToast(
                                      AppStrings.pleaseSelectValidDate,
                                    ),
                                    gravity: ToastGravity.BOTTOM,
                                    toastDuration: const Duration(seconds: 2),
                                  );
                                } else {
                                  getAttendanceByFilter(
                                    filter,
                                    startTime.toString().split(' ')[0],
                                    endTime.toString().split(' ')[0],
                                  );
                                }
                              },
                              child: Text(
                                AppStrings.confirm,
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
