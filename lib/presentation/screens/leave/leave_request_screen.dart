import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:talent/data/api/leave_api.dart';
import 'package:talent/data/database/dao/employee_dao.dart';
import 'package:talent/data/database/dao/leave_reason_dao.dart';
import 'package:talent/data/database/dao/leave_remain.dart';
import 'package:talent/data/database/dao/leave_type_dao.dart';
import 'package:talent/data/models/leave_remain/leave_remain.dart';
import 'package:talent/presentation/screens/leave/leave_history_list_screen.dart';
import 'package:talent/utility/share/app_strings.dart';
import 'package:talent/utility/style/theme.dart' as style;
import 'package:file_picker/file_picker.dart';
import 'package:talent/utility/utils/extension.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/models/employee/employee.dart';
import '../../../data/models/leave/leave.dart';
import '../../../data/models/leave_reason/leave_reason.dart';
import '../../../data/models/leave_type/leave_type.dart';
import '../../../utility/style/theme.dart';
import '../../../utility/utils/date_util.dart';
import '../../../utility/utils/size_config.dart';
import '../../widgets/custom_event_dialog.dart';
import '../../widgets/widgets.dart';
import '../base.account/login.dart';

class LeaveRequestScreen extends StatefulWidget {
  const LeaveRequestScreen({super.key});

  @override
  LeaveRequestScreenState createState() => LeaveRequestScreenState();
}

class LeaveRequestScreenState extends State<LeaveRequestScreen> {
  //API
  var leaveApi = LeaveAPI();

  //Dao
  var leaveTypeDao = LeaveTypeDao();
  var employeeDao = EmployeeDao();
  var leaveReasonDao = LeaveReasonDao();
  var leaveRemainDao = LeaveRemainDao();

  Employee? employee;

  //Variable
  // ignore: prefer_typing_uninitialized_variables
  var pref;
  int? userId;
  FToast? toast;
  var todayDate = '';
  var userName = '';
  DateTime? startDate;
  DateTime? endDate;
  String path = "";
  late String fileName;
  double? noOfDay = 1.0;
  String? _selectedDay;
  bool _isHalfDay = false;
  String _selectedStartDate = '';
  String _selectedEndDate = '';
  late FileType fileType;
  LeaveType? _selectedLeaveType;
  final DateTime _dateTime = DateTime.now();
  List<LeaveReason> leaveReasonList = [];
  List<LeaveType> leaveTypeList = [];
  List<LeaveRemain> leaveRemainList = [];
  List<String> dayTypeList = ['Morning', 'Afternoon'];
  final TextEditingController _reasonController = TextEditingController();

  late final DateTime initDateTime;
  late final DateTime lastDate;
  DateTime startTime = DateTime.now();
  DateTime endTime = DateTime.now();
  int totalDays = 0;
  bool selectTime = false;
  String base64String = '';
  late BuildContext _scaffoldCtx;
  var monthName = '';
  var year = '';
  String selectedDate = 'Tuesday, Nov 2 2021';

