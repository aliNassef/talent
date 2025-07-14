import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
 import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:location/location.dart' as Loc;
import 'package:talent/data/api/attendance_api.dart';
import 'package:talent/data/database/dao/attendance_dao.dart';
import 'package:talent/data/database/dao/employee_dao.dart';
import 'package:talent/utility/style/theme.dart' as Style;
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
import 'attendance_screen.dart';

class ManualAttendance extends StatefulWidget {
  _ManualAttendanceState createState() => _ManualAttendanceState();
}

class _ManualAttendanceState extends State<ManualAttendance> {
  final Geolocator _geolocator = Geolocator();
  DateTime _dateTime = DateTime.now();
  Future<Position>? _initialPosition; //= LatLng(20.5937, 78.9629);
  double? lat = 0, long = 0;
  String address = "";
  String checkInStr = "";
  var todayDate = '';
  Employee? employee;
  var database;
  var employeeDao = EmployeeDao();
  var attendanceDao = AttendanceDao();
  //SharedPreferences? _sharedPreferences;
  bool? _isCheckIn;
  TextEditingController reasonController = TextEditingController();
  // Completer<GoogleMapController> _mapController = Completer();
  var startTime = '';
  var endTime;
  FToast? toast;
  //late SimpleFontelicoProgressDialog _dialog;
  TimeOfDay _startTimeTod = TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTimeTod = TimeOfDay(hour: 9, minute: 0);
  var _shareComponent = ShareComponentClass();
  var attendanceApi = AttendanceAPI();
  var pref;
  late int uid;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  String base64Image = '';
  final photos = <File>[];
  final images = <Uint8List>[];
  List<String> base64ImageList = [];
  Uint8List? bytes;
  var empType = '';
  Attendance? lastAttendance;
  var date;
  var lastAttCheckDate;
  var checkInOutTime;
  late Timer timer;
  var timeForNow = '';
  final _timeNotifier = ValueNotifier<String>('');
  var check_in_datetime;
  var check_out_datetime;
  late BuildContext _scaffoldCtx;
  var locationCheckMessage = '';
  initState() {
    super.initState();
    toast = FToast();
    toast!.init(context);
    // _initialPosition = _getCurrentLocation();
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

    final format = DateFormat.jm();
    _startTimeTod = TimeOfDay.fromDateTime(format.parse(startTime));

    check_in_datetime = DateUtil().getSqlDateTime(now, 'yyyy-MM-dd HH:mm:ss');

    check_out_datetime = DateUtil().getSqlDateTime(now, 'yyyy-MM-dd HH:mm:ss');

    checkIsCheckIn();

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark place = placemarks[0];
    address = '${place.street!} , ${place.locality!} , ${place.country!}';

    setState(() {});
  }

  checkIsCheckIn() async {
    print('checkIsCheckIn-------------');
    lastAttCheckDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    var tempAttendance =
        await attendanceDao.getTodayAttendance(lastAttCheckDate);

    print('tempAttendance------$tempAttendance');

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

    if (_isCheckIn == null || _isCheckIn!) {
      checkInStr = "check_in".tr();
    } else {
      checkInStr = 'check_out'.tr();
    }
  }

  // Future<Position> _getCurrentLocation() async {
  //   // bool locOK = true;
  //   // Loc.Location location = new Loc.Location();
  //   // bool _serviceEnabled;
  //   // Loc.PermissionStatus _permissionGranted;

  //   // _serviceEnabled = await location.serviceEnabled();
  //   // if (!_serviceEnabled) {
  //   //   _serviceEnabled = await location.requestService();
  //   //   if (!_serviceEnabled) {
  //   //     locOK = false;
  //   //   }
  //   // }

  //   // _permissionGranted = await location.hasPermission();
  //   // if (_permissionGranted == Loc.PermissionStatus.denied) {
  //   //   _permissionGranted = await location.requestPermission();
  //   //   if (_permissionGranted != Loc.PermissionStatus.granted) {
  //   //     locOK = false;
  //   //   }
  //   // }

  //   bool serviceEnabled;
  //   LocationPermission permission;

  //   // Test if location services are enabled.
  //   serviceEnabled = await Geolocator.isLocationServiceEnabled();
  //   if (!serviceEnabled) {
  //     // Location services are not enabled don't continue
  //     // accessing the position and request users of the
  //     // App to enable the location services.
  //     toast!.showToast(
  //       child: Widgets().getWarningToast('Location services are disabled.'),
  //       gravity: ToastGravity.BOTTOM,
  //       toastDuration: Duration(seconds: 5),
  //     );

