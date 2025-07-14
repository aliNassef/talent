import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
//import 'package:talent_hr/app/baseState.dart';
import 'package:talent/utility/style/theme.dart' as style;
import 'package:permission_handler/permission_handler.dart';
//import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../data/api/attendance_api.dart';
import '../../../data/database/dao/attendance_dao.dart';
import '../../../data/database/dao/employee_dao.dart';
import '../../../data/models/attendance/attendance.dart';
import '../../../data/models/employee/employee.dart';
import '../../../utility/share/share_component.dart';
import '../../../utility/style/theme.dart';
import '../../../utility/utils/date_util.dart';
import '../../../utility/utils/size_config.dart';
import '../../widgets/custom_event_dialog.dart';
import '../../widgets/error_dialog.dart';
import '../../widgets/leave_time_picker.dart';
import '../../widgets/no_data.dart';
import '../../widgets/widgets.dart';
import '../base.account/login.dart';
import '../dashboard/dashboard_main.dart';

class AttendanceScreen extends StatefulWidget {
  _AttendanceScreenState createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  //OdooUser? odooUser;
  Employee? employee;
  var database;
  var employeeDao = EmployeeDao();
  var attendanceDao = AttendanceDao();
  bool noMoreToShow = false;
  String filter = '';
  List<Attendance> attList = [];
  var attendanceApi = AttendanceAPI();
  bool isRead = false;
  var pref;
  late int uid;
  var userLevel;
  var startDate = '';
  var endDate = '';
  var todayDate = '';
  var chosenStartDate = '', chosenEndDate = '';
  DateTime selectedStartDate = DateTime.now();
  DateTime selectedEndDate = DateTime.now();
  var date;
  bool loading = false;
  late BuildContext _scaffoldCtx;
  double? lat, long;
  FToast? toast;
  var checkInOutTime;
  bool? _isCheckIn = true;
  var lon;
  Attendance? lastAttendance;
  var address;
  var lastAttCheckDate;
  var code;
  late final DateTime init;
  late final DateTime lastDate;
  DateTime startTime = DateTime.now();
  DateTime endTime = DateTime.now();
  int totalDays = 0;
  bool selectTime = false;
  var password;
  bool createPassword = false;
  ValueNotifier<bool> isDialOpen = ValueNotifier(false);
  //QRViewController? controller;
  //Barcode? result;

  void initState() {
    toast = FToast();
    toast!.init(context);
    super.initState();
   
    lastDate = DateTime(3000);
    _loadData();
  }

  int totalDay() => totalDays = endTime.difference(startTime).inDays;

  _loadData() async {
    pref = await SharedPreferences.getInstance();
    uid = await pref.getInt('uid');
    employee = await employeeDao.getSingleEmployeeById(uid);
    todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    //code = 'AX-att-qr';
    //sharePref!.setString('code', code);

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

    var tempAttendance =
        await attendanceDao.getTodayAttendance(lastAttCheckDate);

    if (tempAttendance == null) {
      pref.setBool('is_check_in', true);
    } else {
      lastAttendance = tempAttendance;
      if (lastAttendance!.check_out_time == '') {
        pref.setBool('is_check_in', false);
      } else
        pref.setBool('is_check_in', true);
    }

    _isCheckIn = pref.getBool('is_check_in');
  }

  Future bindData() async {
    bool checkInternet = await InternetConnectionChecker.instance.hasConnection;
    if (checkInternet == false) {
      showDialog(context: context, builder: (_) => CustomEventDialog());
      return;
    }
    attList = [];
    await attendanceApi.getAttendanceSetting(employee!.employee_id!);
    await attendanceApi.getAttendanceList(employee!.employee_id!);
    attList = [];
    attList = await attendanceDao.getAttendanceList();

    if (attList.length <= 0) {
      noMoreToShow = true;
      loading = false;
    } else {
      noMoreToShow = false;
      loading = false;
    }

    setState(() {});
  }