  @override
  initState() {
    super.initState();
    toast = FToast();
    toast!.init(context);

    _loadData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _loadData() async {
    todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    initDateTime = DateTime.now();
    monthName = DateFormat('MMM').format(DateTime.now());
    year = DateFormat('yyyy').format(DateTime.now());
    lastDate = DateTime(3000);
    _selectedStartDate = getDateFormat(_dateTime);
    _selectedEndDate = getDateFormat(_dateTime);
    pref = await SharedPreferences.getInstance();
    userId = await pref.getInt('uid');
    userName = await pref.getString('user_name');

    employee = await employeeDao.getSingleEmployeeById(userId!);
    leaveTypeList = await leaveTypeDao.getLeaveTypeList();
    final seenNames = <int>{};
    leaveTypeList = leaveTypeList
        .where((item) => seenNames.add(item.leave_type_id!))
        .toList();
    log('leaveTypeList---------$leaveTypeList');

    leaveReasonList = await leaveReasonDao.getLeaveReasonList();

    leaveRemainList = await leaveRemainDao.getLeaveRemainList();
    log('leaveRemainList---------$leaveRemainList');

    selectedDate = DateUtil().getDateFormat(_dateTime);

    setState(() {});
  }

  getDateFormat(DateTime dateTime) {
    // DateFormat formatter = DateFormat('d-M-y');
    DateFormat formatter = DateFormat('yyyy-MM-dd');
    String formatted = formatter.format(dateTime);
    log (formatted);
    return formatted;
  }

  int totalDay() => totalDays = endTime.difference(startTime).inDays;

  void _openFileExplorer() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'pdf', 'doc'],
      allowMultiple: true,
    );
    if (result != null) {
      setState(() {
        /*For(int i=0;i<result.length;i++) {

        }*/
        File file = File((result.files.single.path).toString());
        path = file.path;
        final bytes = File(file.path).readAsBytesSync();

        base64String = base64Encode(bytes);
        log(path);
      });
    } else {
      path = "";
    }
  }



  List<DropdownMenuItem<LeaveType>> _addDividersAfterItemsForLeaveType(
    List<LeaveType> items,
  ) {
    log('items-----$items');
    List<DropdownMenuItem<LeaveType>> menuItems = [];
    for (var item in items) {
      menuItems.addAll([
        DropdownMenuItem<LeaveType>(
          value: item,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3.0),
            child: Text(item.name!, style: normalMediumBalckText),
          ),
        ),
        if (item != items.last)
          DropdownMenuItem<LeaveType>(
            enabled: false,
            child: Container(height: 1, color: Colors.black12),
          ),
      ]);
    }
    return menuItems;
  }


  List<DropdownMenuItem<String>> _addDividersAfterItemsForDayType(
    List<String> items3,
  ) {
    log('items-----$items3');
    List<DropdownMenuItem<String>> menuItems = [];
    for (var item in items3) {
      menuItems.addAll([
        DropdownMenuItem<String>(
          value: item,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3.0),
            child: Text(item, style: normalMediumBalckText),
          ),
        ),
        if (item != items3.last)
          DropdownMenuItem<String>(
            enabled: false,
            child: Container(height: 1, color: Colors.black12),
          ),
      ]);
    }
    return menuItems;
  }


  @override
  Widget build(BuildContext context) {
    _scaffoldCtx = context;
    SizeConfig().init(context);
    bool isTablet = false;
    MediaQuery.of(context).size.width / MediaQuery.of(context).size.height;
    var longestSide = MediaQuery.of(context).size.longestSide;
    log('longestSide-------$longestSide');
    if (longestSide > 790) {
      isTablet = true;
    } else if (longestSide > 700) {
    } else {
    }
    log('isTablet-----$isTablet');
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) {
              return const LeaveHistoryListScreen();
            },
          ),
        );
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: style.ColorObj.mainColor,
          title: Text(AppStrings.newLeaveRequest.tr(), style: style.appBarTitleStyle),
          leading: InkWell(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return const LeaveHistoryListScreen();
                  },
                ),
              );
            },
            child: const Padding(
              padding: EdgeInsets.only(right: 10.0),
              child: Icon(Icons.arrow_back, size: 28, color: Colors.white),
            ),
          ),
        ),
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: SingleChildScrollView(
            child: Container(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: 60,
                      child: Card(
                        child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all(
                              const Color(0xfff0efef),
                            ),
                            shape: WidgetStateProperty.all(
                              const RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(5),
                                ),
                              ),
                            ),
                          ),
                          child: Text(
                            selectedDate,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                               color: Color(0xff006ea5),
                              fontSize: 20,
                            ),
                          ),
                          onPressed: () {},
                        ),
                      ),
                    ),
                
                    const SizedBox(height: 8),
                    Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: 2.0.wp(context),
                        vertical: 2.0.hp(context),
                      ),
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            offset: Offset(4, 4),
                            blurRadius: 3,
                            spreadRadius: 1,
                            color: Colors.black12,
                          ),
                          BoxShadow(
                            offset: Offset(-2, -2),
                            blurRadius: 2,
                            spreadRadius: 1,
                            color: Colors.black12,
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(5.0.wp(context)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Divider(),
                            Container(
                              height: 40,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(6),
                                ),
                                border: Border.all(
                                  color: ColorObj.dropDownBorderColor,
                                ),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton2(
                                  dropdownFullScreen: true,
                                  dropdownDecoration: const BoxDecoration(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(6),
                                    ),
                                  ),
                                  isExpanded: true,
                                  hint: Text(
                                    'Select Leave Type',
                                    style: normalMediumGreyText,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  items: _addDividersAfterItemsForLeaveType(
                                    leaveTypeList,
                                  ),
                                  itemHeight: 20,
                                  value: _selectedLeaveType,
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedLeaveType = value as LeaveType;
                                      // sele
                                    });
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),
                            Row(
                              children: [
                                SizedBox(
                                  height: 40,
                                  child: Card(
                                    child: ElevatedButton(
                                      style: ButtonStyle(
                                        backgroundColor:
                                            WidgetStateProperty.all(
                                              Colors.white,
                                            ),
                                        shape: WidgetStateProperty.all(
                                          const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(5),
                                            ),
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            MdiIcons.calendarRange,
                                            color: style.ColorObj.secondColor,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              left: 4,
                                            ),
                                            child: Text(
                                              _selectedStartDate,
                                              textAlign: TextAlign.center,
                                              style: normalMediumBalckText,
                                            ),
                                          ),
                                        ],
                                      ),
                                      onPressed: () {
                                        showDatePicker(
                                          context: context,
                                          initialDate: DateTime.now(),
                                          firstDate: DateTime(2001),
                                          lastDate: DateTime(2222),
                                        ).then((value) {
                                          setState(() {
                                            if (value != null) {
                                              _selectedStartDate =
                                                  getDateFormat(value);
                                              if (_selectedEndDate != '' &&
                                                  _selectedEndDate != '') {
                                                startDate = DateFormat(
                                                  'yyyy-MM-dd',
                                                ).parse(_selectedStartDate);
                                                endDate = DateFormat(
                                                  'yyyy-MM-dd',
                                                ).parse(_selectedEndDate);
                
                                                noOfDay =
                                                    endDate!
                                                        .difference(
                                                          startDate!,
                                                        )
                                                        .inDays +
                                                    1;
                                              }
                                            }
                                          });
                                        });
                                      },
                                    ),
                                  ),
                                  // ),
                                ),
                                !_isHalfDay
                                    ? Row(
                                        children: [
                                          SizedBox(
                                            width: 29,
                                            child: Text(
                                              AppStrings.to.tr(),
                                              textAlign: TextAlign.center,
                                              style: normalMediumGreyText,
                                            ),
                                          ),
                                          SizedBox(
                                            height: 40,
                                            child: Card(
                                              child: ElevatedButton(
                                                style: ButtonStyle(
                                                  backgroundColor:
                                                      WidgetStateProperty.all(
                                                        Colors.white,
                                                      ),
                                                  shape: WidgetStateProperty.all(
                                                    const RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                            Radius.circular(
                                                              5,
                                                            ),
                                                          ),
                                                    ),
                                                  ),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      MdiIcons.calendarRange,
                                                      color: style.ColorObj
                                                          .secondColor,
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                            left: 4,
                                                          ),
                                                      child: Text(
                                                        _selectedEndDate,
                                                        textAlign:
                                                            TextAlign.center,
                                                        style:
                                                            normalMediumBalckText,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                onPressed: () {
                                                  showDatePicker(
                                                    context: context,
                                                    initialDate:
                                                        DateTime.now(),
                                                    firstDate: DateTime(2001),
                                                    lastDate: DateTime(2222),
                                                  ).then((value) {
                                                    setState(() {
                                                      if (value != null) {
                                                        _selectedEndDate =
                                                            getDateFormat(
                                                              value,
                                                            );
                                                        if (_selectedEndDate !=
                                                                '' &&
                                                            _selectedEndDate !=
                                                                '') {
                                                          startDate =
                                                              DateFormat(
                                                                'yyyy-MM-dd',
                                                              ).parse(
                                                                _selectedStartDate,
                                                              );
                                                          endDate =
                                                              DateFormat(
                                                                'yyyy-MM-dd',
                                                              ).parse(
                                                                _selectedEndDate,
                                                              );
                                                          noOfDay =
                                                              endDate!
                                                                  .difference(
                                                                    startDate!,
                                                                  )
                                                                  .inDays +
                                                              1;
                                                        }
                                                      }
                                                    });
                                                  });
                                                },
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    // )
                                    : Row(
                                        children: [
                                          Container(
                                            margin: const EdgeInsets.only(
                                              left: 5,
                                            ),
                                            width: 150,
                                            height: 35,
                                            padding:
                                                const EdgeInsets.symmetric(
                                                  horizontal: 6,
                                                ),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  const BorderRadius.all(
                                                    Radius.circular(6),
                                                  ),
                                              border: Border.all(
                                                color: ColorObj
                                                    .dropDownBorderColor,
                                              ),
                                            ),
                                            child: DropdownButtonHideUnderline(
                                              child: DropdownButton2(
                                                dropdownFullScreen: true,
                                                dropdownDecoration:
                                                    const BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                            Radius.circular(
                                                              6,
                                                            ),
                                                          ),
                                                    ),
                                                isExpanded: true,
                                                hint: Text(
                                                  AppStrings.selectDayType.tr(),
                                                  style: normalMediumGreyText,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                items:
                                                    _addDividersAfterItemsForDayType(
                                                      dayTypeList,
                                                    ),
                                                itemHeight: 20,
                                                value: _selectedDay,
                                                onChanged: (value) {
                                                  setState(() {
                                                    _selectedDay =
                                                        value as String;
                                                    // sele
                                                  });
                                                },
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                //),
                              ],
                            ),
                            const SizedBox(height: 18),
                            Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _isHalfDay = !_isHalfDay;
                                      });
                                    },
                                    child: Row(
                                      children: [
                                        Checkbox(
                                          value: _isHalfDay,
                                          onChanged: (value) {
                                            setState(() {
                                              _isHalfDay = value!;
                                            });
                                          },
                                        ),
                                        Text(
                                          '${AppStrings.halfDay.tr()}',
                                          style: normalMediumGreyText,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                !_isHalfDay
                                    ? Expanded(
                                        flex: 4,
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                            left: 5,
                                          ),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                ///flex: 2,
                                                child: Text(
                                                  '${AppStrings.duration.tr()} :',
                                                  style: normalMediumGreyText,
                                                ),
                                              ),
                                              Expanded(
                                                // flex: 2,
                                                child: Text(
                                                  '$noOfDay days',
                                                  style:
                                                      normalMediumBalckText,
                                                  textAlign: TextAlign.left,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    : Container(),
                              ],
                            ),
                            const SizedBox(height: 18),
                
                            Card(
                              color: Colors.grey[100],
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  top: 8.0,
                                  left: 7,
                                  bottom: 8.0,
                                  right: 8.0,
                                ),
                                child: TextField(
                                  controller: _reasonController,
                                  cursorColor: Colors.grey,
                                  maxLines: 6,
                                  style: normalMediumBalckText,
                                  decoration: InputDecoration.collapsed(
                                    hintText: AppStrings.reason.tr(),
                                    hintStyle: normalMediumGreyText,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),
                            SizedBox(
                              height: 45,
                              width: double.infinity,
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
                                onPressed: _submitRequest,
                                child: Text(
                                  AppStrings.submitRequest.tr(),
                                  style: normalLargeWhiteText,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                _openFileExplorer();
                              },
                              child: Container(
                                padding: const EdgeInsets.only(
                                  left: 5,
                                  top: 10,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      MdiIcons.attachment,
                                      color: style.ColorObj.secondColor,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      AppStrings.attachmentForMedicalLeave.tr(),
                                      style: style.normalMediumBalckText,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 10,
                              ),
                              child: Text(path),
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
        ),
      ),
    );
  }

  _submitRequest() async {
    log('submit-------$_selectedDay');

    bool checkInternet = await InternetConnectionChecker.instance.hasConnection;
    if (checkInternet == false) {
      // ignore: use_build_context_synchronously
      showDialog(context: context, builder: (_) => CustomEventDialog());
      return;
    }

    if (_isHalfDay == true) {
      if (_selectedDay == '' || _selectedDay == null) {
        toast!.showToast(
          child: Widgets().getWarningToast(AppStrings.pleaseSelectDayType.tr()),
          gravity: ToastGravity.BOTTOM,
          toastDuration: const Duration(seconds: 2),
        );
        return;
      }
    }
    if (_selectedLeaveType == null) {
      toast!.showToast(
        child: Widgets().getWarningToast(AppStrings.pleaseSelectLeaveType.tr()),
        gravity: ToastGravity.BOTTOM,
        toastDuration: const Duration(seconds: 2),
      );
      return;
    }

    if (_reasonController.text == '') {
      toast!.showToast(
        child: Widgets().getWarningToast(AppStrings.pleaseEnterReason.tr()),
        gravity: ToastGravity.BOTTOM,
        toastDuration: const Duration(seconds: 2),
      );
      return;
    }

    if (noOfDay! <= 0) {
      toast!.showToast(
        child: Widgets().getWarningToast(AppStrings.pleaseSelectValidDate.tr()),
        gravity: ToastGravity.BOTTOM,
        toastDuration: const Duration(seconds: 2),
      );
      return;
    }

    employee = await employeeDao.getSingleEmployeeById(userId!);

    String holidayType, requestDateFromPeriod;
    if (_selectedLeaveType!.unpaid == 1) {
      holidayType = 'employee';
    } else {
      holidayType = _selectedLeaveType!.holiday_type!;
    }
    if (!_isHalfDay) {
      requestDateFromPeriod = 'am';
    } else {
      if (_selectedDay.toString() == 'Morning') {
        requestDateFromPeriod = 'am';
      } else {
        requestDateFromPeriod = 'pm';
      }
    }

    Leave leave = Leave(
      0,
      _reasonController.text,
      'confirm',
      userId,
      _selectedLeaveType!.leave_type_id,
      _selectedLeaveType!.name,
      employee!.employee_id,
      employee!.department_id!,
      todayDate,
      _selectedStartDate,
      _selectedEndDate,
      noOfDay,
      _selectedStartDate,
      _selectedEndDate,
      3,
      requestDateFromPeriod,
      _isHalfDay == true ? 1 : 0,
      holidayType,
      0,
      0,
      '',
      '',
      '',
      employee!.employee_name,
      '',
      '',
      _reasonController.text.toString(),
      0,
      '',
      base64String,
      '',
      monthName,
      year,
    );
    EasyLoading.show(status: AppStrings.submittingPleaseWait.tr());

    var createResult = await leaveApi.createLeaveRequest(leave);

    log('createResult------$createResult');

    if (createResult['result'] == 'fail') {
      // ignore: prefer_typing_uninitialized_variables
      var resultMessage;
      if (createResult['message'] == '') {
        resultMessage = 'Fail';
      } else {
        resultMessage = createResult['message'];
        if (resultMessage == 'Invalid cookie.') {
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
          // timer = Timer.periodic(Duration(seconds: 3), (timer) {
          // ignore: use_build_context_synchronously
          Navigator.of(_scaffoldCtx).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (BuildContext context) {
                return const LoginScreen();
              },
            ),
            (route) => false,
          );

          //});
          return;
        }
      }
      log('resultMessage---------$resultMessage');
      EasyLoading.dismiss();
      toast!.showToast(
        child: Widgets().getErrorToast(resultMessage.tr()),
        gravity: ToastGravity.BOTTOM,
        toastDuration: const Duration(seconds: 5),
      );
      return;
    }

    EasyLoading.dismiss();

    toast!.showToast(
      child: Widgets().getSuccessToast(AppStrings.requestSuccessfullyCreated.tr()),
      gravity: ToastGravity.BOTTOM,
      toastDuration: const Duration(seconds: 2),
    );

    // ignore: use_build_context_synchronously
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (conext) {
          return const LeaveHistoryListScreen();
        },
      ),
    );
  }
}