  //     locationCheckMessage =
  //         'Location services are disabled  in this user\'s device.';

  //     return Future.error('Location services are disabled.');
  //   }

  //   permission = await Geolocator.checkPermission();
  //   if (permission == LocationPermission.denied) {
  //     permission = await Geolocator.requestPermission();
  //     if (permission == LocationPermission.denied) {
  //       // Permissions are denied, next time you could try
  //       // requesting permissions again (this is also where
  //       // Android's shouldShowRequestPermissionRationale
  //       // returned true. According to Android guidelines
  //       // your App should show an explanatory UI now.
  //       toast!.showToast(
  //         child: Widgets().getWarningToast('Location permissions are denied.'),
  //         gravity: ToastGravity.BOTTOM,
  //         toastDuration: Duration(seconds: 5),
  //       );
  //       locationCheckMessage =
  //           'Location permissions are denied in this user\'s device.';
  //       return Future.error('Location permissions are denied');
  //     }
  //   }

  //   if (permission == LocationPermission.deniedForever) {
  //     // Permissions are denied forever, handle appropriately.
  //     toast!.showToast(
  //       child: Widgets().getWarningToast(
  //           'Location permissions are permanently denied, we cannot request permissions.'),
  //       gravity: ToastGravity.BOTTOM,
  //       toastDuration: Duration(seconds: 5),
  //     );

  //     locationCheckMessage =
  //         'Location permissions are permanently denied, we cannot request permissions  in this user\'s device.';
  //     return Future.error(
  //         'Location permissions are permanently denied, we cannot request permissions.');
  //   }
  //   var position;

  //   EasyLoading.show(status: 'Fetching location------');
  //   position = await Geolocator.getCurrentPosition(
  //       desiredAccuracy: LocationAccuracy.high);
  //   await _getLocationAddress(position).then((value) {
  //     setState(() {
  //       address = value;
  //       print('address---------$value');
  //       EasyLoading.dismiss();
  //     });
  //   });

  //   print('position------${position.toString()}');
  //   return position;
  // }

  void dispose() {
    // controller?.dispose();
    super.dispose();
  }

  Future<String> _getLocationAddress(Position position) async {
    List<Placemark> locations =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    // print(locations[0]);
    Placemark placeMark = locations[0];
    String? street = placeMark.street;
    String? locality = placeMark.locality;
    String? subLocality = placeMark.subLocality;
    String? country = placeMark.country;
    print('country code-------${placeMark.country} : ${placeMark.postalCode}');
    return "$street, $locality,$country";
  }

  // void _onMapCreated(GoogleMapController controller) {
  //   _mapController.complete(controller);
  // }

  _selectTime() async {
    final newTime =
        await showTimePicker(context: context, initialTime: _startTimeTod);
    final dt = DateTime(DateTime.now().year, DateTime.now().month,
        DateTime.now().day, newTime!.hour, newTime.minute);
    check_in_datetime = DateUtil().getSqlDateTime(dt, 'yyyy-MM-dd HH:mm:ss');

    check_out_datetime = DateUtil().getSqlDateTime(dt, 'yyyy-MM-dd HH:mm:ss');

    if (newTime != null && newTime != _startTimeTod) {
      setState(() {
        _startTimeTod = newTime;
        startTime = _startTimeTod.format(context);
      });
    }
  }

  _selectEndTime() async {
    final newTime =
        await showTimePicker(context: context, initialTime: _endTimeTod);
    if (newTime != null && newTime != _endTimeTod) {
      setState(() {
        _endTimeTod = newTime;
        endTime = _endTimeTod.format(context);
      });
    }
  }

