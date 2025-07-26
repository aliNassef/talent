import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:talent/utility/share/app_strings.dart';
import 'package:talent/utility/utils/extension.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/api/expense_api.dart';
// import '../../../data/database/Dao/expense/expense_dao.dart';
import '../../../data/database/dao/expense/analytic_account_dao.dart';
import '../../../data/database/dao/expense/expense_product_dao.dart';
import '../../../data/database/dao/expense/expense_tax_dao.dart';
import '../../../data/models/expense/analytic_account/analytic_account.dart';
import '../../../data/models/expense/expense/expense.dart';
import '../../../data/models/expense/expense_product/expense_product.dart';
import '../../../data/models/expense/expense_tax/expense_tax.dart';
import '../../../utility/style/theme.dart';
import '../../../utility/utils/date_util.dart';
import '../../widgets/custom_event_dialog.dart';
import '../../widgets/widgets.dart';
import '../base.account/login.dart';
import 'expense_request_history_list_page.dart';

class ExpenseEntryPage extends StatefulWidget {
  const ExpenseEntryPage({super.key});

  @override
  State<ExpenseEntryPage> createState() => _ExpenseEntryPageState();
}

class _ExpenseEntryPageState extends State<ExpenseEntryPage> {
  var referenceNo = '';
  late BuildContext _scaffoldCtx;
  var billRefController = TextEditingController();
  var totalAmountController = TextEditingController();
  var descController = TextEditingController();
  var noteController = TextEditingController();
  // ignore: prefer_typing_uninitialized_variables
  var pref;
  // ignore: prefer_typing_uninitialized_variables
  var employeeName;
  List<ExpenseProduct> expenseProductList = [];
  List<AnalyticAccount> analyticAccountList = [];
  List<ExpenseTax> expenseTaxList = [];
  var expensePeoductDao = ExpenseProductDao();
  var expenseTaxDao = ExpenseTaxDao();
  int _groupValue = 0;
  bool empSelect = true;
  bool companySelect = false;
  var photos = <File>[];
  var images = <Uint8List>[];
  List<String> base64ImageList = [];
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  String base64Image = '';
  // ignore: prefer_typing_uninitialized_variables
  var mode;
  bool updateDenied = false;
  // var expenseDao = ExpenseDao();
  FToast? toast;
  // ignore: prefer_typing_uninitialized_variables
  var paidBy;
  // ignore: prefer_typing_uninitialized_variables
  var insertResult;
  bool makeChanges = false;
  var expenseApi = ExpenseAPI();
  NumberFormat numberFormat = NumberFormat("#,###", "en_US");
  double total = 0;
  var expenseProductDao = ExpenseProductDao();
  // ignore: prefer_typing_uninitialized_variables
  var expenseTypeId;
  // ignore: prefer_typing_uninitialized_variables
  var analyticAccountId;
  // ignore: prefer_typing_uninitialized_variables
  var expenseTaxId;
  ExpenseProduct? selectedExpense;
  AnalyticAccount? selectedAnalyticAccount;
  ExpenseTax? selectedExpenseTax;
  var saveDate = '';
  String? selectedFormatDate;
  DateTime? dateTime;
  String selectedDate = 'Tuesday, Nov 2 2021';
  String path = "";
  var analyticAccountDao = AnalyticAccountDao();

  @override
  void initState() {
    super.initState();
    toast = FToast();
    toast!.init(context);
    loadData();
  }

  loadData() async {
    pref = await SharedPreferences.getInstance();
    selectedFormatDate = DateFormat("yyyy-MM-dd").format(DateTime.now());
    employeeName = await pref!.getString('user_name');
    expenseProductList = [];
    analyticAccountList = [];
    expenseTaxList = [];
    expenseProductList = await expensePeoductDao.getExpenseProductList();
    analyticAccountList = await analyticAccountDao.getAnalyticAccountList();
    expenseTaxList = await expenseTaxDao.getExpenseTaxList();
    dateTime = DateTime.now();

    selectedDate = DateUtil().getDateFormat(dateTime!);

    paidBy = 'own_account';

    setState(() {});
  }

