import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:talent/data/api/attendance_api.dart';
import 'package:talent/data/database/dao/attendance_dao.dart';
import 'package:talent/data/database/dao/employee_dao.dart';
import 'package:talent/data/database/dao/hours_dao.dart';
import 'package:talent/data/database/dao/leave_dao.dart';
import 'package:talent/data/database/dao/payslip_dao.dart';
import 'package:talent/presentation/screens/expense/expense_request_history_list_page.dart';
import 'package:talent/presentation/screens/leave/leave_dashboard.dart';
import 'package:talent/presentation/screens/payslip/pay_slip_list_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/api/employee_api.dart';
import '../../../data/api/expense_api.dart';
import '../../../data/api/expense_product_api.dart';
import '../../../data/api/expense_tax_api.dart';
import '../../../data/database/dao/expense/expense_dao.dart';
import '../../../data/database/dao/leave_remain.dart';
import '../../../data/models/attendance/attendance.dart';
import '../../../data/models/employee/employee.dart';
import '../../../data/models/expense/expense/expense.dart';
import '../../../data/models/leave/leave.dart';
import '../../../data/models/leave_remain/leave_remain.dart';
import '../../../utility/share/share_component.dart';
import '../../../utility/style/theme.dart';
import '../../../utility/utils/attendance_permission_checker.dart';
import '../../../utility/utils/date_util.dart';
import '../../../utility/utils/size_config.dart';
import '../../widgets/custom_event_dialog.dart';
import '../../widgets/widgets.dart';
import '../attendance/attendance_screen.dart';
import '../employee/employee_detail.dart';
import '../leave/leave_history_list_screen.dart';
import 'package:easy_localization/easy_localization.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isvisible = false;
  bool isVisiable1 = false;
  bool isVisiable2 = false;
  var employeeDao = EmployeeDao();
  var leaveDao = LeaveDao();
  Employee? employee;
  var hoursDao = HoursDao();
  var payslipDao = PayslipDao();
  var attendanceDao = AttendanceDao();
  var expenseDao = ExpenseDao();
  int overtimeCount = 0;
  int payslipCount = 0;
  int leaveCount = 0;
  int expenseCount = 0;
  int attendanceCount = 0;
  bool? _isCheckIn = true;
  Attendance? lastAttendance;
  SharedPreferences? _sharedPreferences;
  late Timer timer;
  var timeForNow = '';
  bool? clickedCheckIn;
  bool? clickedCheckOut;
  bool showGreetingContainer = false;
  FToast? toast;
  Position? currentLocation;
  double? lat, lon = 0;
  String address = "";
  var lastAttCheckDate = '';
  var checkInOutTime;
  var employeeApi = EmployeeAPI();
  var attendanceApi = AttendanceAPI();
  var pref;
  var uid;
  bool noMoreToShow = false;
  final _timeNotifier = ValueNotifier<String>('');
  final _notiCountNotifier = ValueNotifier<String>('');
  final _paySlipCountNotifier = ValueNotifier<String>('');
  var passwordController = TextEditingController();
  var confirmPwController = TextEditingController();
  bool confirmPassword = false;
  final String _debugLabelString = "";
  String? fcm_token = '';
  var password;
  bool createPassword = false;
  var leaveRemainDao = LeaveRemainDao();
  var leaveRemainCount = 0.0;
  var currentPwController = TextEditingController();
  int notificationCount = 0;
  int instructionCount = 0;
  int? travelAllowanceCount = 0;
  Uint8List? bytes;
  late Position userPosition;
  String dayName = '';
  bool _isOfficeSelected = true;
  bool _remoteSelected = false;

  @override
  initState() {
    super.initState();
    toast = FToast();
    toast!.init(context);
    EasyLoading.instance
      ..displayDuration = const Duration(milliseconds: 2000)
      ..indicatorType = EasyLoadingIndicatorType.fadingCircle
      //..loadingStyle = EasyLoadingStyle.light
      ..lineWidth = 0.5
      ..indicatorSize = 45.0
      ..radius = 5.0
      ..maskColor = Colors.grey.withOpacity(0.5)
      ..userInteractions = false
      ..backgroundColor = Colors.white
      ..loadingStyle = EasyLoadingStyle.light
      ..textColor = Colors.black
      ..indicatorColor = Colors.black
      ..dismissOnTap = false;
    bool isOfficeSelected = true;

    // scheduleAlarm('');
    loadData();
  }

  loadData() {
    _loadData();
    getCurrentTime();
  }

  _loadData() async {
    pref = await SharedPreferences.getInstance();

    dayName = DateFormat('EEEE').format(DateTime.now());

    //await attendanceApi.getAttendanceSetting(employee!.employee_id!);

    //await goalApi.getGoalList();
    // await goalApi.getGoalDetail('First Quarter');
    // await goalApi.getGoalUndoneList();
    // var expProductApi = ExpenseProductAPI();
    // var expenseTaxApi = ExpenseTaxAPI();
    // await expProductApi.getExpenseProductListOnline();

    // await expenseTaxApi.getExpenseTaxListOnline();

    // timeForNow = DateFormat('H:m a').format(DateTime.now());

    // _timeNotifier.value = timeForNow;
    _paySlipCountNotifier.value = payslipCount.toString();

    List<Leave> leaveList = await leaveDao.getLeaveList();
    leaveCount = leaveList.length;
    //setState(() {})
    List<LeaveRemain> leaveRemainList = [];
    leaveRemainList = await leaveRemainDao.getLeaveRemainList();
    List<Expense> expenseList = [];
    expenseList = await expenseDao.getExpenseList();
    expenseCount = expenseList.length;
    List<Attendance> attendanceList = [];
    attendanceList = await attendanceDao.getAttendanceList();
    attendanceCount = attendanceList.length;
    // var expenseApi = ExpenseAPI();
    // var expProductApi = ExpenseProductAPI();

    //To delete
    // await expenseApi.getExpenseListOnline();
    // await expProductApi.getExpenseProductListOnline();
    // var expenseTaxApi = ExpenseTaxAPI();
    // await expenseTaxApi.getExpenseTaxListOnline();
    // toast!.showToast(
    //   child: Widgets().getDownloadToast('Expense data downloaded'),
    //   gravity: ToastGravity.BOTTOM,
    //   toastDuration: Duration(seconds: 1),
    // );

    if (leaveRemainList.isNotEmpty) {
      for (var element in leaveRemainList) {
        leaveRemainCount = leaveRemainCount + element.remaining_days!;
      }
    }
    var payslipCountTemp = await pref.getInt('payslipCount');
    if (payslipCountTemp != null && payslipCountTemp > 0) {
      payslipCount = payslipCountTemp;
      _paySlipCountNotifier.value = payslipCount.toString();
    }
    if (payslipCountTemp == 0) {
      setState(() {});
    }

    password = await pref.getString('password');
    if (password == null || password == '') {
      createPassword = true;
      confirmPassword = true;
    }

    pref.setBool('loginned', true); //login success and reach home
    lastAttCheckDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    var tempAttendance =
        await attendanceDao.getTodayAttendance(lastAttCheckDate);

    if (tempAttendance == null) {
      pref.setBool('is_check_in', true);
    } else {
      lastAttendance = tempAttendance;
      if (lastAttendance!.check_out_time == '') {
        pref.setBool('is_check_in', false);
      } else {
        pref.setBool('is_check_in', true);
      }
    }

    _isCheckIn = pref.getBool('is_check_in');

    uid = await pref.getInt('uid');

    employee = await employeeDao.getSingleEmployeeById(uid!);
    // await instructionApi.getInstructionList(employee!.employee_id!);
    // instructionCount = await pref.getInt('instructionCount');

    // travelAllowanceList = await travelAllowanceDao.getTravelAllowanceList();
    // travelAllowanceCount = travelAllowanceList.length;
    await attendanceApi.getAttendanceSetting(employee!.employee_id!);
    print('employee-${employee!.toJson()}');
    if (employee!.avatar != '')
      bytes = base64.decode("${employee!.avatar}");
    else
      bytes = null;

    setState(() {});
  }

  getCurrentTime() async {
    pref = await SharedPreferences.getInstance();
    var now1 = DateTime.now();
    var thisDay1 = '';
    thisDay1 = now1.day.toString();
    var thisMonth = DateFormat('MM').format(DateTime.now());

    var count = pref.getInt('paySlipNotiCount');
    _notiCountNotifier.value = count.toString();

    if (thisMonth == "04" ||
        thisMonth == "06" ||
        thisMonth == "09" ||
        thisMonth == "11") {
      if (thisDay1 != '30') {
        pref.setBool('runPaySlipForThisMonth', false);
      }
    } else if (thisMonth == "02") {
      if (thisDay1 != '28' && thisDay1 != '29') {
        pref.setBool('runPaySlipForThisMonth', false);
      }
    } else {
      if (thisDay1 != '31') {
        pref.setBool('runPaySlipForThisMonth', false);
      }
    }

    timer = Timer.periodic(const Duration(milliseconds: 10), (Timer t) {
      if (mounted) {
        timeForNow = DateFormat('H:m a').format(DateTime.now());

        _timeNotifier.value = timeForNow;
        var now = DateTime.now();
        var thisDay = '';
        thisDay = now.day.toString();

        // if (thisDay == '26') {
        //   var count = pref.getInt('paySlipNotiCount');

        //   _notiCountNotifier.value = count.toString();
        // }

        if (thisMonth == "04" ||
            thisMonth == "06" ||
            thisMonth == "09" ||
            thisMonth == "11") {
          if (thisDay1 == '30') {
            var count = pref.getInt('paySlipNotiCount');

            _notiCountNotifier.value = count.toString();
          }
        } else if (thisMonth == "02") {
          if (thisDay1 == '28' || thisDay1 == '29') {
            var count = pref.getInt('paySlipNotiCount');

            _notiCountNotifier.value = count.toString();
          }
        } else {
          if (thisDay1 == '31') {
            var count = pref.getInt('paySlipNotiCount');

            _notiCountNotifier.value = count.toString();
          }
        }
      }
    });

    timer = Timer.periodic(const Duration(seconds: 15), (Timer t) {});
  }

  _sendAttendance() async {
    bool checkInternet = await InternetConnectionChecker.instance.hasConnection;

    if (checkInternet == false) {
      EasyLoading.dismiss();
      if (!mounted) return;
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
        EasyLoading.dismiss();

        toast!.showToast(
          child: Widgets().getWarningToast('Today, already check in'),
          gravity: ToastGravity.BOTTOM,
          toastDuration: const Duration(seconds: 2),
        );
        return null;
      }
      att = await _insertCheckIn();
    } else {
      att = await _insertCheckout();
    }

    await _syncToServer(att);

    setState(() {});
  }

  checkIsCheckIn() async {
    print('checkIsCheckIn-------------');
    lastAttCheckDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    var tempAttendance =
        await attendanceDao.getTodayAttendance(lastAttCheckDate);

    print('tempAttendance------$tempAttendance');

    // if (tempAttendance == null) {
    //   pref.setBool('is_check_in', true);
    // } else {
    //   lastAttendance = tempAttendance;
    //   if (lastAttendance!.check_out_time == '') {
    //     pref.setBool('is_check_in', false);
    //   } else
    //     pref.setBool('is_check_in', true);
    // }

    _isCheckIn = pref.getBool('is_check_in');

    setState(() {});
  }

  Future<Attendance?> _insertCheckIn() async {
    String todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    var shareComponent = ShareComponentClass();
    var deviceStatus = await shareComponent.readDeviceId();
    DateTime currentDateTime = DateTime.now();
    String checkInDatetime =
        DateUtil().getSqlDateTime(currentDateTime, 'yyyy-MM-dd HH:mm:ss');

    Position userPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    Attendance att = Attendance(
        0,
        (employee!.employee_name).toString(),
        employee!.employee_id,
        uid,
        todayDate,
        checkInDatetime,
        '',
        checkInOutTime,
        '',
        "0",
        userPosition.latitude,
        userPosition.longitude,
        // userPosition.latitude,z
        // userPosition.longitude,
        0,
        0,
        address,
        '',
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

    Position userPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    if (tempAttendance != null) {
      attendance = tempAttendance;
      DateTime currentDateTime = DateTime.now();
      String checkOutDatetime =
          DateUtil().getSqlDateTime(currentDateTime, 'yyyy-MM-dd HH:mm:ss');

      Attendance att = Attendance(
          attendance!.attendanceId,
          (employee!.employee_name).toString(),
          employee!.employee_id,
          attendance.user_id,
          attendance.date,
          attendance.check_in_datetime,
          checkOutDatetime,
          attendance.check_in_time,
          checkInOutTime,
          attendance.working_hr,
          attendance.in_latitude,
          attendance.in_longitude,
          userPosition.latitude,
          userPosition.longitude,
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
        toastDuration: const Duration(seconds: 2),
      );
      return;
    }

    var checkInResult;

    if (_isCheckIn!) {
      checkInResult = await attendanceApi.createAttendance(attendance, '');
    } else {
      checkInResult = await attendanceApi.checkOutAttendance(attendance, '');
    }

    print('checkInResult------------$checkInResult');

    if (checkInResult['result'] == 'fail') {
      var message;

      EasyLoading.dismiss();

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
            toastDuration: const Duration(seconds: 3),
          );
          await pref.setString('jwt_token', "null");
          EasyLoading.dismiss();

          await Future.delayed(const Duration(seconds: 4));

          return;
        }
      }

      EasyLoading.dismiss();

      toast!.showToast(
        child: Widgets().getErrorToast('$message'),
        gravity: ToastGravity.BOTTOM,
        toastDuration: const Duration(seconds: 6),
      );
      return;
    }

    toast = FToast();
    toast!.init(context); //Custom edit

    var status = checkInResult['attendanceMessage'];

    EasyLoading.dismiss();

    if (status == 'exist') {
      toast!.showToast(
        child: Widgets()
            .getErrorToast('Attendance date is already exist in the system.'),
        gravity: ToastGravity.BOTTOM,
        toastDuration: const Duration(seconds: 3),
      );
    } else if (status == 'in') {
      toast!.showToast(
        child: Widgets().getSuccessToast('Check In Successful'),
        gravity: ToastGravity.BOTTOM,
        toastDuration: const Duration(seconds: 3),
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
        toastDuration: const Duration(seconds: 3),
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

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff6f7f9),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildTopSection(),
            const SizedBox(height: 16),
            // RemoteModeCard(), // Added RemoteModeCard here
            Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.symmetric(
                  horizontal: 16), // Added margin to match image
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Choose Your Working Mode",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                          onTap: () {
                            print('onTap--------');
                            setState(() {
                              _isOfficeSelected = true;
                              _remoteSelected = false;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: _isOfficeSelected
                                  ? Colors.blue
                                  : Colors.grey[200],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Office',
                              style: TextStyle(
                                color: _isOfficeSelected
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                          )),
                      const SizedBox(width: 8),
                      GestureDetector(
                          onTap: () {
                            print('onTap2-----$_isOfficeSelected');
                            setState(() {
                              _isOfficeSelected = false;
                              _remoteSelected = true;
                            });
                            // print('onTap2-----$_isOfficeSelected $_remoteSelected');
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: _remoteSelected
                                  ? Colors.blue
                                  : Colors.grey[200],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Home Or Onsite',
                              style: TextStyle(
                                color: _remoteSelected
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                          )),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Monday June 10 - 2022, 07:56 AM",
                    style: TextStyle(fontSize: 14),
                  ),
                  // Text(
                  //   "07:40:56 AM",
                  //   style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  // ),
                  ValueListenableBuilder(
                    valueListenable: _timeNotifier,
                    builder: (_, value, __) => RichText(
                        text: TextSpan(
                      text: '$value',
                      style: const TextStyle(
                          fontSize: 15,
                          color: ColorObj.secondColor,
                          fontWeight: FontWeight.bold),
                    )),
                  ),
                  const SizedBox(height: 24),
                  GestureDetector(
                    onTap: () async {
                      print('onTap---------');
                      if (_isOfficeSelected) {
                        try {
                          // throw Exception('sm;;mmvms');
                          employee =
                              await employeeDao.getSingleEmployeeById(uid!);

                          EasyLoading.show();

                          await attendanceApi
                              .getAttendanceSetting(employee!.employee_id!);

                          AttendanceChecker checker = AttendanceChecker();

                          bool hasPermission =
                              await checker.checkAttendancePermission();
                          print('hasPermission--------$hasPermission');

                          if (hasPermission) {
                            print("Attendance granted!");
                            EasyLoading.dismiss();
                            if (!mounted) return;
                            showConfirmationDialog(context);
                          } else {
                            print("Attendance denied!");

                            EasyLoading.dismiss();
                            FToast? toast;
                            toast = FToast();
                            toast.init(context);
                            toast.showToast(
                              child: Widgets().getErrorToast(
                                  'You are not in allowed area!'),
                              gravity: ToastGravity.BOTTOM,
                              toastDuration: const Duration(seconds: 1),
                            );

                            return;
                          }
                        } catch (e, stackTrace) {
                          // EasyLoading.dismiss();
                          // EasyLoading.show(
                          //     status: 'Error------${stackTrace.toString()}');
                        }
                      } else {
                        showConfirmationDialog(context);
                      }
                    },
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isCheckIn == true ? Colors.green : Colors.red,
                      ),
                      child: const Icon(
                        Icons.fingerprint,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Register Your Presence And Start",
                    style: TextStyle(fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                  const Text(
                    "Your Work",
                    style: TextStyle(fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            //SizedBox(height: 10),
            _buildAttendanceSection(),
            // SizedBox(height: 16),
            // _buildSummarySection(),
          ],
        ),
      ),
      // Bottom Navigation Bar (if needed)
    );
  }

  void confirmDialog(
    BuildContext context,
  ) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        print(
            'MediaQuery.of(context).size.shortestSide----${MediaQuery.of(context).size.shortestSide}');
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return Dialog(
              //  backgroundColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Container(
                  //   margin: EdgeInsets.only(left: 20, right: 20),
                  // width: double.infinity,
                  // width: MediaQuery.of(context).size.shortestSide > 370
                  //     ? MediaQuery.of(context).size.width - 170
                  //     : MediaQuery.of(context).size.width - 190,
                  child: Column(
                    children: <Widget>[
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(8),
                            topRight: Radius.circular(8)),
                        child: Material(
                          color: ColorObj.mainColor,
                          child: SizedBox(
                            height: 50,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Container(
                                  margin: const EdgeInsets.only(left: 10),
                                  child: const Text("Confirmation",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 16)),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(bottom: 5),
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.close,
                                      size: 23,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                            children: [
                              const SizedBox(
                                width: 10,
                              ),
                              Container(
                                // margin: EdgeInsets.only(top: 3),
                                child: const Icon(
                                  Icons.warning,
                                  size: 31,
                                  color: ColorObj.mainColor,
                                ),
                              ),
                              Flexible(
                                child: Container(
                                    margin: const EdgeInsets.only(
                                        left: 10, top: 10),
                                    child: Text(
                                      'You are going to exit the application!',
                                      style: TextStyle(
                                          color: Colors.grey[800],
                                          fontSize: 15),
                                    )),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(
                                    color: ColorObj.mainColor,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 28,
                              ),
                              ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: ColorObj.mainColor,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 36, vertical: 10),
                                      textStyle: const TextStyle(
                                        fontSize: 13,
                                      )),
                                  onPressed: () {
                                    SystemNavigator.pop();
                                  },
                                  child: const Text(
                                    'OK',
                                    style: TextStyle(fontSize: 13),
                                  )),
                              const SizedBox(
                                width: 15,
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ));
        });
      },
    );
  }

  void showConfirmationDialog(BuildContext context) {
    print('showConfirmationDialog----------$_isCheckIn');

    var textValue = '';
    if (_isCheckIn == true) {
      textValue = 'Check In';
    } else {
      textValue = 'Check Out';
    }

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Stack(
            children: [
              InkWell(
                onTap: () {
                  print('cancel');
                  Navigator.pop(context);
                },
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                  child: Container(
                    color: const Color.fromARGB(255, 110, 110, 110)
                        .withOpacity(0.1), // Optional color overlay
                  ),
                ),
              ),
              Center(
                  child: Container(
                width: 100.0, // width of the circle
                height: 100.0, // height of the circle
                decoration: const BoxDecoration(
                  color: Colors.white, // background color
                  shape: BoxShape.circle, // make the container circular
                ),
                child: InkWell(
                  onTap: () async {
                    EasyLoading.show();
                    await _sendAttendance();
                    await checkIsCheckIn();
                    EasyLoading.dismiss();
                    if (!mounted) return;
                    Navigator.of(context).pop(); // Proceed with confirmation
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        FontAwesomeIcons.locationPin,
                        color: _isCheckIn == true ? Colors.green : Colors.red,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        textValue,
                        style: TextStyle(
                            fontSize: 16,
                            color:
                                _isCheckIn == true ? Colors.green : Colors.red),
                      )
                    ],
                  ),
                ),
              )),
            ],
          );
        });
  }

  Widget _buildTopSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: ColorObj.mainColor,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: SafeArea(
        // Avoid notch issues
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => EmployeeDetailScreen()));
              },
              child: Row(
                children: [
                  bytes != null
                      ? CircleAvatar(
                          radius: 25,
                          backgroundImage:
                              //  NetworkImage(
                              //     "https://via.placeholder.com/150"), // Replace with your image
                              MemoryImage(bytes!),
                        )
                      : const CircleAvatar(
                          radius: 25,
                          backgroundImage:
                              AssetImage('assets/imgs/default_avator.png'),
                        ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          employee != null
                              ? "Good Morning, ${employee!.employee_name}"
                              : "Good Morning, ",
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        const Text(
                          "Have a good day with full of productivity and good vibes.",
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.notifications, color: Colors.white),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Text(
          //   "Feature",
          //   style: TextStyle(fontWeight: FontWeight.bold),
          // ),
          //  SizedBox(height: 5),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics:
                const NeverScrollableScrollPhysics(), // Disable GridView scrolling
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => LeaveHistoryListScreen()));
                },
                child: _buildAttendanceItem('assets/imgs/1.png', 'time_off',
                    leaveCount.toString(), Colors.lightBlue[100]!, 42, 42),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ExpenseListPage()));
                },
                child: _buildAttendanceItem('assets/imgs/6.png', "expense",
                    expenseCount.toString(), Colors.yellow[100]!, 35, 35),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => LeaveDashBoardScreen()));
                },
                child: _buildAttendanceItem(
                    'assets/imgs/3.png',
                    "leave_left",
                    leaveRemainCount.toStringAsFixed(1),
                    Colors.green[100]!,
                    70,
                    45),
              ),
              GestureDetector(
                  onTap: () async {
                    passwordController.clear();
                    confirmPwController.clear();
                    confirmPwController.clear();

                    password = pref.getString('password');
                    print('pw---------------$password');
                    if (password == null || password == '') {
                      createPassword = true;
                      confirmPassword = true;
                    } else {
                      createPassword = false;
                    }

                    bool isChecked = false;

                    showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          return StatefulBuilder(builder: (context, setState) {
                            return Dialog(
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                        color: Color.fromARGB(255, 221, 240,
                                            255), // Change color of the shadow
                                        blurRadius: 1.0,
                                        spreadRadius: 1.0,
                                        offset: Offset(2.0, 2.0))
                                  ],
                                ),
                                padding: const EdgeInsets.all(25),
                                width: MediaQuery.of(context).size.width * 0.9,
                                height: createPassword
                                    ? MediaQuery.of(context).size.height * 0.4
                                    : MediaQuery.of(context).size.height * 0.31,
                                child: Column(
                                  children: <Widget>[
                                    // SizedBox(height: 10.0),
                                    SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.03,
                                      child: Center(
                                          child: Text(
                                        createPassword
                                            ? "Create Password"
                                            : "Enter Password To Access",
                                        style: const TextStyle(
                                          fontSize: 18,
                                          // fontWeight: FontWeight.bold,
                                        ),
                                      )),
                                    ),
                                    // SizedBox(height: 48.0),
                                    Container(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.1,
                                      alignment: Alignment.bottomCenter,
                                      child: TextFormField(
                                        controller: passwordController,
                                        obscureText:
                                            isvisible == false ? true : false,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        autofocus: false,
                                        cursorColor: Colors.grey[600],
                                        decoration: InputDecoration(
                                          suffixIcon: IconButton(
                                              onPressed: () {
                                                setState(() {
                                                  isvisible = !isvisible;
                                                });
                                              },
                                              icon: isvisible == false
                                                  ? Icon(
                                                      Icons.visibility_off,
                                                      color: Colors.grey[400],
                                                    )
                                                  : Icon(
                                                      Icons.visibility,
                                                      color: Colors.grey[800],
                                                    )),
                                          filled: true,
                                          fillColor: const Color.fromARGB(
                                              255, 252, 251, 251),
                                          enabledBorder:
                                              const OutlineInputBorder(
                                            borderSide: BorderSide(
                                                width: 1,
                                                color:
                                                    Colors.grey), //<-- SEE HERE
                                          ),
                                          focusedBorder:
                                              const OutlineInputBorder(
                                            borderSide: BorderSide(
                                                width: 1,
                                                color:
                                                    Colors.grey), //<-- SEE HERE
                                          ),
                                          hintText: 'Password',
                                          contentPadding:
                                              const EdgeInsets.fromLTRB(
                                                  20.0, 12.0, 20.0, 12.0),
                                        ),
                                      ),
                                    ),
                                    // createPassword
                                    //     ? SizedBox(height: 20.0)
                                    //     : SizedBox(height: 5.0),
                                    createPassword
                                        ? Container(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.1,
                                            alignment: Alignment.bottomCenter,
                                            child: TextFormField(
                                              controller: confirmPwController,
                                              keyboardType:
                                                  TextInputType.emailAddress,
                                              autofocus: false,
                                              obscureText: isVisiable1 == false
                                                  ? true
                                                  : false,
                                              cursorColor: Colors.grey[600],
                                              decoration: InputDecoration(
                                                suffixIcon: IconButton(
                                                    onPressed: () {
                                                      setState(() {
                                                        isVisiable1 =
                                                            !isVisiable1;
                                                      });
                                                    },
                                                    icon: isVisiable1 == false
                                                        ? Icon(
                                                            Icons
                                                                .visibility_off,
                                                            color: Colors
                                                                .grey[400],
                                                          )
                                                        : Icon(
                                                            Icons.visibility,
                                                            color: Colors
                                                                .grey[800],
                                                          )),
                                                filled: true,
                                                fillColor: const Color.fromARGB(
                                                    255, 252, 251, 251),
                                                enabledBorder:
                                                    const OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      width: 1,
                                                      color: Colors
                                                          .grey), //<-- SEE HERE
                                                ),
                                                focusedBorder:
                                                    const OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      width: 1,
                                                      color: Colors
                                                          .grey), //<-- SEE HERE
                                                ),
                                                hintText: 'Confirm Password',
                                                contentPadding:
                                                    const EdgeInsets.fromLTRB(
                                                        20.0, 12.0, 20.0, 12.0),
                                              ),
                                            ),
                                          )
                                        : const SizedBox(),
                                    //SizedBox(height: 24.0),
                                    const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: <Widget>[],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 1),
                                      child: Container(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.09,
                                        alignment: Alignment.bottomCenter,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            !createPassword
                                                ? InkWell(
                                                    onTap: () {
                                                      Navigator.pop(context);
                                                      showDialog(
                                                          context: context,
                                                          builder: (context) {
                                                            return StatefulBuilder(
                                                                builder: (context,
                                                                    setState) {
                                                              return Dialog(
                                                                child:
                                                                    Container(
                                                                  decoration:
                                                                      const BoxDecoration(
                                                                    color: Colors
                                                                        .white,
                                                                    boxShadow: [
                                                                      BoxShadow(
                                                                          color: Color.fromARGB(
                                                                              255,
                                                                              221,
                                                                              240,
                                                                              255), // Change color of the shadow
                                                                          blurRadius:
                                                                              1.0,
                                                                          spreadRadius:
                                                                              1.0,
                                                                          offset: Offset(
                                                                              2.0,
                                                                              2.0))
                                                                    ],
                                                                  ),
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          25),
                                                                  width: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width *
                                                                      0.8,
                                                                  height: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .height *
                                                                      0.49,
                                                                  child: Column(
                                                                    children: <Widget>[
                                                                      // SizedBox(
                                                                      //     height:
                                                                      //         10.0),
                                                                      SizedBox(
                                                                        height: MediaQuery.of(context).size.height *
                                                                            0.04,
                                                                        child: const Center(
                                                                            child: Text(
                                                                          "Change Password",
                                                                          style:
                                                                              TextStyle(
                                                                            fontSize:
                                                                                18,
                                                                            // fontWeight:
                                                                            //     FontWeight
                                                                            //         .bold,
                                                                          ),
                                                                        )),
                                                                      ),
                                                                      // SizedBox(
                                                                      //     height:
                                                                      //         48.0),
                                                                      Container(
                                                                        height: MediaQuery.of(context).size.height *
                                                                            0.1,
                                                                        alignment:
                                                                            Alignment.bottomCenter,
                                                                        child:
                                                                            TextFormField(
                                                                          controller:
                                                                              currentPwController,
                                                                          keyboardType:
                                                                              TextInputType.emailAddress,
                                                                          autofocus:
                                                                              false,
                                                                          obscureText: isVisiable2 == false
                                                                              ? true
                                                                              : false,
                                                                          cursorColor:
                                                                              Colors.grey[600],
                                                                          decoration:
                                                                              InputDecoration(
                                                                            suffixIcon: IconButton(
                                                                                onPressed: () {
                                                                                  setState(() {
                                                                                    isVisiable2 = !isVisiable2;
                                                                                  });
                                                                                },
                                                                                icon: isVisiable2 == false
                                                                                    ? Icon(
                                                                                        Icons.visibility_off,
                                                                                        color: Colors.grey[400],
                                                                                      )
                                                                                    : Icon(
                                                                                        Icons.visibility,
                                                                                        color: Colors.grey[800],
                                                                                      )),
                                                                            filled:
                                                                                true,
                                                                            fillColor: const Color.fromARGB(
                                                                                255,
                                                                                252,
                                                                                251,
                                                                                251),
                                                                            enabledBorder:
                                                                                const OutlineInputBorder(
                                                                              borderSide: BorderSide(width: 1, color: Colors.grey), //<-- SEE HERE
                                                                            ),
                                                                            focusedBorder:
                                                                                const OutlineInputBorder(
                                                                              borderSide: BorderSide(width: 1, color: Colors.grey), //<-- SEE HERE
                                                                            ),
                                                                            hintText:
                                                                                'Current Password',
                                                                            contentPadding: const EdgeInsets.fromLTRB(
                                                                                20.0,
                                                                                12.0,
                                                                                20.0,
                                                                                12.0),
                                                                          ),
                                                                        ),
                                                                      ),

                                                                      Container(
                                                                        height: MediaQuery.of(context).size.height *
                                                                            0.1,
                                                                        alignment:
                                                                            Alignment.bottomCenter,
                                                                        child:
                                                                            TextFormField(
                                                                          controller:
                                                                              passwordController,
                                                                          keyboardType:
                                                                              TextInputType.emailAddress,
                                                                          autofocus:
                                                                              false,
                                                                          obscureText: isVisiable1 == false
                                                                              ? true
                                                                              : false,
                                                                          cursorColor:
                                                                              Colors.grey[600],
                                                                          decoration:
                                                                              InputDecoration(
                                                                            suffixIcon: IconButton(
                                                                                onPressed: () {
                                                                                  setState(() {
                                                                                    isVisiable1 = !isVisiable1;
                                                                                  });
                                                                                },
                                                                                icon: isVisiable1 == false
                                                                                    ? Icon(
                                                                                        Icons.visibility_off,
                                                                                        color: Colors.grey[400],
                                                                                      )
                                                                                    : Icon(
                                                                                        Icons.visibility,
                                                                                        color: Colors.grey[800],
                                                                                      )),
                                                                            filled:
                                                                                true,
                                                                            fillColor: const Color.fromARGB(
                                                                                255,
                                                                                252,
                                                                                251,
                                                                                251),
                                                                            enabledBorder:
                                                                                const OutlineInputBorder(
                                                                              borderSide: BorderSide(width: 1, color: Colors.grey), //<-- SEE HERE
                                                                            ),
                                                                            focusedBorder:
                                                                                const OutlineInputBorder(
                                                                              borderSide: BorderSide(width: 1, color: Colors.grey), //<-- SEE HERE
                                                                            ),
                                                                            hintText:
                                                                                'New Password',
                                                                            contentPadding: const EdgeInsets.fromLTRB(
                                                                                20.0,
                                                                                12.0,
                                                                                20.0,
                                                                                12.0),
                                                                          ),
                                                                        ),
                                                                      ),

                                                                      Container(
                                                                        height: MediaQuery.of(context).size.height *
                                                                            0.1,
                                                                        alignment:
                                                                            Alignment.bottomCenter,
                                                                        child:
                                                                            TextFormField(
                                                                          controller:
                                                                              confirmPwController,
                                                                          keyboardType:
                                                                              TextInputType.emailAddress,
                                                                          autofocus:
                                                                              false,
                                                                          obscureText: isvisible == false
                                                                              ? true
                                                                              : false,
                                                                          cursorColor:
                                                                              Colors.grey[600],
                                                                          decoration:
                                                                              InputDecoration(
                                                                            suffixIcon: IconButton(
                                                                                onPressed: () {
                                                                                  setState(() {
                                                                                    isvisible = !isvisible;
                                                                                  });
                                                                                },
                                                                                icon: isvisible == false
                                                                                    ? Icon(
                                                                                        Icons.visibility_off,
                                                                                        color: Colors.grey[400],
                                                                                      )
                                                                                    : Icon(
                                                                                        Icons.visibility,
                                                                                        color: Colors.grey[800],
                                                                                      )),
                                                                            filled:
                                                                                true,
                                                                            fillColor: const Color.fromARGB(
                                                                                255,
                                                                                252,
                                                                                251,
                                                                                251),
                                                                            enabledBorder:
                                                                                const OutlineInputBorder(
                                                                              borderSide: BorderSide(width: 1, color: Colors.grey), //<-- SEE HERE
                                                                            ),
                                                                            focusedBorder:
                                                                                const OutlineInputBorder(
                                                                              borderSide: BorderSide(width: 1, color: Colors.grey), //<-- SEE HERE
                                                                            ),
                                                                            hintText:
                                                                                'Confirm Password',
                                                                            contentPadding: const EdgeInsets.fromLTRB(
                                                                                20.0,
                                                                                12.0,
                                                                                20.0,
                                                                                12.0),
                                                                          ),
                                                                        ),
                                                                      ),

                                                                      Container(
                                                                        height: MediaQuery.of(context).size.height *
                                                                            0.08,
                                                                        alignment:
                                                                            Alignment.bottomCenter,
                                                                        child:
                                                                            Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.end,
                                                                          children: [
                                                                            const SizedBox(
                                                                              width: 10,
                                                                            ),
                                                                            TextButton(
                                                                                onPressed: () {
                                                                                  Navigator.pop(context);
                                                                                },
                                                                                child: const Text(
                                                                                  "Cancel",
                                                                                  style: TextStyle(fontFamily: 'Regular', fontSize: 16, color: Colors.red),
                                                                                )),
                                                                            const SizedBox(
                                                                              width: 10,
                                                                            ),
                                                                            TextButton(
                                                                              onPressed: () async {
                                                                                toast = FToast();
                                                                                toast!.init(context);
                                                                                pref = await SharedPreferences.getInstance();
                                                                                String cPw = await pref!.getString("password");

                                                                                print('cPw---------$cPw');
                                                                                print('cur2------${currentPwController.text}');
                                                                                if (currentPwController.text.toString() == cPw) {
                                                                                  print('same------');
                                                                                  print('${passwordController.text}  : ${confirmPwController.text}');
                                                                                  if (passwordController.text.toString() != '' && confirmPwController.text.toString() != '') {
                                                                                    if (passwordController.text.toString() == confirmPwController.text.toString()) {
                                                                                      print('same--');
                                                                                      await pref!.setString("password", passwordController.text.toString());
                                                                                      print('---${pref!.getString("password")}');
                                                                                      Navigator.of(context).pop();

                                                                                      toast!.showToast(child: Widgets().getSuccessToast('Password successfully changed.'));
                                                                                    } else {
                                                                                      print('diff-');
                                                                                      Navigator.of(context).pop();

                                                                                      toast!.showToast(child: Widgets().getWarningToast('Password does not match'));
                                                                                    }
                                                                                  } else {
                                                                                    //blank new andconfirm pw blank
                                                                                    Navigator.of(context).pop();

                                                                                    toast!.showToast(
                                                                                      child: Widgets().getWarningToast('New or confirm password is blank.Please try again.'),
                                                                                      toastDuration: const Duration(seconds: 3),
                                                                                    );
                                                                                  }
                                                                                } else {
                                                                                  print('diff---------');
                                                                                  Navigator.of(context).pop();
                                                                                  toast!.showToast(child: Widgets().getWarningToast('Current Password not correct'));
                                                                                }

                                                                                passwordController.clear();
                                                                                confirmPwController.clear();
                                                                                currentPwController.clear();
                                                                              },
                                                                              child: const Text(
                                                                                "OK",
                                                                                style: TextStyle(fontFamily: 'Regular', fontSize: 16, color: ColorObj.mainColor),
                                                                              ),
                                                                            ),
                                                                            // const SizedBox(
                                                                            //   width:
                                                                            //       10,
                                                                            // ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              );
                                                            });
                                                          });
                                                    },
                                                    child: Text(
                                                      'Change',
                                                      style: TextStyle(
                                                          fontFamily: 'Regular',
                                                          fontSize: 16,
                                                          color: ColorObj
                                                              .greyColor7),
                                                    ))
                                                : const Text(''),
                                            Container(
                                              // color: Colors.grey,
                                              // height: MediaQuery.of(context)
                                              //         .size
                                              //         .height *
                                              //     0.09,
                                              // alignment: Alignment.bottomCenter,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  // const SizedBox(
                                                  //   width: 10,
                                                  // ),
                                                  TextButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                      child: const Text(
                                                        "Cancel",
                                                        style: TextStyle(
                                                            fontFamily:
                                                                'Regular',
                                                            fontSize: 16,
                                                            color: Colors.red),
                                                      )),
                                                  const SizedBox(
                                                    width: 10,
                                                  ),
                                                  TextButton(
                                                    onPressed: () async {
                                                      toast = FToast();
                                                      toast!.init(context);
                                                      pref =
                                                          await SharedPreferences
                                                              .getInstance();

                                                      print(
                                                          'createPassword--------$createPassword');

                                                      if (createPassword) {
                                                        print('if---------');
                                                        if (passwordController
                                                                .text
                                                                .toString() !=
                                                            confirmPwController
                                                                .text
                                                                .toString()) {
                                                          print('1-if');
                                                          toast!.showToast(
                                                            child: Widgets()
                                                                .getWarningToast(
                                                                    'Password and confirm password do not match'),
                                                            gravity:
                                                                ToastGravity
                                                                    .BOTTOM,
                                                            toastDuration:
                                                                const Duration(
                                                                    seconds: 3),
                                                          );
                                                          Navigator.pop(
                                                              context);
                                                        } else {
                                                          print('1-else');
                                                          await pref.setString(
                                                              'password',
                                                              passwordController
                                                                  .text
                                                                  .toString());
                                                          Navigator.pop(
                                                              context);
                                                        }
                                                      } else {
                                                        print('else---------');
                                                        var pw = await pref
                                                            .getString(
                                                                'password');
                                                        if ((passwordController
                                                                .text
                                                                .toString() ==
                                                            pw)) {
                                                          print('2-if');
                                                          Navigator.pushReplacement(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          const PaySlipListScreen()));
                                                        } else {
                                                          print('2-else---$pw');
                                                          toast!.showToast(
                                                            child: Widgets()
                                                                .getWarningToast(
                                                                    'Invalid Password'),
                                                            gravity:
                                                                ToastGravity
                                                                    .BOTTOM,
                                                            toastDuration:
                                                                const Duration(
                                                                    seconds: 3),
                                                          );
                                                          Navigator.pop(
                                                              context);
                                                        }
                                                      }
                                                    },
                                                    child: Text(
                                                      createPassword
                                                          ? "Create"
                                                          : "Submit",
                                                      style: const TextStyle(
                                                          fontFamily: 'Regular',
                                                          fontSize: 16,
                                                          color: ColorObj
                                                              .mainColor),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            );
                          });
                        });
                  },
                  child: Card(
                    color: Colors.purple[100]!,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/imgs/slip2.png',
                            width: 40,
                            height: 40,
                          ),
                          Text('payslip'.tr(),
                              style: const TextStyle(fontSize: 12)),
                          ValueListenableBuilder(
                            valueListenable: _paySlipCountNotifier,
                            builder: (_, value, __) => RichText(
                                text: TextSpan(
                              text: '$value',
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14),
                            )),
                          ),
                          //Text(value, style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  )),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AttendanceScreen()));
                },
                child: _buildAttendanceItem('assets/imgs/5.png', "attendance",
                    attendanceCount.toString(), Colors.red[100]!, 42, 42),
              ),
              GestureDetector(
                onTap: () {},
                child: _buildAttendanceItem('assets/imgs/2.png', 'overtime',
                    overtimeCount.toString(), Colors.orange[100]!, 38, 38),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceItem(String image, String title, String value,
      Color color, double width, double height) {
    return Card(
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              image,
              width: width,
              height: height,
            ),
            Text(title.tr(), style: const TextStyle(fontSize: 12)),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildSummarySection() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Today's Summary",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          // Add your summary content here
        ],
      ),
    );
  }
}
