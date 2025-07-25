import 'dart:developer';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:talent/data/api/leave_api.dart';
import 'package:talent/data/database/dao/employee_dao.dart';
import 'package:talent/data/database/dao/leave_dao.dart';
import 'package:talent/data/database/dao/leave_remain.dart';
import 'package:talent/data/database/dao/leave_type_dao.dart';
import 'package:talent/utility/share/app_strings.dart';
import 'package:talent/utility/style/theme.dart' as style;
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../data/models/employee/employee.dart';
import '../../../data/models/leave/leave.dart';
import '../../../data/models/leave_remain/leave_remain.dart';
import '../../../data/models/leave_type/leave_type.dart';
import '../../../utility/style/theme.dart';
import '../../../utility/utils/size_config.dart';
import '../../widgets/custom_event_dialog.dart';
import '../dashboard/dashboard_main.dart'; 

class LeaveDashBoardScreen extends StatefulWidget {
  const LeaveDashBoardScreen({super.key});

  @override
  LeaveDashBoardScreenState createState() => LeaveDashBoardScreenState();
}

class LeaveDashBoardScreenState extends State<LeaveDashBoardScreen>
    with TickerProviderStateMixin {
  //API
  var leaveApi = LeaveAPI();

  //Dao
  var employeeDao = EmployeeDao();
  var leaveTypeDao = LeaveTypeDao();
  var leaveRemainDao = LeaveRemainDao();

  //Model
  Employee? employee;
  LeaveType? leaveType;
  LeaveRemain? leaveRemain;
  List<DateTime> toHighlight = [];
  DateTime? _selectedDay;
  DateTime _focusedDay = DateTime.now();

  //Variable
  // ignore: prefer_typing_uninitialized_variables
  var pref;
  int? userId;
  FToast? toast;
  // ignore: prefer_typing_uninitialized_variables
  var userLevel;
  Color? progressColor = Colors.grey;
  double percent = 0, usedDayCount = 0;
  List<Color> colorList = [];
  List<Color> textColorList = [];
  List<LeaveType> leaveTypeList = [];
  List<LeaveRemain> leaveRemainList = [];
  late AnimationController _animationController;

  // ignore: prefer_typing_uninitialized_variables
  var password;
  bool createPassword = false;
  bool doneRefresh = false;
  List<Leave> leaveList = [];

  bool showLeaveDetail = false;
  late Leave leaveDetail;
  var leaveDao = LeaveDao();
  ValueNotifier<bool> isDialOpen = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    toast = FToast();
    toast!.init(context);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _animationController.forward();
    loadData();
  }

  @override
  void dispose() {
    _animationController.dispose();

    super.dispose();
  }

  loadData() async {
    pref = await SharedPreferences.getInstance();
    userId = await pref.getInt('uid');

    employee = await employeeDao.getSingleEmployeeById(userId!);
    await loadDataFromDatabase();

    password = await pref.getString('password');
    if (password == null || password == '') {
      createPassword = true;
    }

    //EasyLoading.show(status: 'Fetching data...........');

    // await leaveApi.getLeaveList();
    // await leaveApi.getLeaveTypeList();
    await loadDataFromDatabase();

    await leaveApi.getLeaveRemainingList();
    await leaveApi.getLeaveList();
    await leaveApi.getLeaveTypeList();

    //await leaveApi.getUpcomingHolidayList();
    await loadDataFromDatabase();
    // EasyLoading.dismiss();
  }

  loadDataFromDatabase() async {
    leaveRemainList = [];
    leaveList = [];
    leaveRemainList = await leaveRemainDao.getLeaveRemainList();
    if (leaveRemainList.isNotEmpty) {
      // ignore: unused_local_variable
      for (var element in leaveRemainList) {
        colorList.add(const Color(0xffDCDCDC));
        textColorList.add(Colors.grey);
      }

      colorList[0] = Colors.blue;
      textColorList[0] = Colors.white;
      usedDayCount =
          leaveRemainList[0].total_days! - leaveRemainList[0].remaining_days!;
      percent = usedDayCount / 100;
      progressColor = Colors.blue;
    }

    leaveList = await leaveDao.getLeaveList();
    DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
    DateTime dateTime;

    dateFormat.format(DateTime.now()); //Converting DateTime object to String
    for (var element in leaveList) {
      dateTime = dateFormat.parse('${element.date_from!} 00:00:00');
      toHighlight.add(dateTime);
      dateTime = dateFormat.parse('${element.date_to!} 00:00:00');
      toHighlight.add(dateTime);
    }

    setState(() {});
  }

  bindLeaveProgress(LeaveRemain leaveRemain) async {
    usedDayCount = leaveRemain.total_days! - leaveRemain.remaining_days!;
    percent = usedDayCount / 100;
    log('percent-------$percent');
  }

  Future<void> refreshList() async {
    // doneRefresh = true;
    // leaveTypeList = [];
    // leaveRemainList = [];
    // await loadDataFromDatabase();
    bool checkInternet = await InternetConnectionChecker.instance.hasConnection;
    if (checkInternet == false) {
      // ignore: use_build_context_synchronously
      showDialog(context: context, builder: (_) => CustomEventDialog());
      return;
    }

    EasyLoading.show(status: 'Fetching data...........');
    log('leaveRemainList1-------${leaveRemainList.length}');
    await leaveApi.getLeaveTypeList();
    await leaveApi.getLeaveList();

    await leaveApi.getLeaveRemainingList();
    await leaveApi.getUpcomingHolidayList();
    await loadDataFromDatabase();

    log('leaveRemainList2-------${leaveRemainList.length}');
    doneRefresh = false;
    EasyLoading.dismiss();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
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
          backgroundColor: style.ColorObj.mainColor,
          title: Text(AppStrings.leaveDashboard.tr(), style: style.appBarTitleStyle),
          actions: [
            IgnorePointer(
              ignoring: doneRefresh,
              child: InkWell(
                onTap: () {
                  setState(() {
                    //leaveRemainList = [];
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
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: DateTime.now(),

                startingDayOfWeek: StartingDayOfWeek.monday,
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  //centerHeaderTitle: true
                ),
                calendarBuilders: CalendarBuilders(
                  defaultBuilder: (context, day, focusedDay) {
                    for (DateTime d in toHighlight) {
                      if (day.day == d.day &&
                          day.month == d.month &&
                          day.year == d.year) {
                        return Container(
                          decoration: const BoxDecoration(
                            // color: Color.fromARGB(255, 2, 81, 165),
                            color: Colors.white,
                            shape: BoxShape.circle,
                            // borderRadius: BorderRadius.all(
                            //   Radius.circular(100.0),//8
                            // ),
                          ),
                          child: Center(
                            child: Text(
                              '${day.day}',
                              style: const TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      }
                    }
                    return null;
                  },
                ),
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },
                onDaySelected: (selectedDay, focusedDay) async {
                  log('selectedDay------------$selectedDay');

                  leaveList = await leaveDao.getLeaveList();

                  DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");

                  String string = dateFormat.format(
                    selectedDay,
                  ); //Converting DateTime object to String

                  log('string-----$string');

                  //DateTime dateTime = dateFormat.parse(string); //Converting String to DateTime object

                  for (int i = 0; i < leaveList.length; i++) {
                    log('ele--------: ${leaveList[i].date_from}  :  $string');

                    if (string.substring(0, 10) == leaveList[i].date_from ||
                        string.substring(0, 10) == leaveList[i].date_to) {
                      log('same leave-${leaveList[i].toJson()}');
                      showLeaveDetail = true;
                      leaveDetail = leaveList[i];

                      setState(() {});

                      log('leaveDetail-------$leaveDetail');
                      log('leaveDetail2-------${leaveDetail.toJson()}');

                      break;
                    } else {
                      showLeaveDetail = false;
                      setState(() {});
                    }
                  }

                  setState(() {
                    log(
                      'setState----------$_selectedDay  :  $selectedDay - $_focusedDay  : $focusedDay',
                    );
                    _selectedDay = selectedDay;
                    _focusedDay =
                        focusedDay; // update `_focusedDay` here as well
                  });
                },
              ),
              const SizedBox(height: 15),
              if (showLeaveDetail)
                Container(
                  padding: const EdgeInsets.only(
                    left: 15,
                    top: 5,
                    bottom: 5,
                    right: 10,
                  ),
                  width: double.infinity,
                  color: Colors.grey[300],
                  child: Text(
                    leaveDetail.leave_type.toString(),
                    style: boldLargeBlackText,
                  ),
                ),
              if (showLeaveDetail)
                Container(
                  padding: const EdgeInsets.only(
                    left: 15,
                    top: 5,
                    bottom: 5,
                    right: 10,
                  ),
                  width: double.infinity,
                  child: Text(
                    leaveDetail.name.toString(),
                    style: normalMediumBalckText,
                  ),
                ),

              SizedBox(
                height: 100.0,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: leaveRemainList.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          colorList = [];
                          textColorList = [];

                          // ignore: unused_local_variable
                          for (var element in leaveRemainList) {
                            colorList.add(const Color(0xffDCDCDC));
                            textColorList.add(Colors.grey);
                          }
                          if (index == 0) {
                            colorList[index] = Colors.blue;

                            textColorList[index] = Colors.white;
                            progressColor = Colors.blue;
                          }
                          if (index == 1) {
                            colorList[index] = Colors.cyan;
                            textColorList[index] = Colors.white;
                            progressColor = Colors.cyan;
                          }
                          if (index == 2) {
                            colorList[index] = Colors.orange;
                            textColorList[index] = Colors.white;
                            progressColor = Colors.orange;
                          }
                          if (index == 3) {
                            colorList[index] = Colors.green;
                            textColorList[index] = Colors.white;
                            progressColor = Colors.green;
                          }
                          if (index == 4) {
                            colorList[index] = Colors.purple;
                            textColorList[index] = Colors.white;
                            progressColor = Colors.purple;
                          }

                          if (index == 5) {
                            colorList[index] = Colors.brown;
                            textColorList[index] = Colors.white;
                            progressColor = Colors.brown;
                          }

                          if (index == 6) {
                            colorList[index] = Colors.amber;
                            textColorList[index] = Colors.white;
                            progressColor = Colors.amber;
                          }
                          if (index == 7) {
                            colorList[index] = Colors.deepPurple;
                            textColorList[index] = Colors.white;
                            progressColor = Colors.deepPurple;
                          }
                          if (index == 8) {
                            colorList[index] = Colors.yellow;
                            textColorList[index] = Colors.white;
                            progressColor = Colors.yellow;
                          }
                          if (index == 9) {
                            colorList[index] = Colors.teal;
                            textColorList[index] = Colors.white;
                            progressColor = Colors.teal;
                          }

                          bindLeaveProgress(leaveRemainList[index]);
                          setState(() {});
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.all(8),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: colorList[index],
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey[300]!,
                              blurRadius: 2.0,
                              spreadRadius: 2.0,
                              offset: const Offset(1.0, 1.0),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              leaveRemainList[index].name!,
                              style: TextStyle(
                                color: textColorList[index],
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              leaveRemainList[index].remaining_days.toString(),
                              style: TextStyle(
                                color: textColorList[index],
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              AppStrings.remain.tr(),
                              style: TextStyle(
                                color: textColorList[index],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              CircularPercentIndicator(
                radius: 60,
                lineWidth: 12.0,
                animation: true,
                percent: percent,
                center: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      AppStrings.used.tr(),
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    Text(
                      usedDayCount.toString(),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      AppStrings.days.tr(),
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
                progressColor: progressColor,
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
