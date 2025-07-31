import 'dart:async';
import 'dart:developer';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:talent/data/api/attendance_api.dart';
import 'package:talent/data/api/employee_api.dart';
import 'package:talent/data/api/expense_api.dart';
import 'package:talent/data/api/pay_slip_api.dart';
import 'package:talent/data/database/dao/attachment_dao.dart';
import 'package:talent/data/database/dao/attendance_dao.dart';
import 'package:talent/data/database/dao/employee_dao.dart';
import 'package:talent/data/database/dao/holiday_dao.dart';
import 'package:talent/data/database/dao/leave_dao.dart';
import 'package:talent/data/database/dao/leave_reason_dao.dart';
import 'package:talent/data/database/dao/leave_remain.dart';
import 'package:talent/data/database/dao/leave_type_dao.dart';
// Removed as the file does not exist
import 'package:talent/data/database/dao/payslip_dao.dart';
import 'package:talent/data/database/dao/payslip_line_dao.dart';
import 'package:talent/presentation/screens/dashboard/dashboard_main.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:talent/utility/style/theme.dart' as style;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/api/expense_product_api.dart';
import '../../../data/api/expense_tax_api.dart';
import '../../../data/api/leave_api.dart';
import '../../../data/api/login_api.dart';
import '../../../data/helper/constant.dart';
import '../../../data/models/employee/employee.dart';
import '../../../utility/share/app_strings.dart';
import '../../../utility/share/share_component.dart';
import '../../../utility/utils/size_config.dart';
import '../../widgets/custom_event_dialog.dart';
import '../../widgets/widgets.dart';
import 'login.dart';
import 'reject_screen.dart';

class WaitingScreen extends StatefulWidget {
  const WaitingScreen({super.key});

  @override
  WaitingScreenState createState() => WaitingScreenState();
}

class WaitingScreenState extends State<WaitingScreen> {
  var employeeDao = EmployeeDao();
  var holidayDao = HolidayDao();
  var leaveTypeDao = LeaveTypeDao();
  var leaveRemainDao = LeaveRemainDao();
  var attendanceDao = AttendanceDao();
  var leaveDao = LeaveDao();
  var payslipDao = PayslipDao();
  var payslipLineDao = PayslipLineDao();
  var leaveReasonDao = LeaveReasonDao();
  var attachmentDao = AttachmentDao();
  FToast? toast;
  Timer? timer;
  Employee? employee;
  var deviceState = '';
  var loginApi = loginAPI();
  late DeviceInfoPlugin deviceInfoPlugin;
  late AndroidDeviceInfo androidDeviceInfo;

  var employeeApi = EmployeeAPI();
  var attendanceApi = AttendanceAPI();
  var leaveApi = LeaveAPI();
  var expenseApi = ExpenseAPI();
  var expProductApi = ExpenseProductAPI();
  var expenseTaxApi = ExpenseTaxAPI();
  late BuildContext _scaffoldCtx;

  @override
  void initState() {
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
      ..maskColor = Colors.grey.withValues(alpha: 0.5)
      ..userInteractions = false
      ..backgroundColor = Colors.white
      ..loadingStyle = EasyLoadingStyle.light
      ..textColor = Colors.black
      ..indicatorColor = Colors.black
      ..dismissOnTap = false;
    downloadData();
  }

