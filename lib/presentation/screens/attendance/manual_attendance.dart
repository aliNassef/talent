import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:talent/data/api/attendance_api.dart';
import 'package:talent/data/database/dao/attendance_dao.dart';
import 'package:talent/data/database/dao/employee_dao.dart';
import 'package:talent/utility/share/app_strings.dart';
import 'package:talent/utility/style/theme.dart' as style;
import 'package:talent/utility/utils/extension.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/models/attendance/attendance.dart';
import '../../../data/models/employee/employee.dart';
import '../../../utility/share/share_component.dart';
import '../../../utility/style/theme.dart';
import '../../../utility/utils/date_util.dart';
import '../../../utility/utils/size_config.dart';
import '../../widgets/custom_event_dialog.dart';
import '../../widgets/widgets.dart';
import 'package:easy_localization/easy_localization.dart';

import '../base.account/login.dart';
 
class ManualAttendance extends StatefulWidget {
  const ManualAttendance({super.key});

  @override
  ManualAttendanceState createState() => ManualAttendanceState();
}

class ManualAttendanceState extends State<ManualAttendance> {
  double? lat = 0, long = 0;
  String address = "";
  String checkInStr = "";
  var todayDate = '';
  Employee? employee;
  // ignore: prefer_typing_uninitialized_variables
  var database;
  var employeeDao = EmployeeDao();
  var attendanceDao = AttendanceDao();
  bool? _isCheckIn;
  TextEditingController reasonController = TextEditingController();
  var startTime = '';
  // ignore: prefer_typing_uninitialized_variables
  var endTime;
  FToast? toast;
  //late SimpleFontelicoProgressDialog _dialog;
  var attendanceApi = AttendanceAPI();
  // ignore: prefer_typing_uninitialized_variables
  var pref;
  late int uid;
  String base64Image = '';
  final photos = <File>[];
  final images = <Uint8List>[];
  List<String> base64ImageList = [];
  Uint8List? bytes;
  var empType = '';
  Attendance? lastAttendance;
  // ignore: prefer_typing_uninitialized_variables
  var date;
  // ignore: prefer_typing_uninitialized_variables
  var lastAttCheckDate;
  // ignore: prefer_typing_uninitialized_variables
  var checkInOutTime;
  late Timer timer;
  var timeForNow = '';
  // ignore: prefer_typing_uninitialized_variables, non_constant_identifier_names
  var check_in_datetime;
  // ignore: prefer_typing_uninitialized_variables, non_constant_identifier_names
  var check_out_datetime;
  late BuildContext _scaffoldCtx;
  var locationCheckMessage = '';
  @override
  void initState() {
    super.initState();
    toast = FToast();
    toast!.init(context);
    _loadData();
  }

  _loadData() async {
    pref = await SharedPreferences.getInstance();

    uid = await pref.getInt('uid');
    employee = await employeeDao.getSingleEmployeeById(uid);

    empType = employee!.employee_type!;
    bytes = base64.decode("${employee!.avatar}");

    date = DateFormat("EEEE, d MMM yyyy").format(DateTime.now());

    final now = DateTime.now();
    startTime = DateFormat('jm').format(now);


    check_in_datetime = DateUtil().getSqlDateTime(now, 'yyyy-MM-dd HH:mm:ss');

    check_out_datetime = DateUtil().getSqlDateTime(now, 'yyyy-MM-dd HH:mm:ss');

    checkIsCheckIn();

    Position position = await Geolocator.getCurrentPosition(
      // ignore: deprecated_member_use
      desiredAccuracy: LocationAccuracy.high,
    );
    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );
    Placemark place = placemarks[0];
    address = '${place.street!} , ${place.locality!} , ${place.country!}';