  List<DropdownMenuItem<int>> _addDividersAfterItems(
    List<ExpenseProduct> items,
  ) {
    List<DropdownMenuItem<int>> menuItems = [];
    for (var item in items) {
      menuItems.addAll([
        DropdownMenuItem<int>(
          value: item.expenseProductId!,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3.0),
            child: Text(item.name!, style: normalMediumBalckText),
          ),
        ),
        if (item != items.last)
          DropdownMenuItem<int>(
            enabled: false,
            child: Container(height: 1, color: Colors.black12),
          ),
      ]);
    }

    return menuItems;
  }

  List<DropdownMenuItem<int>> _addDividersAfterItemsForAnalyticAccount(
    List<ExpenseTax> items,
  ) {
    List<DropdownMenuItem<int>> menuItems = [];
    for (var item in items) {
      menuItems.addAll([
        DropdownMenuItem<int>(
          value: item.expenseTaxId!,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3.0),
            child: Text(item.name!, style: normalMediumBalckText),
          ),
        ),
        if (item != items.last)
          DropdownMenuItem<int>(
            enabled: false,
            child: Container(height: 1, color: Colors.black12),
          ),
      ]);
    }

    return menuItems;
  }

  void _openFileExplorer() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'pdf', 'doc'],
      allowMultiple: true,
    );
    if (result != null) {
      setState(() {
        File file = File((result.files.single.path).toString());
        path = file.path;
        final bytes = File(file.path).readAsBytesSync();

        base64Image = base64Encode(bytes);
        log(path);
      });
    } else {
      path = "";
    }
  }

  @override
  Widget build(BuildContext context) {
    MediaQuery.of(context).size;
    _scaffoldCtx = context;
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) {
              return const ExpenseListPage();
            },
          ),
        );
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppStrings.newExpense.tr(), style: appBarTitleStyle),
          backgroundColor: ColorObj.mainColor,
          leading: InkWell(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return const ExpenseListPage();
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          selectedDate,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xff006ea5),
                            fontSize: 16,
                          ),
                        ),
                      ],
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
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        AppStrings.description.tr(),
                                        style: normalTextWithGrey700,
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        height: 40,
                                        width: double.infinity,
                                        //  margin: EdgeInsets.only(right: 20),
                                        padding: const EdgeInsets.only(
                                          left: 10,
                                          right: 10,
                                          bottom: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          // color: Color(0xffF5F5F5),
                                          borderRadius: BorderRadius.circular(
                                            5,
                                          ),
                                          border: Border.all(
                                            color: ColorObj.dropDownBorderColor,
                                          ),
                                        ),
                                        child: TextFormField(
                                          controller: descController,
                                          textAlign: TextAlign.left,
                                          cursorColor: Colors.grey,
                                          style: normalTextWithBlack,
                                          decoration: InputDecoration(
                                            // hintText:
                                            //     'Enter............',
                                            hintStyle: smallTextWithGrey700,
                                            border: InputBorder.none,
                                          ),
                                          onChanged: ((value) async {
                                            setState(() {});
                                          }),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            const Divider(),
                            const SizedBox(height: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  AppStrings.expenseProduct.tr(),
                                  style: normalMediumGreyText,
                                ),
                                Container(
                                  height: 40,
                                  margin: const EdgeInsets.only(top: 8),
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
                                          Radius.circular(5),
                                        ),
                                      ),
                                      isExpanded: true,
                                      hint: Text(
                                        AppStrings.selectExpenseProduct.tr(),
                                        style: normalMediumGreyText,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      items: _addDividersAfterItems(
                                        expenseProductList,
                                      ),
                                      itemHeight: 20,
                                      value: expenseTypeId,
                                      onChanged: (value) async {
                                        expenseTypeId = value as int;

                                        for (var element
                                            in expenseProductList) {
                                          if (expenseTypeId ==
                                              element.expenseProductId) {
                                            selectedExpense = element;
                                          }
                                        }

                                        setState(() {});
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            const Divider(),
                            const SizedBox(height: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  AppStrings.expenseTax.tr(),
                                  style: normalMediumGreyText,
                                ),
                                Container(
                                  height: 40,
                                  margin: const EdgeInsets.only(top: 8),
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
                                          Radius.circular(5),
                                        ),
                                      ),
                                      isExpanded: true,
                                      hint: Text(
                                        AppStrings.selectExpenseTax.tr(),
                                        style: normalMediumGreyText,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      items:
                                          _addDividersAfterItemsForAnalyticAccount(
                                            expenseTaxList,
                                          ),
                                      itemHeight: 20,
                                      value: expenseTaxId,
                                      onChanged: (value) async {
                                        expenseTaxId = value as int;

                                        for (var element in expenseTaxList) {
                                          if (expenseTaxId ==
                                              element.expenseTaxId) {
                                            selectedExpenseTax = element;
                                          }
                                        }

                                        setState(() {});
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            const Divider(),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        AppStrings.billReference.tr(),
                                        style: normalMediumGreyText,
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        height: 40,
                                        width: double.infinity,

                                        padding: const EdgeInsets.only(
                                          left: 10,
                                          right: 10,
                                          bottom: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            5,
                                          ),
                                          border: Border.all(
                                            color: ColorObj.dropDownBorderColor,
                                          ),
                                        ),
                                        child: TextFormField(
                                          controller: billRefController,
                                          textAlign: TextAlign.left,
                                          cursorColor: Colors.grey,
                                          style: normalTextWithBlack,
                                          decoration: InputDecoration(
                                            border: InputBorder.none,

                                            hintStyle: smallTextWithGrey700,
                                          ),
                                          onChanged: ((value) async {
                                            setState(() {});
                                          }),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            const Divider(),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        AppStrings.totalKs.tr(),
                                        style: normalMediumGreyText,
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        height: 40,
                                        width: double.infinity,
                                        // margin: EdgeInsets.only(left: 20),
                                        padding: const EdgeInsets.only(
                                          left: 10,
                                          right: 10,
                                          bottom: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            5,
                                          ),
                                          border: Border.all(
                                            color: ColorObj.dropDownBorderColor,
                                          ),
                                        ),
                                        child: TextFormField(
                                          controller: totalAmountController,
                                          keyboardType: TextInputType.number,
                                          textAlign: TextAlign.left,
                                          cursorColor: Colors.grey,
                                          style: normalTextWithBlack,
                                          decoration: InputDecoration(
                                            hintStyle: smallTextWithGrey700,
                                            border: InputBorder.none,
                                          ),
                                          onFieldSubmitted: (value) async {
                                            total = double.parse(
                                              value.toString(),
                                            );
                                            totalAmountController.text =
                                                numberFormat.format(total);
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            const Divider(),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          margin: const EdgeInsets.only(
                                            top: 16,
                                          ),
                                          child: Text(
                                            AppStrings.paidBy.tr(),
                                            style: normalMediumGreyText,
                                            textAlign: TextAlign.left,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 6,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            RadioListTile(
                                              contentPadding:
                                                  const EdgeInsets.all(0),
                                              dense: true,
                                              value: 0,
                                              groupValue: _groupValue,
                                              title: Text(
                                                AppStrings.employeeToReimburse
                                                    .tr(),
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                ),
                                              ),
                                              onChanged: (newValue) {
                                                setState(() {
                                                  _groupValue = int.parse(
                                                    newValue.toString(),
                                                  );
                                                  empSelect = true;
                                                  companySelect = false;
                                                  paidBy = 'own_account';
                                                });
                                              },
                                              activeColor: _groupValue == 0
                                                  ? Colors.lightBlue[900]
                                                  : Colors.black,
                                              selected: empSelect,
                                            ),
                                            RadioListTile(
                                              contentPadding:
                                                  const EdgeInsets.all(0),
                                              dense: true,
                                              value: 1,
                                              groupValue: _groupValue,
                                              title: Text(
                                                AppStrings.company.tr(),
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                ),
                                              ),
                                              onChanged: (newValue) {
                                                log('onChanged---$newValue');
                                                setState(() {
                                                  _groupValue = int.parse(
                                                    newValue.toString(),
                                                  );

                                                  companySelect = true;
                                                  empSelect = false;
                                                  paidBy = 'company_account';
                                                });
                                              },
                                              activeColor: _groupValue == 1
                                                  ? Colors.lightBlue[900]
                                                  : Colors.black,
                                              selected: companySelect,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                //Expanded(child: Container())
                              ],
                            ),
                            const SizedBox(height: 10),
                            const Divider(),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        AppStrings.note.tr(),
                                        style: normalMediumGreyText,
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        // height: 40,
                                        width: double.infinity,
                                        //  margin: EdgeInsets.only(right: 20),
                                        padding: const EdgeInsets.only(
                                          left: 10,
                                          right: 10,
                                          bottom: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          // color: Color(0xffF5F5F5),
                                          borderRadius: BorderRadius.circular(
                                            5,
                                          ),
                                          border: Border.all(
                                            color: ColorObj.dropDownBorderColor,
                                          ),
                                        ),
                                        child: TextFormField(
                                          controller: noteController,
                                          textAlign: TextAlign.left,
                                          cursorColor: Colors.grey,
                                          style: normalTextWithBlack,
                                          decoration: InputDecoration(
                                            // hintText:
                                            //     '............',
                                            hintStyle: smallTextWithGrey700,
                                            border: InputBorder.none,
                                          ),
                                          maxLines: 5,
                                          onChanged: ((value) async {
                                            setState(() {});
                                          }),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 30),
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
                                      color: ColorObj.secondColor,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      AppStrings.attachment.tr(),
                                      style: normalMediumGreyText,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
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
    bool checkInternet = await InternetConnectionChecker.instance.hasConnection;
    if (checkInternet == false) {
      // ignore: use_build_context_synchronously
      showDialog(context: context, builder: (_) => CustomEventDialog());
      return;
    }

    if (descController.text == '') {
      toast!.showToast(
        child: Widgets().getWarningToast(
          AppStrings.pleaseEnterDescription.tr(),
        ),
        gravity: ToastGravity.BOTTOM,
        toastDuration: const Duration(seconds: 2),
      );
      return;
    }

    if (selectedExpense == null) {
      toast!.showToast(
        child: Widgets().getWarningToast(
          AppStrings.pleaseSelectExpenseProduct.tr(),
        ),
        gravity: ToastGravity.BOTTOM,
        toastDuration: const Duration(seconds: 2),
      );
      return;
    }

    if (totalAmountController.text == '') {
      toast!.showToast(
        child: Widgets().getWarningToast(
          AppStrings.pleaseEnterTotalAmount.tr(),
        ),
        gravity: ToastGravity.BOTTOM,
        toastDuration: const Duration(seconds: 2),
      );
      return;
    }

    EasyLoading.show(status: AppStrings.submittingPleaseWait.tr());

    var amount = totalAmountController.text.toString().replaceAll(",", "");
    log('amount-------$amount');

    log(
      'selectedExpenseTax-$selectedExpenseTax : ${selectedExpenseTax.runtimeType.toString()}',
    );

    Expense expense = Expense(
      0,
      descController.text.toString(),
      selectedFormatDate,
      billRefController.text.toString(),
      selectedExpense!.expenseProductId,
      selectedExpense!.name,
      double.parse(amount.toString()),
      1,
      total,
      paidBy,
      noteController.text.toString(),
      'draft',
      0,
      selectedExpenseTax != null ? selectedExpenseTax!.expenseTaxId : 0,
      //0,
      base64Image,
    );

    var createResult = await expenseApi.createExpense(expense);

    log('createResult-----$createResult');

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

      EasyLoading.dismiss();
      toast!.showToast(
        child: Widgets().getErrorToast('$resultMessage'),
        gravity: ToastGravity.BOTTOM,
        toastDuration: const Duration(seconds: 2),
      );
      return;
    }

    EasyLoading.dismiss();

    toast!.showToast(
      child: Widgets().getSuccessToast(
        AppStrings.requestSuccessfullyCreated.tr(),
      ),
      gravity: ToastGravity.BOTTOM,
      toastDuration: const Duration(seconds: 2),
    );

    // ignore: use_build_context_synchronously
    await Navigator.pushReplacementNamed(context, '/expense');
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget bottomSheet() {
    return SingleChildScrollView(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.12,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          children: [
            Text(
              AppStrings.takeAttachmentPhoto.tr(),
              textAlign: TextAlign.left,
              style: const TextStyle(fontSize: 20.0),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.camera, color: ColorObj.mainColor),
                  onPressed: () {
                    takephoto(ImageSource.camera);
                    Navigator.pop(context);
                  },
                  label: Text(
                    AppStrings.camera.tr(),
                    style: smallTextWithPurple,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: ColorObj.mainColor, width: 1),
                  ),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.camera, color: ColorObj.mainColor),
                  onPressed: () {
                    takephoto(ImageSource.camera);
                    Navigator.pop(context);
                  },
                  label: Text(
                    AppStrings.camera.tr(),
                    style: smallTextWithPurple,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: ColorObj.mainColor, width: 1),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  takephoto(ImageSource source) async {
    final pickedFile = await _picker.pickImage(
      imageQuality: 85,
      source: source,
    );
    setState(() {
      _imageFile = File(pickedFile!.path);
    });

    setState(() {
      photos.add(_imageFile!);
    });

    final bytes = File(pickedFile!.path).readAsBytesSync();

    base64Image = base64Encode(bytes);
    base64ImageList.add(base64Image);
  }
}
