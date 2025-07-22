import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:talent/data/api/employee_api.dart';
import 'package:talent/utility/style/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/database/dao/employee_dao.dart';
import '../../../data/models/employee/employee.dart';
import '../../../utility/share/app_strings.dart';
import '../../../utility/utils/size_config.dart';
import '../../widgets/custom_event_dialog.dart';
// import '../../widgets/drawer_body.dart';
// import '../../widgets/drawer_widget.dart';
import '../dashboard/dashboard_main.dart';

class EmployeeDetailScreen extends StatefulWidget {
  const EmployeeDetailScreen({super.key});

  @override
  EmployeeDetailScreenState createState() => EmployeeDetailScreenState();
}

class EmployeeDetailScreenState extends State<EmployeeDetailScreen> {
  // ignore: prefer_typing_uninitialized_variables
  var pref;
  int? userId;
  // ignore: prefer_typing_uninitialized_variables
  var userLevel;
  Uint8List? bytes;
  var employeeDao = EmployeeDao();
  Employee? employee;
  var empApi = EmployeeAPI();
  // ignore: prefer_typing_uninitialized_variables
  var password;
  bool createPassword = false;
  bool fetchEmpUpdateData = false;
  // ignore: prefer_typing_uninitialized_variables
  var uid;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  loadData() async {
    pref = await SharedPreferences.getInstance();

    uid = await pref.getInt('uid');
    employee = await employeeDao.getSingleEmployeeById(uid);

    userId = await pref.getInt('uid');
    userLevel = await pref.getString('user_level');

    password = await pref.getString('password');
    if (password == null || password == '') {
      createPassword = true;
    }

    if (employee!.avatar != '') {
      bytes = base64.decode("${employee!.avatar}");
    } else {
      bytes = null;
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
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
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
        body: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
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
                backgroundColor: ColorObj.mainColor,
                expandedHeight: 200.0,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        employee != null
                            ? employee!.employee_name.toString()
                            : '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16.0,
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
                          EasyLoading.show(
                            status: AppStrings.fetchingUpdateData,
                          );
                          var employeeApi = EmployeeAPI();
                          await employeeApi.getEmployeeList();
                          employee = await employeeDao.getSingleEmployeeById(
                            uid,
                          );

                          EasyLoading.dismiss();
                          setState(() {});
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 3, right: 5),
                          child: const Icon(
                            Icons.refresh,
                            color: Colors.green,
                            size: 25,
                          ),
                        ),
                      ),
                    ],
                  ),
                  background: bytes != null
                      ? Image.memory(bytes!, fit: BoxFit.cover)
                      : const Image(
                          image: AssetImage('assets/imgs/default_avator.png'),
                          fit: BoxFit.cover,
                        ),
                ),
              ),
            ];
          },
          body: ListView(
            children: <Widget>[
              ListTile(
                dense: true,

                visualDensity: const VisualDensity(vertical: -2), // to compact
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      employee != null ? employee!.job_name.toString() : '',
                      textAlign: TextAlign.left,
                      style: normalLargeGreyText,
                    ),
                  ],
                ),
              ),
              const Divider(height: 2, thickness: 1.5),
              ListTile(
                leading: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      MdiIcons.clipboardAccount,
                      color: const Color(0xff208d9c),
                    ),
                  ],
                ),
                title: Text(AppStrings.registrationNumber, style: normalSmallGreyText),
                subtitle: Text(
                  employee != null ? employee!.employee_code.toString() : '',
                  style: normalMediumBalckText,
                ),
              ),
              ListTile(
                leading: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      MdiIcons.genderMaleFemale,
                      color: const Color(0xff208d9c),
                    ),
                  ],
                ),
                title: Text(AppStrings.gender, style: normalSmallGreyText),
                subtitle: Text(
                  employee != null ? employee!.gender.toString() : '',
                  style: normalMediumBalckText,
                ),
              ),
              ListTile(
                leading: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(MdiIcons.cakeVariant, color: const Color(0xff208d9c)),
                  ],
                ),
                title: Text(AppStrings.birthday, style: normalSmallGreyText),
                subtitle: Text(
                  employee != null ? employee!.birthday.toString() : '',
                  style: normalMediumBalckText,
                ),
              ),
              ListTile(
                leading: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(MdiIcons.phone, color: const Color(0xff208d9c)),
                  ],
                ),
                title: Text(AppStrings.work, style: normalSmallGreyText),
                subtitle: Text(
                  employee != null ? employee!.work_phone! : '',
                  style: normalMediumBalckText,
                ),
                // trailing: Icon(MdiIcons.messageBulleted,
                //     color: Color(0xff208d9c)),
              ),
              ListTile(
                leading: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(MdiIcons.phone, color: const Color(0xff208d9c)),
                  ],
                ),
                title: Text(AppStrings.home, style: normalSmallGreyText),
                subtitle: Text(
                  employee != null ? employee!.mobile_phone! : '',
                  style: normalMediumBalckText,
                ),
              ),
              ListTile(
                leading: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(MdiIcons.email, color: const Color(0xff208d9c)),
                  ],
                ),
                title: Text(AppStrings.workEmail, style: normalSmallGreyText),
                subtitle: Text(
                  employee != null ? employee!.email.toString() : '',
                  style: normalMediumBalckText,
                ),
              ),
            ],
          ),
        ),
        //  drawer: drawerWidget(context, employee, odoo, createPassword),
      ),
    );
  }
}
