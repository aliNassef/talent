import 'dart:developer';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talent/presentation/screens/base.account/welcome_screen.dart';
import 'package:talent/presentation/screens/employee/employee_detail.dart';
import 'package:talent/utility/style/theme.dart' as Style;
import '../presentation/screens/attendance/attendance_screen.dart';
import '../presentation/screens/base.account/login.dart';
import '../presentation/screens/dashboard/dashboard_main.dart';
import '../presentation/screens/expense/expense_request_history_list_page.dart';
import '../presentation/screens/leave/leave_dashboard.dart';
import '../presentation/screens/payslip/pay_slip_list_page.dart';

class Root extends StatelessWidget {
  const Root({super.key});
  void data() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    final String? url = pref.getString('url');

    log("url :$url");
  }

  @override
  Widget build(BuildContext context) {
    String fontFamily = context.locale.languageCode == 'ar' ? 'Cairo' : 'DINNextLTArabic';
    return MaterialApp(
      key: ValueKey(context.locale),
      title: "SANID",
      builder: EasyLoading.init(),
      supportedLocales: context.supportedLocales,
      localizationsDelegates: context.localizationDelegates,
      locale: context.locale,
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/dashboard': (context) => const HomeScreen(),
        '/employee': (context) => const EmployeeDetailScreen(),
        '/attendance': (context) => const AttendanceScreen(),
        '/leave': (context) => const LeaveDashBoardScreen(),
        '/payslip': (context) => const PaySlipListScreen(),
        '/expense': (context) => const ExpenseListPage(),
      },
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: fontFamily,
        primaryColor: Style.ColorObj.mainColor,
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: Style.ColorObj.mainColor,
        ),
        iconTheme: const IconThemeData(color: Style.ColorObj.mainColor),
      ),
    );
  }
}
