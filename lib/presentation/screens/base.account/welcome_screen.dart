import 'dart:async';
import 'dart:developer';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:talent/presentation/screens/base.account/login.dart';
import 'package:talent/presentation/screens/base.account/reject_screen.dart';
import 'package:talent/presentation/screens/base.account/waiting_screen.dart';
import 'package:talent/presentation/screens/dashboard/dashboard_main.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:talent/utility/share/app_strings.dart';
import 'package:talent/utility/style/theme.dart' as style;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/api/login_api.dart';
import '../../../data/helper/constant.dart';
import '../../../utility/share/share_component.dart';
import '../../../utility/utils/alertText.dart';
import '../../../utility/utils/size_config.dart';
import '../../widgets/custom_event_dialog.dart';
import '../../widgets/widgets.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  // var ;
  late BuildContext _scaffoldCtx;
  Timer? timer;
  var deviceState = '';
  var loginApi = loginAPI();
  late SharedPreferences pref;
  FToast? toast;
  StreamSubscription? subscription;
  bool hasConnection = true;
  // ignore: prefer_typing_uninitialized_variables
  var waitingStage;

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
    loadData();
  }

  @override
  void dispose() {
    timer?.cancel();
    subscription?.cancel();
    super.dispose();
  }

  loadData() async {
    pref = await SharedPreferences.getInstance();
    await pref.setBool(
      'welcomePage',
      true,
    ); //for internet restore and checkactivation
    subscription = Connectivity().onConnectivityChanged.listen((
      List<ConnectivityResult> result,
    ) async {
      // Got a new connectivity status!
      log('connection------$result');
      if (result.contains(ConnectivityResult.none)) {
        pref.setString('noInternet', 'true');
        toast!.showToast(
          child: Widgets().noInternetToast(MessageAndAlertText.noInternet),
          gravity: ToastGravity.BOTTOM,
          toastDuration: const Duration(seconds: 3),
        );
        hasConnection = false;
      } else {
        log('else-------');
        var noInternet = pref.getString('noInternet');
        log('noInternet--------$noInternet');

        if (noInternet == 'true') {
          toast!.showToast(
            child: Widgets().onlineToast(MessageAndAlertText.internetRestore),
            gravity: ToastGravity.BOTTOM,
            toastDuration: const Duration(seconds: 3),
          );
          var isWelcomePage = pref.getBool('welcomePage');
          if (isWelcomePage == true) await gotoNext();
        }

        pref.setString('noInternet', 'false');
        hasConnection = true;
      }
    });
    await gotoNext();
  }

  gotoNext() async {
    log('gotoNext-----------');
    bool checkInternet = await InternetConnectionChecker.instance.hasConnection;
    log('checkInternet--------$checkInternet');
    if (checkInternet == false) {
      if (!mounted) return;
      showDialog(context: context, builder: (_) => const CustomEventDialog());
      return;
    }

    timer = Timer(const Duration(milliseconds: 300), () async {
      String? token = pref.getString('jwt_token');

      waitingStage = pref.getString('waitingStage');
      log('waitingStage-----$waitingStage');

      if (waitingStage == null || waitingStage == '') {
        log('waitingStage 1');
        await pref.setString('waitingStage', 'false');
      }

      if (token.toString() != "null" && token != null) {
        log('waitingStage 2');
        if (waitingStage == 'true') {
          dispose();
          if (!mounted) return;
          Navigator.of(_scaffoldCtx).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (BuildContext context) {
                return const WaitingScreen();
              },
            ),
            (route) => false,
          );
        } else {
          if (checkInternet == false) {
            if (!mounted) return;
            showDialog(
              context: context,
              builder: (_) => const CustomEventDialog(),
            );
            return;
          }
          checkDeviceActivation();
        }
      } else {
        if (!mounted) return;
        Navigator.of(_scaffoldCtx).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (BuildContext context) {
              return const LoginScreen();
            },
          ),
          (route) => false,
        );
      }
    });
    await pref.setBool(
      'welcomePage',
      false,
    ); //for internet restore and checkactivation
  }

  Future<void> checkDeviceActivation() async {
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
        child: Widgets().getErrorToast(
          AppStrings.sessionExpiredPleaseLoginAgain.tr(),
        ),
        gravity: ToastGravity.BOTTOM,
        toastDuration: const Duration(seconds: 3),
      );
      await pref.setString('jwt_token', "null");
      await Future.delayed(const Duration(seconds: 4));
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
    SizeConfig().init(context);
    _scaffoldCtx = context;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Image(
              width: 70,
              height: 70,
              image: AssetImage('assets/logos/Logo-Icon.png'),
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 20),
            JumpingDotsProgressIndicator(
              numberOfDots: 5,
              fontSize: 40,
              color: style.ColorObj.mainColor,
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