  Future<Null> refreshList() async {
    bool checkInternet = await InternetConnectionChecker.instance.hasConnection;
    if (checkInternet == false) {
      showDialog(context: context, builder: (_) => CustomEventDialog());
      return;
    }
    await bindData();
    EasyLoading.dismiss();
  }

  choiceAction(int result) {
    print('result--$result');

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
          () => dateRangeDialog(context),
        );

        break;
    }
  }

/*fetch attendance by filter from server and then local database*/
  getAttendanceByFilter(String filter, String startDate, String endDate) async {
    print('getAttendanceByFilter--------------$startDate : $endDate');

    bool checkInternet = await    InternetConnectionChecker.instance.hasConnection;
    if (checkInternet == false) {
      showDialog(context: context, builder: (_) => CustomEventDialog());
      return;
    }

    await attendanceApi.getAttendanceListByFilter(filter, startDate, endDate);
    await bindData2();

    if (filter == 'custom') Navigator.pop(context);
  }

  Future bindData2() async {
    bool checkInternet = await InternetConnectionChecker.instance.hasConnection;
    if (checkInternet == false) {
      showDialog(context: context, builder: (_) => CustomEventDialog());
      return;
    }
    attList = [];
    attList = await attendanceDao.getAttendanceList();

    if (attList.length <= 0) {
      noMoreToShow = true;
      loading = false;
    } else {
      noMoreToShow = false;
      loading = false;
    }

    setState(() {});
  }

  void dispose() {
    // controller?.dispose();
    super.dispose();
  }

  // Future<void> scanQR2() async {
  //   bool checkInternet = await InternetConnectionChecker().hasConnection;
  //   if (checkInternet == false) {
  //     showDialog(context: context, builder: (_) => CustomEventDialog());
  //     return;
  //   }
  //   print('scanQr----------');

  //   var scanResult = await BarcodeScanner.scan();
  //   print('scanResult---------$scanResult');
  //   print(scanResult.type); // The result type (barcode, cancelled, failed)
  //   print(scanResult.rawContent); // The barcode content
  //   print(scanResult.format); // The barcode format (as enum)
  //   print(scanResult.formatNote);
  //   var firebaseQrResult = await FirebaseService.scanQr();
  //   print('firebaseQrResult---------$firebaseQrResult');
  //   if (firebaseQrResult['qr_code'] == scanResult.rawContent) {
  //     await checkIsCheckIn();
  //     await _sendAttendance();
  //   } else {
  //     EasyLoading.dismiss();
  //     toast!.showToast(
  //       child: Widgets().getWarningToast('QR not match!'),
  //       gravity: ToastGravity.BOTTOM,
  //       toastDuration: Duration(seconds: 3),
  //     );
  //   }
  // }

  // Future<void> scanQR1() async {
  //   bool checkInternet = await InternetConnectionChecker().hasConnection;
  //   if (checkInternet == false) {
  //     showDialog(context: context, builder: (_) => CustomEventDialog());
  //     return;
  //   }

  //   String qrCodeScanRes;
  //   try {
  //     print('try-----------------------------------');
  //     qrCodeScanRes = await FlutterBarcodeScanner.scanBarcode(
  //         '#ff6666', 'Cancel', true, ScanMode.QR);
  //     print('barcodeScanRes------------------------$qrCodeScanRes');
  //     var firebaseQrResult = await FirebaseService.scanQr();
  //     print('firebaseQrResult---------$firebaseQrResult');
  //     if (firebaseQrResult['qr_code'] == qrCodeScanRes) {
  //       await checkIsCheckIn();
  //       await _sendAttendance();
  //     } else {
  //       EasyLoading.dismiss();
  //       toast!.showToast(
  //         child: Widgets().getWarningToast('QR not match!'),
  //         gravity: ToastGravity.BOTTOM,
  //         toastDuration: Duration(seconds: 3),
  //       );
  //     }
  //   } on PlatformException {
  //     print('PlatformException---------------------------');
  //     EasyLoading.dismiss();
  //     qrCodeScanRes = 'Failed to get platform version.';
  //   }

  //   print('barcodeScanRes----------$qrCodeScanRes');

  //   setState(() {});
  // }

  _sendAttendance() async {
    bool checkInternet = await InternetConnectionChecker.instance.hasConnection;
    if (checkInternet == false) {
      showDialog(context: context, builder: (_) => CustomEventDialog());
      return;
    }

    Attendance? att;

    if (_isCheckIn == null || _isCheckIn!) {
      String todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
      Attendance? attendance;
      attendance =
          await attendanceDao.getTodayAttendanceCheckForCheckIn(todayDate);
      checkInOutTime = DateFormat('H:m a').format(DateTime.now());

      if (attendance != null) {
        EasyLoading.show(status: '................');
        EasyLoading.dismiss();
        toast!.showToast(
          child: Widgets().getWarningToast('Today, already check in'),
          gravity: ToastGravity.BOTTOM,
          toastDuration: Duration(seconds: 2),
        );
        return null;
      }
      att = await _insertCheckIn();
    } else {
      att = await _insertCheckout();
    }

    // EasyLoading.show(status: 'Submitting. Please Wait...');

    await _syncToServer(att);
    await refreshList();

    EasyLoading.dismiss();

    setState(() {});
  }

  Future<Attendance?> _insertCheckIn() async {
    // Attendance? attendance;
    String todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    // attendance =
    //     await attendanceDao.getTodayAttendanceCheckForCheckIn(todayDate);
    // checkInOutTime = DateFormat('H:m a').format(DateTime.now());

    // if (attendance != null) {
    //   EasyLoading.dismiss();
    //   // _dialog.hide();
    //   toast!.showToast(
    //     child: Widgets().getWarningToast('Today, already check in'),
    //     gravity: ToastGravity.BOTTOM,
    //     toastDuration: Duration(seconds: 2),
    //   );
    //   return null;
    // }
    //DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    // AndroidDeviceInfo androidDeviceInfo = await deviceInfoPlugin.androidInfo;
    var shareComponent = ShareComponentClass();
    var deviceStatus = await shareComponent.readDeviceId();
    DateTime _currentDateTime = DateTime.now();
    String check_in_datetime =
        DateUtil().getSqlDateTime(_currentDateTime, 'yyyy-MM-dd HH:mm:ss');

    Attendance att = Attendance(
        0,
        (employee!.employee_name).toString(),
        employee!.employee_id,
        uid,
        todayDate,
        check_in_datetime,
        '',
        checkInOutTime,
        '',
        "0",
        0,
        0,
        0,
        0,
        address,
        address,
        deviceStatus.id,
        //androidDeviceInfo.androidId,
        '',
        '',
        'default',
        '',
        '');

    print('att----$att');
    return att;
  }

  Future<Attendance?> _insertCheckout() async {
    Attendance? attendance;
    var todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    var tempAttendance =
        await attendanceDao.getTodayAttendanceAlreadyCheckIn(todayDate);
    checkInOutTime = DateFormat('H:m a').format(DateTime.now());

    if (tempAttendance != null) {
      attendance = tempAttendance;
      DateTime _currentDateTime = DateTime.now();
      String check_out_datetime =
          DateUtil().getSqlDateTime(_currentDateTime, 'yyyy-MM-dd HH:mm:ss');

      Attendance att = Attendance(
          attendance!.attendanceId,
          (employee!.employee_name).toString(),
          employee!.employee_id,
          attendance.user_id,
          attendance.date,
          attendance.check_in_datetime,
          check_out_datetime,
          attendance.check_in_time,
          checkInOutTime,
          attendance.working_hr,
          attendance.in_latitude,
          attendance.in_longitude,
          attendance.out_latitude,
          attendance.out_longitude,
          attendance.in_location,
          attendance.out_location,
          attendance.device_id,
          'default',
          attendance.write_date,
          attendance.att_type,
          '',
          '',
          id: attendance.id);
      print('att----$att');
      return att;
    } else {
      return null;
    }
  }

  _syncToServer(Attendance? attendance) async {
    print('_syncCheckInToServer----------');
    if (attendance == null) {
      EasyLoading.dismiss();

      toast!.showToast(
        child: Widgets().getErrorToast('Today, already check in'),
        gravity: ToastGravity.BOTTOM,
        toastDuration: Duration(seconds: 2),
      );
      return;
    }

    var checkInResult;
    EasyLoading.show(status: 'Submitting. Please Wait...');

    if (_isCheckIn!)
      checkInResult = await attendanceApi.createAttendance(attendance, '');
    else
      checkInResult = await attendanceApi.checkOutAttendance(attendance, '');

    print('checkInResult------------$checkInResult');

    if (checkInResult['result'] == 'fail') {
      var message;

      if (checkInResult['attendanceMessage'] == '') {
        message = 'Check In Fail.';
      } else {
        message = checkInResult['attendanceMessage'];
        if (message == 'Invalid cookie.') {
          EasyLoading.dismiss();
          toast!.showToast(
            child:
                Widgets().getErrorToast('Session Expired.Please login again.'),
            gravity: ToastGravity.BOTTOM,
            toastDuration: Duration(seconds: 3),
          );
          await pref.setString('jwt_token', "null");
          await Future.delayed(Duration(seconds: 4));

          Navigator.of(_scaffoldCtx).pushAndRemoveUntil(
              MaterialPageRoute(builder: (BuildContext context) {
            return LoginScreen();
          }), (route) => false);

          return;
        }
      }

      EasyLoading.dismiss();
      toast!.showToast(
        child: Widgets().getErrorToast('$message'),
        gravity: ToastGravity.BOTTOM,
        toastDuration: Duration(seconds: 6),
      );
      return;
    }

    EasyLoading.dismiss();

    toast = FToast();
    toast!.init(context); //Custom edit

    var status = checkInResult['attendanceMessage'];

    if (status == 'exist') {
      toast!.showToast(
        child: Widgets()
            .getErrorToast('Attendance date is already exist in the system.'),
        gravity: ToastGravity.BOTTOM,
        toastDuration: Duration(seconds: 3),
      );
    } else if (status == 'in') {
      toast!.showToast(
        child: Widgets().getSuccessToast('Check In Successful'),
        gravity: ToastGravity.BOTTOM,
        toastDuration: Duration(seconds: 3),
      );

      await pref.setBool('is_check_in', false);

      attendance.attendanceId =
          int.parse(checkInResult['attendanceId'].toString());
      await attendanceDao.updateAttendance(attendance);

      var resultId = await attendanceDao.insertSingleAttendance(attendance);

      attendance.id = int.parse(resultId.toString());
      await attendanceDao.updateAttendance(attendance);
      lastAttCheckDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
      var tempAttendance =
          await attendanceDao.getTodayAttendance(lastAttCheckDate);

      lastAttendance = tempAttendance;

      setState(() {});
    } else if (status == 'out') {
      print('else if Checkout successful.-------');
      toast!.showToast(
        child: Widgets().getSuccessToast('Check Out Successful'),
        gravity: ToastGravity.BOTTOM,
        toastDuration: Duration(seconds: 3),
      );

      await pref.setBool('is_check_in', true);

      attendance.id = attendance.id;
      await attendanceDao.updateAttendance(attendance);

      var tempAttendance =
          await attendanceDao.getTodayAttendance(lastAttCheckDate);

      lastAttendance = tempAttendance;

      setState(() {});
    }
  }

  Widget build(BuildContext context) {
    _scaffoldCtx = context;
    SizeConfig().init(context);
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

        return false;
      },
      child: Scaffold(
          appBar: AppBar(
              leading: InkWell(
                  onTap: () {
                    if (!mounted) return;
                    Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (BuildContext context) {
                      return HomeScreen();
                    }));
                  },
                  child: Icon(Icons.home)),
              title: Text(
                'attendance'.tr(),
                style: appBarTitleStyle,
              ),
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
                            EasyLoading.show(
                              status: 'Getting current location...',
                            );

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
                                  'You are not allowed to check in/out from this location',
                                ),
                                gravity: ToastGravity.BOTTOM,
                                toastDuration: const Duration(seconds: 3),
                              );
                            }

                            var location =
                                await Geolocator.getCurrentPosition(
                                    desiredAccuracy: LocationAccuracy.high);

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
                            child: Icon(
                              Icons.my_location,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        InkWell(
                            onTap: () async {
                              bool checkInternet =
                                  await InternetConnectionChecker.instance
                                      .hasConnection;
                              if (checkInternet == false) {
                                showDialog(
                                    context: context,
                                    builder: (_) => CustomEventDialog());
                                return;
                              }
                              setState(() {
                                //attList = [];
                                noMoreToShow = false;
                              });
                              EasyLoading.show(
                                  status: 'Fetching data...........');
                              refreshList();
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(right: 15.0),
                              child: Icon(
                                Icons.refresh,
                                color: Colors.white,
                              ),
                            )),
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
                                  padding:
                                      const EdgeInsets.only(left: 5, right: 5),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            flex: 2,
                                            child: Icon(
                                              MdiIcons.calendarClock,
                                              color: ColorObj.mainColor,
                                            ),
                                          ),
                                          // Expanded(
                                          //     flex: 1, child: Container()),
                                          Expanded(
                                              flex: 4,
                                              child: Text(
                                                "Today",
                                                textAlign: TextAlign.left,
                                                style: listRow1TextStyle,
                                              )),
                                        ],
                                      ),
                                      PopupMenuDivider()
                                    ],
                                  ),
                                  value: 0,
                                ),
                                PopupMenuItem(
                                  onTap: () {
                                    choiceAction(1);
                                  },
                                  height: 20,
                                  padding:
                                      const EdgeInsets.only(left: 5, right: 5),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            flex: 2,
                                            child: Icon(
                                              MdiIcons.calendarRange,
                                              color: ColorObj.mainColor,
                                            ),
                                          ),
                                          // Expanded(
                                          //     flex: 1, child: Container()),
                                          Expanded(
                                              flex: 4,
                                              child: Text("This Week",
                                                  textAlign: TextAlign.left,
                                                  style: listRow1TextStyle)),
                                        ],
                                      ),
                                      PopupMenuDivider()
                                    ],
                                  ),
                                  value: 1,
                                ),
                                PopupMenuItem(
                                  onTap: () {
                                    choiceAction(2);
                                  },
                                  height: 20,
                                  padding:
                                      const EdgeInsets.only(left: 5, right: 5),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
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
                                              child: Text("This Month",
                                                  textAlign: TextAlign.left,
                                                  style: listRow1TextStyle)),
                                        ],
                                      ),
                                      PopupMenuDivider()
                                    ],
                                  ),
                                  value: 2,
                                ),
                                PopupMenuItem(
                                  onTap: () {
                                    choiceAction(3);
                                  },
                                  height: 20,
                                  padding:
                                      const EdgeInsets.only(left: 5, right: 5),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            flex: 2,
                                            child: Icon(
                                              MdiIcons.calendarArrowLeft,
                                              color: ColorObj.mainColor,
                                            ),
                                          ),
                                          // Expanded(
                                          //     flex: 1, child: Container()),
                                          Expanded(
                                              flex: 4,
                                              child: Text("Last Week",
                                                  textAlign: TextAlign.left,
                                                  style: listRow1TextStyle)),
                                        ],
                                      ),
                                      PopupMenuDivider()
                                    ],
                                  ),
                                  value: 3,
                                ),
                                PopupMenuItem(
                                  onTap: () {
                                    choiceAction(4);
                                  },
                                  height: 20,
                                  padding:
                                      const EdgeInsets.only(left: 5, right: 5),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            flex: 2,
                                            child: Icon(
                                              MdiIcons.calendarEdit,
                                              color: ColorObj.mainColor,
                                            ),
                                          ),
                                          // Expanded(
                                          //     flex: 1, child: Container()),
                                          Expanded(
                                              flex: 4,
                                              child: Text("Custom",
                                                  textAlign: TextAlign.left,
                                                  style: listRow1TextStyle)),
                                        ],
                                      ),
                                    ],
                                  ),
                                  value: 4,
                                )
                              ];
                            }),
                      ],
                    )),
              ]),
          //drawer: drawerWidget(context, employee, odoo, createPassword),
          body: attList.length > 0
              ? SingleChildScrollView(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Container(
                              margin:
                                  EdgeInsets.only(left: 5, right: 5, top: 5),
                              alignment: Alignment.center,
                              height: 42,
                              //  color: Color(0xff016976),
                              decoration: BoxDecoration(
                                color: Color(0xff016976),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              // decoration: BoxDecoration(
                              //     color: Colors.grey[200],
                              //     border: Border.all(
                              //         color: Colors.grey[300]!,
                              //         width: 0.5)),
                              child: Text(
                                'Date',
                                textAlign: TextAlign.center,
                                style: style.tableHeadingStyle2,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Container(
                              margin:
                                  EdgeInsets.only(left: 5, right: 5, top: 5),
                              alignment: Alignment.center,
                              height: 42,
                              //  color: Color(0xff016976),
                              decoration: BoxDecoration(
                                color: Color(0xff016976),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                'Check In',
                                textAlign: TextAlign.center,
                                style: style.tableHeadingStyle2,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Container(
                              margin:
                                  EdgeInsets.only(left: 5, right: 5, top: 5),
                              alignment: Alignment.center,
                              height: 42,
                              //  color: Color(0xff016976),
                              decoration: BoxDecoration(
                                color: Color(0xff016976),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              // decoration: BoxDecoration(
                              //     color: Colors.grey[200],
                              //     border: Border.all(
                              //         color: Colors.grey[300]!,
                              //         width: 0.5)),
                              child: Text(
                                'Check Out',
                                textAlign: TextAlign.center,
                                style: style.tableHeadingStyle2,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Container(
                              margin:
                                  EdgeInsets.only(left: 5, right: 5, top: 5),
                              alignment: Alignment.center,
                              height: 42,
                              //  color: Color(0xff016976),
                              decoration: BoxDecoration(
                                color: Color(0xff016976),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              // decoration: BoxDecoration(
                              //     color: Colors.grey[200],
                              //     border: Border.all(
                              //         color: Colors.grey[300]!,
                              //         width: 0.5)),
                              child: Text(
                                'Hours',
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
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (context, i) {
                            var dateTime1 = DateFormat('yyyy-MM-dd')
                                .parse(attList[i].date!);

                            final DateFormat format = DateFormat('MMM');

                            var month = format.format(dateTime1);

                            return Container(
                              decoration: BoxDecoration(
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
                                        // decoration: BoxDecoration(
                                        //     border: Border.all(
                                        //         color: Colors.grey[300]!,
                                        //         width: 0.5)),
                                        child: Text(attList[i].date!,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontFamily: 'Regular',
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: todayDate ==
                                                        attList[i].date
                                                    ? Colors.white
                                                    : Color.fromARGB(
                                                        255, 54, 113, 143))),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Container(
                                        alignment: Alignment.center,
                                        height: 40,
                                        // decoration: BoxDecoration(
                                        //     border: Border.all(
                                        //         color: Colors.grey[300]!,
                                        //         width: 0.5)),
                                        child: Text(attList[i].check_in_time!,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontFamily: 'Regular',
                                                fontSize: 14,
                                                color:
                                                    todayDate == attList[i].date
                                                        ? Colors.white
                                                        : Colors.grey[700])),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Container(
                                        alignment: Alignment.center,
                                        height: 40,
                                        // decoration: BoxDecoration(
                                        //     border: Border.all(
                                        //         color: Colors.grey[300]!,
                                        //         width: 0.5)),
                                        child: Text(attList[i].check_out_time!,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontFamily: 'Regular',
                                                fontSize: 14,
                                                color:
                                                    todayDate == attList[i].date
                                                        ? Colors.white
                                                        : Colors.grey[700])),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Container(
                                        alignment: Alignment.center,
                                        height: 40,
                                        // decoration: BoxDecoration(
                                        //     border: Border.all(
                                        //         color: Colors.grey[300]!,
                                        //         width: 0.5)),
                                        child: Text(
                                            attList[i].working_hr!.toString(),
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontFamily: 'Regular',
                                                fontSize: 14,
                                                color:
                                                    todayDate == attList[i].date
                                                        ? Colors.white
                                                        : Colors.grey[700])),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                    ],
                  ),
                )
              : noMoreToShow
                  ? noDataWidget()
                  : Center(
                      child: CircularProgressIndicator(),
                    ),
          // floatingActionButton: SpeedDial(
          //   openCloseDial: isDialOpen,
          //   animatedIcon: AnimatedIcons.menu_close,
          //   shape: RoundedRectangleBorder(
          //     borderRadius: BorderRadius.all(Radius.circular(15)),
          //   ),
          //   children: <SpeedDialChild>[
          //     // SpeedDialChild(
          //     //     backgroundColor: ColorObj.mainColor,
          //     //     child: Icon(
          //     //       MdiIcons.qrcodeScan,
          //     //       color: Colors.white,
          //     //     ),
          //     //     label: 'QR Scan2',
          //     //     onTap: (){}),
          //     // SpeedDialChild(
          //     //     backgroundColor: ColorObj.mainColor,
          //     //     child: Icon(
          //     //       MdiIcons.qrcodeScan,
          //     //       color: Colors.white,
          //     //     ),
          //     //     label: 'QR Scan1',
          //     //     onTap: (){}),
          //     SpeedDialChild(
          //         backgroundColor: ColorObj.mainColor,
          //         child: Icon(
          //           MdiIcons.pen,
          //           color: Colors.white,
          //         ),
          //         label: 'Manual',
          //         onTap: () {
          //           Navigator.of(context)
          //               .push(MaterialPageRoute(builder: (context) {
          //             return ManualAttendance();
          //           })).then((value) => _loadData());
          //         }),
          //   ],
          // ),
         
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Colors.grey,
                  width: 0.4,
                ),
              ),
            ),
            alignment: Alignment.center,
            height: 25,
            width: double.infinity,
            child: attList.length > 0
                ? Text(
                    '${attList.length} records found',
                    style: normalMediumGreyText,
                  )
                : Text(
                    '0 records found',
                    style: normalMediumGreyText,
                  ),
          )),
    );
  }

/*widget */
  Widget attendanceDataScreen(Attendance attendance) {
    return Column(
      children: <Widget>[
        Row(
          children: [
            Expanded(
              flex: 1,
              child: Container(
                child: Center(
                  child: Text(attendance.date!),
                ),
              ),
            ),
            Container(
              height: 25,
              width: 2,
              color: Colors.grey,
            ),
            Expanded(
              flex: 1,
              child: Container(
                child: Center(
                  child: Text(attendance.check_in_time!),
                ),
              ),
            ),
            Container(
              height: 25,
              width: 2,
              color: Colors.grey,
            ),
            Expanded(
              flex: 1,
              child: Container(
                child: Center(
                  child: Text(attendance.check_out_time!),
                ),
              ),
            ),
            Container(
              height: 25,
              width: 2,
              color: Colors.grey,
            ),
            Expanded(
              flex: 1,
              child: Container(
                child: Center(
                  child: Text(attendance.working_hr!.toString()),
                ),
              ),
            ),
          ],
        ),
        Divider(
          color: Colors.grey,
          thickness: 1.5,
        )
      ],
    );
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedStartDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedStartDate) {
      setState(() {
        selectedStartDate = picked;

        chosenStartDate = DateFormat("yyyy-MM-dd").format(selectedStartDate);
      });
    }
    // await bindData();
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedEndDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedEndDate) {
      selectedEndDate = picked;

      chosenEndDate = DateFormat("yyyy-MM-dd").format(selectedEndDate);
    }
    setState(() {});

    // await bindData();
  }

  dateRangeDialog(
    BuildContext context,
  ) async {
    print('dateRangeDialog-------${MediaQuery.of(context).size.width}');
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
                child: Column(children: [
                  Container(
                    //   padding: const EdgeInsets.only(left: 30),
                    alignment: Alignment.center,
                    // width: MediaQuery.of(context).size.width * 0.7,
                    height: MediaQuery.of(context).size.height * 0.07,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8)),
                      color: ColorObj.mainColor,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text(
                            "Choose Date",
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                        IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                              refreshList();
                            },
                            icon: const Icon(
                              Icons.close,
                              color: Colors.white,
                            ))
                      ],
                    ),
                  ),
                  // SizedBox(
                  //   height: 40,
                  // ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.02,
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height * 0.22,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 6),
                          height: MediaQuery.of(context).size.height * 0.06,
                          child: TimePickerWidget(
                            //edit border radius in library
                            text: 'Start Date',
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
                            child: Container(
                          height: MediaQuery.of(context).size.height * 0.05,
                          child: Text(
                            "To",
                            style: TextStyle(
                                fontSize: 15,
                                color: ColorObj.textColor,
                                fontWeight: FontWeight.bold),
                          ),
                        )),

                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.02,
                        ),
                        // selectTime
                        //     ?
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 6),
                          height: MediaQuery.of(context).size.height * 0.06,
                          child: TimePickerWidget(
                            text: 'End Date',
                            timePicker: (t) {
                              setState(() {
                                endTime = t;
                                totalDays = totalDay();
                                if (totalDays < 0) {
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return ErrorDialog(
                                            title: "End Date Select Error",
                                            content: const Text(
                                              "Please select correct End Date",
                                              style: TextStyle(
                                                  color: ColorObj.textColor,
                                                  fontSize: 15),
                                            ),
                                            icon: Icons.warning);
                                      });
                                }
                              });
                            },
                            init: endTime,
                            totalDays: totalDays,
                          ),
                        )
                      ],
                    ),
                  ),
                  // const SizedBox(
                  //   height: 40,
                  // ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.02,
                  ),
                  Container(
                    //height: MediaQuery.of(context).size.height * 0.05,
                    //padding: const EdgeInsets.only(right: 5),
                    height: MediaQuery.of(context).size.height * 0.07,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        SizedBox(
                            width: 80,
                            // height: 30,
                            child: TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  refreshList();
                                },
                                child: const Text("Cancel",
                                    style: TextStyle(
                                        color: Colors.red, fontSize: 16)))),
                        SizedBox(
                            width: 80,
                            // height: 30,
                            child: TextButton(
                                onPressed: () async {
                                  print('confirm-total------$totalDays');
                                  if (selectTime == false) {
                                    toast!.showToast(
                                      child: Widgets().getWarningToast(
                                          'Please select start date'),
                                      gravity: ToastGravity.BOTTOM,
                                      toastDuration: Duration(seconds: 2),
                                    );
                                  }

                                  if (totalDays <= 0) {
                                    toast!.showToast(
                                      child: Widgets().getWarningToast(
                                          'Please select valid date'),
                                      gravity: ToastGravity.BOTTOM,
                                      toastDuration: Duration(seconds: 2),
                                    );
                                  } else {
                                    getAttendanceByFilter(
                                        filter,
                                        startTime.toString().split(' ')[0],
                                        endTime.toString().split(' ')[0]);
                                  }
                                },
                                child: const Text(
                                  "Confirm",
                                  style: TextStyle(
                                      color: Colors.green, fontSize: 16),
                                ))),
                      ],
                    ),
                  )
                ]),
              ),
            );
          },
        );
      },
    );
  }
}