  downloadData() async {
    var pref = await SharedPreferences.getInstance();
    var userId = pref.getInt('uid');

    await employeeApi.getEmployeeList();

    checkDeviceActivation();
    setState(() {});

    Employee employee = await employeeDao.getSingleEmployeeById(userId!);
    toast!.showToast(
      child: Widgets().getDownloadToast(AppStrings.employeeDataDownloaded.tr()),
      gravity: ToastGravity.BOTTOM,
      toastDuration: const Duration(seconds: 1),
    );

    await attendanceApi.getAttendanceList(employee.employee_id!);
    toast!.showToast(
      child: Widgets().getDownloadToast(AppStrings.attendanceDataDownloaded.tr()),
      gravity: ToastGravity.BOTTOM,
      toastDuration: const Duration(seconds: 1),
    );

    // await overTimeApi.getOverTimeTypeList();
    // await overTimeApi.getOverTimeList(employee.employee_id!, 'all');
    // toast!.showToast(
    //   child: Widgets().getDownloadToast('Overtime data downloaded'),
    //   gravity: ToastGravity.BOTTOM,
    //   toastDuration: Duration(seconds: 1),
    // );

    // await projectApi.getProjectList();
    // await projectApi.getProjectTaskList();
    // toast!.showToast(
    //   child: Widgets().getDownloadToast('Task data downloaded'),
    //   gravity: ToastGravity.BOTTOM,
    //   toastDuration: Duration(seconds: 1),
    // );

    await expenseApi.getExpenseListOnline();
    await expProductApi.getExpenseProductListOnline();

    await expenseTaxApi.getExpenseTaxListOnline();
    toast!.showToast(
      child: Widgets().getDownloadToast(AppStrings.expenseDataDownloaded.tr()),
      gravity: ToastGravity.BOTTOM,
      toastDuration: const Duration(seconds: 1),
    );

    await leaveApi.getLeaveRemainingList();
    await leaveApi.getLeaveList();
    await leaveApi.getLeaveTypeList();
    // await leaveApi.getUpcomingHolidayList();
    toast!.showToast(
      child: Widgets().getDownloadToast(AppStrings.leaveDataDownloaded.tr() ),
      gravity: ToastGravity.BOTTOM,
      toastDuration: const Duration(seconds: 1),
    );
    var paySlipApi = PaySlipAPI();
    await paySlipApi.paySlipList();
    toast!.showToast( 
      child: Widgets().getDownloadToast(AppStrings.payslipDataDownloaded.tr()),
      gravity: ToastGravity.BOTTOM,
      toastDuration: const Duration(seconds: 1),
    );

    timer = Timer.periodic(
      const Duration(seconds: 5),
      (timer) => checkDeviceActivation(),
    );
    // });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> checkDeviceActivation() async {
    bool checkInternet = await InternetConnectionChecker.instance.hasConnection;
    if (checkInternet == false) {
      if (!mounted) return;
      showDialog(context: context, builder: (_) => const CustomEventDialog());
      return;
    }
    var pref = await SharedPreferences.getInstance();
    var deviceState = '';
    var loginApi = loginAPI();
    // DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    // AndroidDeviceInfo androidDeviceInfo = await deviceInfoPlugin.androidInfo;
    var shareComponent = ShareComponentClass();
    var deviceStatus = await shareComponent.readDeviceId();

    deviceState = await loginApi.checkDevice(deviceStatus.id);

    log('deviceState--------$deviceState');
    if (deviceState == 'waiting') {
      await pref.setString('waitingStage', 'true');
    } else if (deviceState == 'approve') {
      await pref.setString('waitingStage', 'false');
      await pref.setBool(Constant.IS_APPROVED, true);
      dispose();
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (BuildContext context) {
            return const HomeScreen();
          },
        ),
      );
    } else if (deviceState == 'reject') {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (BuildContext context) {
            return const RejectScreen();
          },
        ),
      );
    } else if (deviceState == 'Invalid cookie.') {
      toast!.showToast(
        child: Widgets().getErrorToast(AppStrings.sessionExpiredPleaseLoginAgain.tr()),
        gravity: ToastGravity.BOTTOM,
        toastDuration: const Duration(seconds: 3),
      );
      await pref.setString('jwt_token', "null");
      await Future.delayed(const Duration(seconds: 4));
      // timer = Timer.periodic(Duration(seconds: 3), (timer) {
      if (!mounted) return;
      Navigator.of(_scaffoldCtx).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (BuildContext context) {
            return const LoginScreen();
          },
        ),
        (route) => false,
      );
    } else {
      toast!.showToast(
        child: Widgets().getErrorToast(deviceState),
        gravity: ToastGravity.BOTTOM,
        toastDuration: const Duration(seconds: 3),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    _scaffoldCtx = context;
    SizeConfig().init(context);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppStrings.waitting.tr(),
              style: const TextStyle(
                color: Colors.black,
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              AppStrings.approvalOrDownload.tr(),
              style: const TextStyle(
                color: Colors.black,
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
            JumpingDotsProgressIndicator(
              numberOfDots: 5,
              fontSize: 40,
              color: style.ColorObj.mainColor,
            ),
          ],
        ),
      ),
    );
  }
}