  Widget build(BuildContext context) {
    _scaffoldCtx = context;
    SizeConfig().init(context);
    return WillPopScope(
      onWillPop: () async {
        print('will pop---------');
        Navigator.pop(context);

        return false;
      },
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
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
                  color: Style.ColorObj.mainColor,
                ),
              ),
              Positioned(
                top: 5,
                child: SizedBox(
                  height: 50.0.hp(context),
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    children: [
                      SizedBox(
                        height: 3.0.hp(context),
                      ),
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
                              )),
                          Text(
                            checkInStr,
                            style: Style.normalDoubleXLWhiteText,
                          )
                        ],
                      ),
                      // Container(
                      //   height: 30.0.hp(context),
                      //   width: MediaQuery.of(context).size.width,
                      //   color: ColorObj.mainColor,
                      //   child: FutureBuilder(
                      //     future: _initialPosition,
                      //     builder: (context, AsyncSnapshot<Position> snapshot) {
                      //       print(
                      //           'snapshot.connectionState----------${snapshot.connectionState}');
                      //       if (snapshot.connectionState ==
                      //           ConnectionState.done) {
                      //         print(
                      //             'snapshot.hasError----------${snapshot.hasError}');
                      //         if (!snapshot.hasError) {
                      //           print('lat-------${snapshot.data!.latitude}');
                      //           print('long-------${snapshot.data!.longitude}');
                      //           lat = snapshot.data!.latitude; //to check
                      //           long = snapshot.data!.longitude; //to check
                      //           print("${snapshot..data} hello");
                      //           return GoogleMap(
                      //             rotateGesturesEnabled: false,
                      //             scrollGesturesEnabled: false,
                      //             zoomControlsEnabled: false,
                      //             zoomGesturesEnabled: false,
                      //             liteModeEnabled: false,
                      //             tiltGesturesEnabled: false,
                      //             myLocationEnabled: true,
                      //             myLocationButtonEnabled: false,
                      //             onMapCreated: _onMapCreated,
                      //             mapType: MapType.normal,
                      //             initialCameraPosition: CameraPosition(
                      //                 target: LatLng(snapshot.data!.latitude,
                      //                     snapshot.data!.longitude),
                      //                 zoom: 14),
                      //           );
                      //         } else {
                      //           print(snapshot.error);
                      //         }
                      //       }
                      //       return Center(
                      //         child: CircularProgressIndicator(),
                      //       );
                      //     },
                      //   ),
                      // ),
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
                            color: Colors.black12)
                      ],
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15.0.wp(context)),
                          topRight: Radius.circular(15.0.wp(context)))),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(
                          height: 9.0.hp(context), //5
                        ),
                        Text(
                          employee != null ? '${employee!.employee_name!}' : '',
                          style: boldXLGreyText,
                        ),
                        SizedBox(
                          height: 1.0.hp(context),
                        ),
                        Text(
                          employee != null ? '${employee!.job_name!}' : '',
                          style: normalSmallGreyText,
                        ),
                        SizedBox(
                          height: 1.0.hp(context),
                        ),
                        Container(
                          height: 26.0.hp(context),
                          width: 80.0.wp(context),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                            boxShadow: [
                              BoxShadow(
                                  offset: Offset(4, 4),
                                  spreadRadius: 1,
                                  blurRadius: 4,
                                  color: Colors.black12),
                              BoxShadow(
                                  offset: Offset(-4, -4),
                                  spreadRadius: 1,
                                  blurRadius: 4,
                                  color: Colors.black12),
                            ],
                          ),
                          child: Column(
                            children: [
                              InkWell(
                                // onTap: _selectTime,
                                onTap: () {},
                                child: Container(
                                  margin: EdgeInsets.only(top: 3.0.hp(context)),
                                  height: 9.0.hp(context),
                                  width: 60.0.wp(context),
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Style
                                              .ColorObj.dropDownBorderColor),
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(8))),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Text(
                                        "Time",
                                        style: boldXLGreyText,
                                      ),

                                      // ValueListenableBuilder(
                                      //   valueListenable: _timeNotifier,
                                      //   builder: (_, value, __) => RichText(
                                      //       text: TextSpan(
                                      //     text: '$value',
                                      //     style: boldXLGreenText,
                                      //   )),
                                      // )
                                      Text(
                                        startTime,
                                        style: boldXLGreenText,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 2.0.hp(context),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 5.0.wp(context)),
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
                                    )
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 2.0.hp(context),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 5.0.wp(context)),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.date_range,
                                      color: ColorObj.mainColor,
                                    ),
                                    SizedBox(width: 5.0.wp(context)),
                                    Text(
                                      date != null ? date : '',
                                      style: normalSmallGreyText,
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 2.0.hp(context),
                        ),
                        AnimatedPadding(
                          padding: MediaQuery.of(context).viewInsets,
                          duration: const Duration(milliseconds: 100),
                          curve: Curves.decelerate,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10.0.wp(context)),
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              decoration: const BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8)),
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                        offset: Offset(4, 4),
                                        blurRadius: 4,
                                        spreadRadius: 1,
                                        color: Colors.black12),
                                    BoxShadow(
                                        offset: Offset(-4, -4),
                                        blurRadius: 4,
                                        spreadRadius: 1,
                                        color: Colors.black12)
                                  ]),
                              child: TextFormField(
                                controller: reasonController,
                                style: normalSmallGreyText,
                                cursorColor: Colors.grey,
                                maxLines: 4,
                                decoration: InputDecoration(
                                    hintText: "Reason Detail ...",
                                    hintStyle: normalSmallGreyText,
                                    border: InputBorder.none),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 2.0.hp(context),
                        ),

                        SizedBox(
                          height: 2.0.hp(context),
                        ),
                        SizedBox(
                            height: 45,
                            width: 80.0.wp(context),
                            child: ElevatedButton(
                                style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                        ColorObj.mainColor),
                                    shape: MaterialStateProperty.all(
                                        const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(5))))),
                                onPressed: () async {
                                  await checkIsCheckIn();
                                  await _sendAttendance();
                                },
                                child: Text(
                                  "Submit",
                                  style: normalLargeWhiteText,
                                ))),
                        // SizedBox(
                        //   height: 5.0.hp(context),
                        // ),
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
                                image: MemoryImage(bytes!), fit: BoxFit.cover)
                            : DecorationImage(
                                image: AssetImage(
                                    'assets/imgs/default_avator.png'),
                                fit: BoxFit.cover),
                        color: Colors.grey,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                              offset: Offset(4, 4),
                              spreadRadius: 1,
                              blurRadius: 4,
                              color: Colors.black12)
                        ]),
                  )),
            ],
          ),
        )),
      ),
    );
  }

  _sendAttendance() async {
    bool checkInternet = await InternetConnectionChecker.instance.hasConnection;
    if (checkInternet == false) {
      showDialog(context: context, builder: (_) => CustomEventDialog());
      return;
    }

    if (reasonController.text == '' || reasonController.text == null) {
      toast!.showToast(
        child: Widgets().getWarningToast('Please enter reason.'),
        gravity: ToastGravity.BOTTOM,
        toastDuration: Duration(seconds: 2),
      );
      return null;
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

    await _syncToServer(att);

    EasyLoading.dismiss();
  }

  Future<Attendance?> _insertCheckIn() async {
    Attendance? attendance;
    String todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    Position userPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    // DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    // AndroidDeviceInfo androidDeviceInfo = await deviceInfoPlugin.androidInfo;
    var shareComponent = ShareComponentClass();
    var deviceStatus = await shareComponent.readDeviceId();
    DateTime _currentDateTime = DateTime.now();

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
            ? 'Check in Address   : ${address != '' ? address : '-'}    ,    Check in Reason  : ' +
                reasonController.text.toString()
            : 'Check in Address   : ${address != '' ? address : '-'}    ,    Check in Reason  : ' +
                reasonController.text.toString() +
                '\n' +
                '    ( ' +
                locationCheckMessage +
                ' )',
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

      print('check out obj-----${attendance!.toJson()}');
      DateTime _currentDateTime = DateTime.now();

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
              ? '   -   Check out Address   : ${address != '' ? address : '-'}    ,    Check out Reason  : ' +
                  reasonController.text.toString()
              : '   -   Check out Address   : ${address != '' ? address : '-'}    ,    Check out Reason : ' +
                  reasonController.text.toString() +
                  '    ( ' +
                  locationCheckMessage +
                  ' )',
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

    var status = checkInResult['attendanceMessage'];

    if (status == 'exist') {
      toast!.showToast(
        child: Widgets()
            .getErrorToast('Attendance date is already exist in the system.'),
        gravity: ToastGravity.BOTTOM,
        toastDuration: Duration(seconds: 3),
      );
    } else if (status == 'in') {
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

      toast!.showToast(
        child: Widgets().getSuccessToast('Check In Successful'),
        gravity: ToastGravity.BOTTOM,
        toastDuration: Duration(seconds: 3),
      );

      lastAttendance = tempAttendance;
      Navigator.pop(context);
    } else if (status == 'out') {
      print('else if Checkout successful.-------');

      await pref.setBool('is_check_in', true);

      attendance.id = attendance.id;
      await attendanceDao.updateAttendance(attendance);

      var tempAttendance =
          await attendanceDao.getTodayAttendance(lastAttCheckDate);
      toast!.showToast(
        child: Widgets().getSuccessToast('Check Out Successful'),
        gravity: ToastGravity.BOTTOM,
        toastDuration: Duration(seconds: 3),
      );

      lastAttendance = tempAttendance;
      Navigator.pop(context);
    }
  }
}