    setState(() {});
  }

  checkIsCheckIn() async {
    log('checkIsCheckIn-------------');
    lastAttCheckDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    var tempAttendance = await attendanceDao.getTodayAttendance(
      lastAttCheckDate,
    );

    log('tempAttendance------$tempAttendance');

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

    _isCheckIn = pref.getBool('is_check_in');

    if (_isCheckIn == null || _isCheckIn!) {
      checkInStr = AppStrings.checkIn.tr();
    } else {
      checkInStr = AppStrings.checkOut.tr();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _scaffoldCtx = context;
    SizeConfig().init(context);
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        log('will pop---------');
        Navigator.pop(context);

        return false;
      },
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Scaffold(
          body: SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: <Widget>[
                Positioned(
                  top: 0,
                  child: Container(
                    height: 50.0.hp(context),
                    width: MediaQuery.of(context).size.width,
                    color: style.ColorObj.mainColor,
                  ),
                ),
                Positioned(
                  top: 5,
                  child: SizedBox(
                    height: 50.0.hp(context),
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      children: [
                        SizedBox(height: 3.0.hp(context)),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: const Icon(
                                Icons.arrow_back,
                                size: 25,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              checkInStr,
                              style: style.normalDoubleXLWhiteText,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 23.0.hp(context),
                  child: Container(
                    padding: EdgeInsets.only(top: 1.0.hp(context)),
                    height: 82.0.hp(context),
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      boxShadow: const [
                        BoxShadow(
                          offset: Offset(4, -4),
                          blurRadius: 3,
                          spreadRadius: 1,
                          color: Colors.black12,
                        ),
                      ],
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15.0.wp(context)),
                        topRight: Radius.circular(15.0.wp(context)),
                      ),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          SizedBox(
                            height: 9.0.hp(context), //5
                          ),
                          Text(
                            employee != null ? employee!.employee_name! : '',
                            style: boldXLGreyText,
                          ),
                          SizedBox(height: 1.0.hp(context)),
                          Text(
                            employee != null ? employee!.job_name! : '',
                            style: normalSmallGreyText,
                          ),
                          SizedBox(height: 1.0.hp(context)),
                          Container(
                            height: 26.0.hp(context),
                            width: 80.0.wp(context),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.all(
                                Radius.circular(8),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  offset: Offset(4, 4),
                                  spreadRadius: 1,
                                  blurRadius: 4,
                                  color: Colors.black12,
                                ),
                                BoxShadow(
                                  offset: Offset(-4, -4),
                                  spreadRadius: 1,
                                  blurRadius: 4,
                                  color: Colors.black12,
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                InkWell(
                                  // onTap: _selectTime,
                                  onTap: () {},
                                  child: Container(
                                    margin: EdgeInsets.only(
                                      top: 3.0.hp(context),
                                    ),
                                    height: 9.0.hp(context),
                                    width: 60.0.wp(context),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color:
                                            style.ColorObj.dropDownBorderColor,
                                      ),
                                      borderRadius: const BorderRadius.all(
                                        Radius.circular(8),
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Text(
                                          AppStrings.time.tr(),
                                          style: boldXLGreyText,
                                        ),

                                        Text(startTime, style: boldXLGreenText),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: 2.0.hp(context)),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 5.0.wp(context),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.location_on,
                                        color: ColorObj.mainColor,
                                      ),
                                      SizedBox(width: 5.0.wp(context)),
                                      Flexible(
                                        child: Text(
                                          address,
                                          style: normalSmallGreyText,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 2.0.hp(context)),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 5.0.wp(context),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.date_range,
                                        color: ColorObj.mainColor,
                                      ),
                                      SizedBox(width: 5.0.wp(context)),
                                      Text(
                                        date ?? '',
                                        style: normalSmallGreyText,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 2.0.hp(context)),
                          AnimatedPadding(
                            padding: MediaQuery.of(context).viewInsets,
                            duration: const Duration(milliseconds: 100),
                            curve: Curves.decelerate,
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.0.wp(context),
                              ),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                                decoration: const BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(8),
                                  ),
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      offset: Offset(4, 4),
                                      blurRadius: 4,
                                      spreadRadius: 1,
                                      color: Colors.black12,
                                    ),
                                    BoxShadow(
                                      offset: Offset(-4, -4),
                                      blurRadius: 4,
                                      spreadRadius: 1,
                                      color: Colors.black12,
                                    ),
                                  ],
                                ),
                                child: TextFormField(
                                  controller: reasonController,
                                  style: normalSmallGreyText,
                                  cursorColor: Colors.grey,
                                  maxLines: 4,
                                  decoration: InputDecoration(
                                    hintText: AppStrings.reasonDetail.tr(),
                                    hintStyle: normalSmallGreyText,
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 2.0.hp(context)),

                          SizedBox(height: 2.0.hp(context)),
                          SizedBox(
                            height: 45,
                            width: 80.0.wp(context),
                            child: ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor: WidgetStateProperty.all(
                                  ColorObj.mainColor,
                                ),
                                shape: WidgetStateProperty.all(
                                  const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(5),
                                    ),
                                  ),
                                ),
                              ),
                              onPressed: () async {
                                await checkIsCheckIn();
                                await _sendAttendance();
                              },
                              child: Text(
                                AppStrings.submit.tr(),
                                style: normalLargeWhiteText,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 15.0.hp(context),
                  child: Container(
                    height: 25.0.wp(context),
                    width: 25.0.wp(context),
                    decoration: BoxDecoration(
                      image: bytes != null
                          ? DecorationImage(
                              image: MemoryImage(bytes!),
                              fit: BoxFit.cover,
                            )
                          : const DecorationImage(
                              image: AssetImage(
                                'assets/imgs/default_avator.png',
                              ),
                              fit: BoxFit.cover,
                            ),
                      color: Colors.grey,
                      shape: BoxShape.circle,
                      boxShadow: const [
                        BoxShadow(
                          offset: Offset(4, 4),
                          spreadRadius: 1,
                          blurRadius: 4,
                          color: Colors.black12,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _sendAttendance() async {
    bool checkInternet = await InternetConnectionChecker.instance.hasConnection;
    if (checkInternet == false) {
      // ignore: use_build_context_synchronously
      showDialog(context: context, builder: (_) => CustomEventDialog());
      return;
    }

    if (reasonController.text == '') {
      toast!.showToast(
        child: Widgets().getWarningToast(AppStrings.pleaseEnterReason.tr()),
        gravity: ToastGravity.BOTTOM,
        toastDuration: const Duration(seconds: 2),
      );
      return null;
    }

    Attendance? att;

    if (_isCheckIn == null || _isCheckIn!) {
      String todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
      Attendance? attendance;
      attendance = await attendanceDao.getTodayAttendanceCheckForCheckIn(
        todayDate,
      );
      checkInOutTime = DateFormat('H:m a').format(DateTime.now());

      if (attendance != null) {
        EasyLoading.show(status: '................');
        EasyLoading.dismiss();
        toast!.showToast(
          child: Widgets().getWarningToast(AppStrings.todayAlreadyCheckIn.tr()),
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

    EasyLoading.dismiss();
  }

  Future<Attendance?> _insertCheckIn() async {
    String todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    Position userPosition = await Geolocator.getCurrentPosition(
      // ignore: deprecated_member_use
      desiredAccuracy: LocationAccuracy.high,
    );

  
    var shareComponent = ShareComponentClass();
    var deviceStatus = await shareComponent.readDeviceId();

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
      userPosition.latitude,
      userPosition.longitude,
      0,
      0,
      address,
      '',
      deviceStatus.id,
      //androidDeviceInfo.androidId,
      locationCheckMessage == ''
          ? 'Check in Address   : ${address != '' ? address : '-'}    ,    Check in Reason  : ${reasonController.text}'
          : 'Check in Address   : ${address != '' ? address : '-'}    ,    Check in Reason  : ${reasonController.text}\n    ( $locationCheckMessage )',
      '',
      'default',
      '',
      '',
    );

    log('att----$att');
    return att;
  }

  Future<Attendance?> _insertCheckout() async {
    Attendance? attendance;
    var todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    var tempAttendance = await attendanceDao.getTodayAttendanceAlreadyCheckIn(
      todayDate,
    );
    checkInOutTime = DateFormat('H:m a').format(DateTime.now());
    Position userPosition = await Geolocator.getCurrentPosition(
      // ignore: deprecated_member_use
      desiredAccuracy: LocationAccuracy.high,
    );

    if (tempAttendance != null) {
      attendance = tempAttendance;

      log('check out obj-----${attendance!.toJson()}');

      Attendance att = Attendance(
        attendance.attendanceId,
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
        userPosition.latitude,
        userPosition.longitude,
        attendance.in_location,
        attendance.out_location,
        attendance.device_id,
        // '     -    ' + 'Evening : ' + reasonController.text.toString(),
        locationCheckMessage == ''
            ? '   -   Check out Address   : ${address != '' ? address : '-'}    ,    Check out Reason  : ${reasonController.text}'
            : '   -   Check out Address   : ${address != '' ? address : '-'}    ,    Check out Reason : ${reasonController.text}    ( $locationCheckMessage )',
        attendance.write_date,
        attendance.att_type,
        '',
        '',
        id: attendance.id,
      );
      log('att----$att');
      return att;
    } else {
      return null;
    }
  }

  _syncToServer(Attendance? attendance) async {
    log('_syncCheckInToServer----------');
    if (attendance == null) {
      EasyLoading.dismiss();

      toast!.showToast(
        child: Widgets().getErrorToast(AppStrings.todayAlreadyCheckIn.tr()),
        gravity: ToastGravity.BOTTOM,
        toastDuration: const Duration(seconds: 2),
      );
      return;
    }

    // ignore: prefer_typing_uninitialized_variables
    var checkInResult;
    EasyLoading.show(status: AppStrings.submittingPleaseWait.tr());

    if (_isCheckIn!) {
      checkInResult = await attendanceApi.createAttendance(attendance, '');
    } else {
      checkInResult = await attendanceApi.checkOutAttendance(attendance, '');
    }

    log('checkInResult------------$checkInResult');

    if (checkInResult['result'] == 'fail') {
      // ignore: prefer_typing_uninitialized_variables
      var message;

      if (checkInResult['attendanceMessage'] == '') {
        message = AppStrings.checkInFail.tr();
      } else {
        message = checkInResult['attendanceMessage'];
        if (message == 'Invalid cookie.') {
          EasyLoading.dismiss();
          toast!.showToast(
            child: Widgets().getErrorToast(
              AppStrings.sessionExpiredPleaseLoginAgain.tr(),
            ),
            gravity: ToastGravity.BOTTOM,
            toastDuration: const Duration(seconds: 3),
          );
          await pref.setString('jwt_token', "null");
          await Future.delayed(const Duration(seconds: 4));

          // ignore: use_build_context_synchronously
          Navigator.of(_scaffoldCtx).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (BuildContext context) {
                return const LoginScreen();
              },
            ),
            (route) => false,
          );

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

    EasyLoading.dismiss();

    var status = checkInResult['attendanceMessage'];

    if (status == 'exist') {
      toast!.showToast(
        child: Widgets().getErrorToast(
          AppStrings.attendanceDateIsAlreadyExistInTheSystem.tr(),
        ),
        gravity: ToastGravity.BOTTOM,
        toastDuration: const Duration(seconds: 3),
      );
    } else if (status == 'in') {
      await pref.setBool('is_check_in', false);

      attendance.attendanceId = int.parse(
        checkInResult['attendanceId'].toString(),
      );
      await attendanceDao.updateAttendance(attendance);

      var resultId = await attendanceDao.insertSingleAttendance(attendance);

      attendance.id = int.parse(resultId.toString());
      await attendanceDao.updateAttendance(attendance);
      lastAttCheckDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
      var tempAttendance = await attendanceDao.getTodayAttendance(
        lastAttCheckDate,
      );

      toast!.showToast(
        child: Widgets().getSuccessToast(AppStrings.checkInSuccessful.tr()),
        gravity: ToastGravity.BOTTOM,
        toastDuration: const Duration(seconds: 3),
      );

      lastAttendance = tempAttendance;
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
    } else if (status == 'out') {
      log('else if Checkout successful.-------');

      await pref.setBool('is_check_in', true);

      attendance.id = attendance.id;
      await attendanceDao.updateAttendance(attendance);

      var tempAttendance = await attendanceDao.getTodayAttendance(
        lastAttCheckDate,
      );
      toast!.showToast(
        child: Widgets().getSuccessToast(AppStrings.checkOutSuccessful.tr()),
        gravity: ToastGravity.BOTTOM,
        toastDuration: const Duration(seconds: 3),
      );

      lastAttendance = tempAttendance;
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
    }
  }
}
