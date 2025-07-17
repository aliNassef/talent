import 'dart:async';
import 'dart:developer';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:talent/app/config.dart';
import 'package:talent/data/api/login_api.dart';
import 'package:talent/presentation/screens/base.account/waiting_screen.dart';
import 'package:talent/utility/share/app_strings.dart';
import 'package:talent/utility/style/theme.dart' as style;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/helper/constant.dart';
import '../../../utility/share/share_component.dart';
import '../../../utility/utils/alertText.dart';
import '../../../utility/utils/size_config.dart';
import '../../widgets/custom_event_dialog.dart';
import '../../widgets/widgets.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../dashboard/dashboard_main.dart';
//import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // SharedPreferences? _prefs;
  bool _obscureText = true;
  bool _isInvalid = false;
  final _formKey = GlobalKey<FormState>();
  TextEditingController urlController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final FocusNode _nameF = FocusNode();
  final FocusNode _passF = FocusNode();
  var _database = '';
  // List<DropdownMenuItem<String>> _dbMenuList = [];
  FToast? toast;
  bool? isLogin;
  bool? loginned = false;
  var loginApi = loginAPI();
  late Timer timer;
  var deviceState = '';
  final _dbList = <Map<String, dynamic>>[];
  // late DeviceInfoPlugin deviceInfoPlugin;
  // late AndroidDeviceInfo androidDeviceInfo;
  late SharedPreferences pref;
  StreamSubscription? subscription;
  bool hasConnection = true;

  bool enteredUrl = false;

  bool showDatabaseDropdown = false;

  bool ckeckedUrl = false;
  var url;
  late AndroidDeviceInfo deviceStatus;

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

    initiate();
  }

  initiate() async {
    pref = await SharedPreferences.getInstance();
    // deviceInfoPlugin = DeviceInfoPlugin();
    // androidDeviceInfo = await deviceInfoPlugin.androidInfo;
    var shareComponent = ShareComponentClass();
    deviceStatus = await shareComponent.readDeviceId();
    // url = Config.url;
    // urlController.text = url;
    // await pref.setString('url', url);
    var username = pref.getString('username');

    var userPw = pref.getString('user_pw');
    if (username != null && userPw != null) {
      usernameController.text = username;
      passwordController.text = userPw;
    }
    subscription = Connectivity().onConnectivityChanged.listen((
      List<ConnectivityResult> result,
    ) async {
      // Got a new connectivity status!
      if (result.contains(ConnectivityResult.none)) {
        toast!.showToast(
          child: Widgets().noInternetToast(MessageAndAlertText.noInternet),
          gravity: ToastGravity.BOTTOM,
          toastDuration: const Duration(seconds: 3),
        );
        hasConnection = false;
      } else {
        var noInternet = pref.getString('noInternet');

        if (noInternet == 'true') {
          toast!.showToast(
            child: Widgets().onlineToast(MessageAndAlertText.internetRestore),
            gravity: ToastGravity.BOTTOM,
            toastDuration: const Duration(seconds: 3),
          );
        }

        pref.setString('noInternet', 'false');
        hasConnection = true;
      }

      setState(() {});
    });
  }

  @override
  void dispose() {
    timer.cancel();
    subscription?.cancel();
    super.dispose();
  }

  Future<void> login() async {
    bool checkInternet = await InternetConnectionChecker.instance.hasConnection;
    if (checkInternet == false) {
      // ignore: use_build_context_synchronously
      showDialog(context: context, builder: (_) => CustomEventDialog());
      return;
    }

    // ignore: prefer_typing_uninitialized_variables
    var loginResult;

    EasyLoading.show(status: 'signing in...........');
    loginResult = await loginApi.login(
      usernameController.text.toString(),
      passwordController.text.toString(),
      deviceStatus.id,
      deviceStatus.id,
      deviceStatus.device,
      deviceStatus.model,
    );

    EasyLoading.dismiss();

    log('loginResult----------$loginResult');
    if (loginResult == 'success') {
      pref.setString('username', usernameController.text.toString());
      pref.setString('user_pw', passwordController.text.toString());
      toast!.showToast(
        child: Widgets().getSuccessToast(MessageAndAlertText.loginSuccessful),
        gravity: ToastGravity.BOTTOM,
        toastDuration: const Duration(seconds: 2),
      );
      var loginned = pref.getBool('loginned');
      log('isLoginned-------$loginned ');
      if (loginned != null && loginned == true) {
        Navigator.pushReplacement(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        pref.setString('waitingStage', 'true');
        pref.setBool(Constant.WAITING_APPROVE, true);
        pref.setBool(Constant.IS_APPROVED, false);
        pref.setBool(Constant.IS_LOGIN, false);
        timer = Timer(const Duration(milliseconds: 1), () async {
          timer.cancel();

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const WaitingScreen()),
          );
        });
      }
    } else {
      toast!.showToast(
        child: Widgets().getErrorToast(loginResult),
        gravity: ToastGravity.BOTTOM,
        toastDuration: const Duration(seconds: 3),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            color: style.ColorObj.layoutColor,
            child: Column(
              children: <Widget>[
                const SizedBox(height: 85),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: const Image(
                    width: 80,
                    height: 80,
                    //  color: Style.ColorObj.loginBackgroundColor,
                    image: AssetImage('assets/logos/ic_hrms.png'),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  AppStrings.welcome,
                  style: const TextStyle(
                    color: style.ColorObj.loginBackgroundColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 25.0,
                  ),
                ),
                const SizedBox(height: 15),
                Form(
                  key: _formKey,
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    margin: const EdgeInsets.all(30.0),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          showDatabaseDropdown
                              ? Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  height: 55,
                                  child: DropdownButtonFormField(
                                    items: [
                                      for (int i = 0; i < _dbList.length; i++)
                                        DropdownMenuItem<String>(
                                          // value: '${_dbList[i]['value']}',
                                          value: _dbList[i]['value'],
                                          child: Text(
                                            '${_dbList[i]['value']}',
                                            style: TextStyle(
                                              fontSize: 15,
                                              color: Colors.grey[800],
                                            ),
                                          ),
                                        ),
                                    ],
                                    isExpanded: true,
                                    isDense: true,
                                    decoration: InputDecoration(
                                      border: const OutlineInputBorder(),
                                      prefixIcon: Icon(MdiIcons.database),
                                    ),
                                    hint: const Text(
                                      'Select Database',
                                      style: TextStyle(fontSize: 15),
                                    ),
                                    value: _database,
                                    onChanged: (newValue) async {
                                      log('onChange--------$newValue');
                                      _database = newValue.toString();
                                      await pref.setString(
                                        'database',
                                        _database,
                                      );
                                      enteredUrl = false;
                                      setState(() {});
                                    },
                                  ),
                                )
                              : const Text(''),
                          SizedBox(
                            height: _isInvalid ? 70 : 50,
                            child: TextFormField(
                              focusNode: _nameF,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return AppStrings.pleaseEnterUsername;
                                }
                                return null;
                              },
                              controller: usernameController,
                              cursorColor: Colors.grey,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.person),
                                hintText: AppStrings.username,
                                border: const OutlineInputBorder(),
                                contentPadding: const EdgeInsets.only(
                                  bottom: 25,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: _isInvalid ? 70 : 50,
                            child: TextFormField(
                              focusNode: _passF,
                              cursorColor: Colors.grey,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return AppStrings.pleaseEnterPassword;
                                }
                                return null;
                              },
                              controller: passwordController,
                              obscureText: _obscureText,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.lock),
                                hintText: AppStrings.password,
                                suffixIcon: IconButton(
                                  icon: _obscureText
                                      ? const Icon(Icons.remove_red_eye)
                                      : const FaIcon(
                                          FontAwesomeIcons.solidEyeSlash,
                                          size: 18,
                                        ),
                                  onPressed: () {
                                    setState(() {
                                      _obscureText = !_obscureText;
                                    });
                                  },
                                ),
                                border: const OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          InkWell(
                            onTap: () async {
                              setState(() {});
                              log('onPressed--------------');
                              await pref.clear();
                              // enteredUrl = true;
                              // url = urlController.text.toString();
                              await pref.setString('database', Config.database);
                              await pref.setString('url', Config.url);
                              // //showDatabaseDropdown = true;
                              if (_formKey.currentState!.validate()) {
                                log('_formKey.currentState------------');
                                setState(() {
                                  _isInvalid = false;
                                });
                                login();
                              } else {
                                setState(() {
                                  _isInvalid = true;
                                });
                              }
                            },
                            child: Container(
                              height: 45,
                              width: MediaQuery.of(context).size.width,
                              alignment: Alignment.center,
                              padding: const EdgeInsets.fromLTRB(
                                10.0,
                                6.0,
                                10.0,
                                6.0,
                              ),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color.fromARGB(255, 0, 117, 133),
                                    Colors.cyan,
                                    Color.fromARGB(255, 0, 117, 133),
                                    Color.fromARGB(255, 101, 192, 210),
                                    Color.fromARGB(255, 0, 117, 133),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              child: Text(
                                AppStrings.login,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.0,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
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
}
