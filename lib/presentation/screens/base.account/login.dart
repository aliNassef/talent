import 'dart:async';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:talent/data/api/login_api.dart';
import 'package:talent/presentation/screens/base.account/waiting_screen.dart';
import 'package:talent/utility/style/theme.dart' as Style;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../app/config.dart';
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
  final String _versionNo = "";
  final _formKey = GlobalKey<FormState>();
  TextEditingController urlController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final _focusNode = FocusNode();
  final FocusNode _urlF = FocusNode();
  final FocusNode _nameF = FocusNode();
  final FocusNode _passF = FocusNode();
  var _database = '';
  // List<DropdownMenuItem<String>> _dbMenuList = [];
  FToast? toast;
  bool? isLogin;
  final bool _showLoginForm = false;
  bool? loginned = false;
  var loginApi = loginAPI();
  late Timer timer;
  var deviceState = '';
  final _dbList = <Map<String, dynamic>>[];
  final _listDbSuccessful = false;
  // late DeviceInfoPlugin deviceInfoPlugin;
  // late AndroidDeviceInfo androidDeviceInfo;
  var pref;
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
      ..maskColor = Colors.grey.withOpacity(0.5)
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
    var username = await pref.getString('username');

    var userPw = await pref.getString('user_pw');
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
    super.dispose();
    timer.cancel();
  }

  Future<void> login() async {
    bool checkInternet = await InternetConnectionChecker.instance.hasConnection;
    if (checkInternet == false) {
      showDialog(context: context, builder: (_) => CustomEventDialog());
      return;
    }

    // if (_database == '' || _database == null) {
    //   toast!.showToast(
    //     child: Widgets().getWarningToast(MessageAndAlertText.enterDatabase),
    //     gravity: ToastGravity.BOTTOM,
    //     toastDuration: Duration(seconds: 2),
    //   );
    //   return;
    // }
    var userId;

    var loginResult;

    EasyLoading.show(status: 'signing in...........');
    // log("ali nassef ${deviceStatus.androidId.toString()}");
    loginResult = await loginApi.login(
      usernameController.text.toString(),
      passwordController.text.toString(),
      deviceStatus.id,
      deviceStatus.id,
      deviceStatus.device,
      deviceStatus.model,
    );

    EasyLoading.dismiss();

    print('loginResult----------$loginResult');
    if (loginResult == 'success') {
      pref.setString('username', usernameController.text.toString());
      pref.setString('user_pw', passwordController.text.toString());
      toast!.showToast(
        child: Widgets().getSuccessToast(MessageAndAlertText.loginSuccessful),
        gravity: ToastGravity.BOTTOM,
        toastDuration: const Duration(seconds: 2),
      );
      var loginned = await pref.getBool('loginned');
      print('isLoginned-------$loginned ');
      if (loginned != null && loginned == true) {
        Navigator.pushReplacement(
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
            color: Style.ColorObj.layoutColor,
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
                const Text(
                  "Welcome",
                  style: TextStyle(
                    color: Style.ColorObj.loginBackgroundColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 25.0,
                  ),
                ),
                const SizedBox(height: 15),
                // Text(
                //   // "Sign in to continue",
                //   'signIn'.tr(),
                //   style: TextStyle(
                //       color: Style.ColorObj.text_color_dark_grey, fontSize: 15),
                // ),
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
                          // Container(
                          //   margin: EdgeInsets.only(
                          //       bottom: showDatabaseDropdown ? 12 : 0),
                          //   height: _isInvalid ? 70 : 50,
                          //   child: TextFormField(
                          //     focusNode: _urlF,
                          //     onFieldSubmitted: (value) async {
                          //       if (value != null && value != '') {
                          //         bool checkInternet =
                          //             await InternetConnectionChecker()
                          //                 .hasConnection;
                          //         if (checkInternet == false) {
                          //           showDialog(
                          //               context: context,
                          //               builder: (_) => CustomEventDialog());
                          //           return;
                          //         }
                          //         enteredUrl = true;
                          //         //url = urlController.text.toString();
                          //         await pref.setString('url', url);
                          //         //showDatabaseDropdown = true;

                          //          await pref!.setString('database', 'scofield0007-hr-mobile-app-main-12633087');

                          //        // await getDatabaseList();
                          //         setState(() {});
                          //       }
                          //     },
                          //     validator: (value) {
                          //       if (value!.isEmpty) {
                          //         return 'Please enter url';
                          //       }
                          //       return null;
                          //     },
                          //     controller: urlController,
                          //     cursorColor: Colors.grey,
                          //     decoration: InputDecoration(
                          //         suffixIcon: enteredUrl
                          //             ? Container(
                          //                 padding: EdgeInsets.only(
                          //                     left: 25,
                          //                     right: 25,
                          //                     top: 7,
                          //                     bottom: 7),
                          //                 child: CircularProgressIndicator(
                          //                   strokeWidth: 2,
                          //                   color: Colors.blue,
                          //                 ))
                          //             : ckeckedUrl
                          //                 ? Padding(
                          //                     padding: const EdgeInsets.only(
                          //                         right: 10.0),
                          //                     child: Icon(
                          //                       Icons.check,
                          //                       size: 35,
                          //                       color: Colors.green,
                          //                     ),
                          //                   )
                          //                 : Text(''),
                          //         prefixIcon: Icon(MdiIcons.earth),
                          //         hintText: 'url',
                          //         border: OutlineInputBorder(),
                          //         contentPadding: EdgeInsets.only(bottom: 25)),
                          //   ),
                          // ),
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
                                      print('onChange--------$newValue');
                                      _database = newValue.toString();
                                      await pref!.setString(
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
                                  return 'Please enter username';
                                }
                                return null;
                              },
                              controller: usernameController,
                              cursorColor: Colors.grey,
                              decoration: const InputDecoration(
                                prefixIcon: Icon(Icons.person),
                                hintText: 'username',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.only(bottom: 25),
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
                                  return 'Please enter password';
                                }
                                return null;
                              },
                              controller: passwordController,
                              obscureText: _obscureText,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.lock),
                                hintText: 'password',
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
                                /*contentPadding: EdgeInsets.only(
                                                                    bottom: 25
                                                                )*/
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // ElevatedButton(
                          //   style: ElevatedButton.styleFrom(
                          //     padding: const EdgeInsets.all(0.0),
                          //     elevation: 5,
                          //   ),
                          //  onPressed: () async {
                          //     print('onPressed--------------');

                          //     // enteredUrl = true;
                          //     // url = urlController.text.toString();
                          //     await pref.setString('url', url);
                          //     //showDatabaseDropdown = true;

                          //     await pref!.setString('database',
                          //         'scofield0007-hr-mobile-app-main-12633087');

                          //     if (_formKey.currentState!.validate()) {
                          //       print('_formKey.currentState------------');
                          //       setState(() {
                          //         _isInvalid = false;
                          //       });
                          //       login();
                          //     } else {
                          //       setState(() {
                          //         _isInvalid = true;
                          //       });
                          //     }
                          //   },
                          //   child: Ink(
                          //     decoration: BoxDecoration(
                          //       gradient: LinearGradient(
                          //           colors: [Colors.blue, Colors.cyan]),
                          //     ),
                          //     child: Container(
                          //       padding: const EdgeInsets.all(10),
                          //       constraints: const BoxConstraints(minWidth: 88.0),
                          //       child:
                          //           const Text('Start Your ID', textAlign: TextAlign.center),
                          //     ),
                          //   ),
                          // ),
                          InkWell(
                            onTap: () async {
                              setState(() {});
                              print('onPressed--------------');
                              await pref.clear();
                              // enteredUrl = true;
                              // url = urlController.text.toString();
                              await pref.setString(
                                'database',
                                'odoozaly-sanid-stg-21897440',
                              );
                              await pref.setString(
                                'url',
                                'https://sanidstg.odoo.com/',
                              );
                              // //showDatabaseDropdown = true;

                              if (_formKey.currentState!.validate()) {
                                print('_formKey.currentState------------');
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
                              child: const Text(
                                'Start Your ID',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.0,
                                ),
                              ),
                            ),
                          ),

                          // ElevatedButton(
                          //   style: ElevatedButton.styleFrom(
                          //     shape: RoundedRectangleBorder(
                          //       borderRadius: BorderRadius.circular(20),
                          //     ),
                          //     // primary: Style.ColorObj
                          //     //     .loginBackgroundColor, // Background color

                          //     // onPrimary: Colors.white,
                          //     // onSurface: Colors.blue,
                          //   ),
                          //   // shape: RoundedRectangleBorder(
                          //   //   borderRadius: BorderRadius.circular(5),
                          //   // ),
                          //   // color: Style.ColorObj.loginBackgroundColor,
                          //   child: Ink(
                          //     decoration: BoxDecoration(
                          //       gradient: LinearGradient(
                          //           colors: [Colors.cyan, Colors.white]),
                          //     ),
                          //     child: Container(
                          //       width: MediaQuery.of(context).size.width - 20,
                          //       height: 40,
                          //       child: Text(
                          //         "Start your ID",
                          //         style: TextStyle(
                          //           color: Colors.white,
                          //           fontSize: 16.0,
                          //         ),
                          //       ),
                          //     ),
                          //   ),
                          //   onPressed: () async {
                          //     print('onPressed--------------');

                          //     // enteredUrl = true;
                          //     // url = urlController.text.toString();
                          //     await pref.setString('url', url);
                          //     //showDatabaseDropdown = true;

                          //     await pref!.setString('database',
                          //         'scofield0007-hr-mobile-app-main-12633087');

                          //     if (_formKey.currentState!.validate()) {
                          //       print('_formKey.currentState------------');
                          //       setState(() {
                          //         _isInvalid = false;
                          //       });
                          //       login();
                          //     } else {
                          //       setState(() {
                          //         _isInvalid = true;
                          //       });
                          //     }
                          //   },
                          // )
                        ],
                      ),
                    ),
                  ),
                ),
                // Expanded(
                //     child: Padding(
                //   padding: EdgeInsets.all(10),
                //   child: Align(
                //     alignment: Alignment.bottomCenter,
                //     child: Row(
                //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //       children: <Widget>[
                //         Text(
                //           "Powered by Asia Matrix",
                //           style: TextStyle(
                //               color: Style.ColorObj.text_color_light_grey,
                //               fontSize: 15.0,
                //               fontWeight: FontWeight.bold),
                //         ),
                //         Text(
                //           'Version : 1.1',
                //           style: TextStyle(
                //               color: Style.ColorObj.text_color_light_grey,
                //               fontSize: 15.0,
                //               fontWeight: FontWeight.bold),
                //         ),
                //       ],
                //     ),
                //   ),
                // ))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
