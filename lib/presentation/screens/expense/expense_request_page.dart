import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
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
  var pref;
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
  var mode;
  bool updateDenied = false;
  // var expenseDao = ExpenseDao();
  FToast? toast;
  var paidBy;
  var insertResult;
  bool makeChanges = false;
  var expenseApi = ExpenseAPI();
  NumberFormat numberFormat = NumberFormat("#,###", "en_US");
  double total = 0;
  var expenseProductDao = ExpenseProductDao();
  var expenseTypeId;
  var analyticAccountId;
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
    // TODO: implement initState
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
      List<ExpenseProduct> items) {
    List<DropdownMenuItem<int>> _menuItems = [];
    for (var item in items) {
      _menuItems.addAll(
        [
          DropdownMenuItem<int>(
            value: item.expenseProductId!,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3.0),
              child: Text(
                item.name!,
                style: normalMediumBalckText,
              ),
            ),
          ),
          if (item != items.last)
            DropdownMenuItem<int>(
              enabled: false,
              child: Container(
                height: 1,
                color: Colors.black12,
              ),
            ),
        ],
      );
    }

    return _menuItems;
  }

  List<DropdownMenuItem<int>> _addDividersAfterItemsForAnalyticAccount(
      List<ExpenseTax> items) {
    List<DropdownMenuItem<int>> _menuItems = [];
    for (var item in items) {
      _menuItems.addAll(
        [
          DropdownMenuItem<int>(
            value: item.expenseTaxId!,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3.0),
              child: Text(
                item.name!,
                style: normalMediumBalckText,
              ),
            ),
          ),
          if (item != items.last)
            DropdownMenuItem<int>(
              enabled: false,
              child: Container(
                height: 1,
                color: Colors.black12,
              ),
            ),
        ],
      );
    }

    return _menuItems;
  }

  void _openFileExplorer() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'pdf', 'doc'],
        allowMultiple: true);
    if (result != null) {
      setState(() {
        /*For(int i=0;i<result.length;i++) {

        }*/
        File file = File((result.files.single.path).toString());
        path = file.path;
        final bytes = File(file.path).readAsBytesSync();

        base64Image = base64Encode(bytes);
        print(path);
      });
    } else {
      path = "";
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    _scaffoldCtx = context;
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) {
          return ExpenseListPage();
        }));
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'new_expense'.tr(),
            style: appBarTitleStyle,
          ),
          backgroundColor: ColorObj.mainColor,
          leading: InkWell(
              onTap: () {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) {
                  return ExpenseListPage();
                }));
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 10.0),
                child: Icon(
                  Icons.arrow_back,
                  size: 28,
                  color: Colors.white,
                ),
              )),
        ),
        body: GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(new FocusNode());
            },
            child: SingleChildScrollView(
                child: Container(
                    color: Colors.white,
                    child: Padding(
                        padding: EdgeInsets.all(12),
                        child: Container(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                    Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      selectedDate,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontFamily: 'Regular',
                                          color: Color(0xff006ea5),
                                          fontSize: 16),
                                    )
                                  ],
                                ),
                              // Container(
                              //     width: MediaQuery.of(context).size.width,
                              //     height: 60,
                              //     child: Card(
                              //         child: ElevatedButton(
                              //       style: ButtonStyle(
                              //           backgroundColor:
                              //               MaterialStateProperty.all(
                              //                   Color(0xfff0efef)),
                              //           shape: MaterialStateProperty.all(
                              //               const RoundedRectangleBorder(
                              //                   borderRadius: BorderRadius.all(
                              //                       Radius.circular(5))))),
                              //       child: Text(
                              //         selectedDate,
                              //         textAlign: TextAlign.center,
                              //         style: TextStyle(
                              //             fontFamily: 'Regular',
                              //             color: Color(0xff006ea5),
                              //             fontSize: 20),
                              //       ),
                              //       onPressed: () {
                              //         showDatePicker(
                              //                 context: context,
                              //                 initialDate: DateTime.now(),
                              //                 firstDate: DateTime(2001),
                              //                 lastDate: DateTime(2222))
                              //             .then((value) {
                              //           setState(() {
                              //             if (value != null) {
                              //               selectedDate =
                              //                   DateUtil().getDateFormat(value);

                              //               selectedFormatDate =
                              //                   DateUtil().getChosenDate(value);

                              //               dateTime = value;
                              //             }
                              //           });
                              //         });
                              //       },
                              //     ))),
                             
                              SizedBox(
                                height: 8,
                              ),
                              Container(
                                margin: EdgeInsets.symmetric(
                                    horizontal: 2.0.wp(context),
                                    vertical: 2.0.hp(context)),
                                decoration: const BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(8)),
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                          offset: Offset(4, 4),
                                          blurRadius: 3,
                                          spreadRadius: 1,
                                          color: Colors.black12),
                                      BoxShadow(
                                          offset: Offset(-2, -2),
                                          blurRadius: 2,
                                          spreadRadius: 1,
                                          color: Colors.black12)
                                    ]),
                                child: Padding(
                                  padding: EdgeInsets.all(5.0.wp(context)),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                              flex: 1,
                                              child: Container(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Description',
                                                      style:
                                                          normalTextWithGrey700,
                                                    ),
                                                    SizedBox(
                                                      height: 8,
                                                    ),
                                                    Container(
                                                      height: 40,
                                                      width: double.infinity,
                                                      //  margin: EdgeInsets.only(right: 20),
                                                      padding: EdgeInsets.only(
                                                          left: 10,
                                                          right: 10,
                                                          bottom: 8),
                                                      decoration: BoxDecoration(
                                                        // color: Color(0xffF5F5F5),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                        border: Border.all(
                                                            color: ColorObj
                                                                .dropDownBorderColor),
                                                      ),
                                                      child: TextFormField(
                                                          controller:
                                                              descController,
                                                          textAlign:
                                                              TextAlign.left,
                                                          cursorColor:
                                                              Colors.grey,
                                                          style:
                                                              normalTextWithBlack,
                                                          decoration:
                                                              InputDecoration(
                                                            // hintText:
                                                            //     'Enter............',
                                                            hintStyle:
                                                                smallTextWithGrey700,
                                                            border: InputBorder
                                                                .none,
                                                          ),
                                                          onChanged:
                                                              ((value) async {
                                                            setState(() {});
                                                          })),
                                                    )
                                                  ],
                                                ),
                                              )),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Divider(),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Container(
                                              child: Text(
                                                'Expense Product',
                                                style: normalMediumGreyText,
                                              ),
                                            ),
                                            Container(
                                                height: 40,
                                                margin: EdgeInsets.only(
                                                  top: 8,
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 6),
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        const BorderRadius.all(
                                                            Radius.circular(6)),
                                                    border: Border.all(
                                                        color: ColorObj
                                                            .dropDownBorderColor)),
                                                child:
                                                    DropdownButtonHideUnderline(
                                                  child: DropdownButton2(
                                                    dropdownFullScreen: true,
                                                    dropdownDecoration:
                                                        const BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            5))),
                                                    isExpanded: true,
                                                    hint: Text(
                                                      'Select Expense Product',
                                                      style:
                                                          normalMediumGreyText,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                    items:
                                                        _addDividersAfterItems(
                                                            expenseProductList),
                                                    itemHeight: 20,
                                                    value: expenseTypeId,
                                                    onChanged: (value) async {
                                                      expenseTypeId =
                                                          value as int;

                                                      expenseProductList
                                                          .forEach((element) {
                                                        if (expenseTypeId ==
                                                            element
                                                                .expenseProductId) {
                                                          selectedExpense =
                                                              element;
                                                        }
                                                      });

                                                      setState(() {});
                                                    },
                                                  ),
                                                ))
                                          ]),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Divider(),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Container(
                                              child: Text(
                                                'Expense Tax',
                                                style: normalMediumGreyText,
                                              ),
                                            ),
                                            Container(
                                                height: 40,
                                                margin: EdgeInsets.only(
                                                  top: 8,
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 6),
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        const BorderRadius.all(
                                                            Radius.circular(6)),
                                                    border: Border.all(
                                                        color: ColorObj
                                                            .dropDownBorderColor)),
                                                child:
                                                    DropdownButtonHideUnderline(
                                                  child: DropdownButton2(
                                                    dropdownFullScreen: true,
                                                    dropdownDecoration:
                                                        const BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            5))),
                                                    isExpanded: true,
                                                    hint: Text(
                                                      'Select Expense Tax',
                                                      style:
                                                          normalMediumGreyText,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                    items:
                                                        _addDividersAfterItemsForAnalyticAccount(
                                                            expenseTaxList),
                                                    itemHeight: 20,
                                                    value: expenseTaxId,
                                                    onChanged: (value) async {
                                                      expenseTaxId =
                                                          value as int;

                                                      expenseTaxList
                                                          .forEach((element) {
                                                        if (expenseTaxId ==
                                                            element
                                                                .expenseTaxId) {
                                                          selectedExpenseTax =
                                                              element;
                                                        }
                                                      });

                                                      setState(() {});
                                                    },
                                                  ),
                                                ))
                                          ]),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Divider(),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                              flex: 1,
                                              child: Container(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Bill Reference',
                                                      style:
                                                          normalMediumGreyText,
                                                    ),
                                                    SizedBox(
                                                      height: 8,
                                                    ),
                                                    Container(
                                                      height: 40,
                                                      width: double.infinity,
                                                      // margin: EdgeInsets.only(
                                                      //     right: 12),
                                                      padding: EdgeInsets.only(
                                                          left: 10,
                                                          right: 10,
                                                          bottom: 8),
                                                      decoration: BoxDecoration(
                                                        //  color: Color(0xffF5F5F5),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                        border: Border.all(
                                                            color: ColorObj
                                                                .dropDownBorderColor),
                                                      ),
                                                      child: TextFormField(
                                                        controller:
                                                            billRefController,
                                                        textAlign:
                                                            TextAlign.left,
                                                        cursorColor:
                                                            Colors.grey,
                                                        style:
                                                            normalTextWithBlack,
                                                        decoration:
                                                            InputDecoration(
                                                          border:
                                                              InputBorder.none,
                                                          // hintText:
                                                          //     'Enter............',
                                                          hintStyle:
                                                              smallTextWithGrey700,
                                                        ),
                                                        onChanged:
                                                            ((value) async {
                                                          setState(() {});
                                                        }),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              )),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Divider(),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                              flex: 1,
                                              child: Container(
                                                // margin: EdgeInsets.only(
                                                //   left: 12,
                                                // ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Total(Ks)',
                                                      style:
                                                          normalMediumGreyText,
                                                    ),
                                                    SizedBox(
                                                      height: 8,
                                                    ),
                                                    Container(
                                                      height: 40,
                                                      width: double.infinity,
                                                      // margin: EdgeInsets.only(left: 20),
                                                      padding: EdgeInsets.only(
                                                          left: 10,
                                                          right: 10,
                                                          bottom: 8),
                                                      decoration: BoxDecoration(
                                                        //  color: Color(0xffF5F5F5),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                        border: Border.all(
                                                            color: ColorObj
                                                                .dropDownBorderColor),
                                                      ),
                                                      child: TextFormField(
                                                        controller:
                                                            totalAmountController,
                                                        keyboardType:
                                                            TextInputType
                                                                .number,
                                                        textAlign:
                                                            TextAlign.left,
                                                        cursorColor:
                                                            Colors.grey,
                                                        style:
                                                            normalTextWithBlack,
                                                        decoration:
                                                            InputDecoration(
                                                          // hintText:
                                                          //     'Enter Amount...........',
                                                          hintStyle:
                                                              smallTextWithGrey700,
                                                          border:
                                                              InputBorder.none,
                                                        ),
                                                        onFieldSubmitted:
                                                            (value) async {
                                                          total = double.parse(
                                                              value.toString());
                                                          totalAmountController
                                                                  .text =
                                                              numberFormat
                                                                  .format(
                                                                      total);
                                                        },
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              )),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Divider(),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                            flex: 3,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  flex: 2,
                                                  child: Container(
                                                    margin: EdgeInsets.only(
                                                        top: 16),
                                                    child: Text(
                                                      'Paid By:',
                                                      style:
                                                          normalMediumGreyText,
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
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      RadioListTile(
                                                        contentPadding:
                                                            EdgeInsets.all(0),
                                                        dense: true,
                                                        value: 0,
                                                        groupValue: _groupValue,
                                                        title: Text(
                                                          "Employee(To reimburse)",
                                                          style: TextStyle(
                                                              fontSize: 14),
                                                        ),
                                                        onChanged: (newValue) {
                                                          setState(() {
                                                            _groupValue = int
                                                                .parse(newValue
                                                                    .toString());
                                                            empSelect = true;
                                                            companySelect =
                                                                false;
                                                            paidBy =
                                                                'own_account';
                                                          });
                                                        },
                                                        activeColor:
                                                            _groupValue == 0
                                                                ? Colors
                                                                    .lightBlue[900]
                                                                : Colors.black,
                                                        selected: empSelect,
                                                      ),
                                                      RadioListTile(
                                                        contentPadding:
                                                            EdgeInsets.all(0),
                                                        dense: true,
                                                        value: 1,
                                                        groupValue: _groupValue,
                                                        title: Text("Company",
                                                            style: TextStyle(
                                                                fontSize: 14)),
                                                        onChanged: (newValue) {
                                                          print(
                                                              'onChanged---$newValue');
                                                          setState(() {
                                                            _groupValue = int
                                                                .parse(newValue
                                                                    .toString());

                                                            companySelect =
                                                                true;
                                                            empSelect = false;
                                                            paidBy =
                                                                'company_account';
                                                          });
                                                        },
                                                        activeColor:
                                                            _groupValue == 1
                                                                ? Colors
                                                                    .lightBlue[900]
                                                                : Colors.black,
                                                        selected: companySelect,
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                          //Expanded(child: Container())
                                        ],
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Divider(),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                              flex: 1,
                                              child: Container(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Note',
                                                      style:
                                                          normalMediumGreyText,
                                                    ),
                                                    SizedBox(
                                                      height: 8,
                                                    ),
                                                    Container(
                                                      // height: 40,
                                                      width: double.infinity,
                                                      //  margin: EdgeInsets.only(right: 20),
                                                      padding: EdgeInsets.only(
                                                          left: 10,
                                                          right: 10,
                                                          bottom: 8),
                                                      decoration: BoxDecoration(
                                                        // color: Color(0xffF5F5F5),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                        border: Border.all(
                                                            color: ColorObj
                                                                .dropDownBorderColor),
                                                      ),
                                                      child: TextFormField(
                                                          controller:
                                                              noteController,
                                                          textAlign:
                                                              TextAlign.left,
                                                          cursorColor:
                                                              Colors.grey,
                                                          style:
                                                              normalTextWithBlack,
                                                          decoration:
                                                              InputDecoration(
                                                            // hintText:
                                                            //     '............',
                                                            hintStyle:
                                                                smallTextWithGrey700,
                                                            border: InputBorder
                                                                .none,
                                                          ),
                                                          maxLines: 5,
                                                          onChanged:
                                                              ((value) async {
                                                            setState(() {});
                                                          })),
                                                    )
                                                  ],
                                                ),
                                              )),
                                        ],
                                      ),

                                      // Row(
                                      //   mainAxisAlignment:
                                      //       MainAxisAlignment.start,
                                      //   children: [
                                      //     Container(
                                      //       margin: EdgeInsets.only(top: 22),
                                      //       child: Text(
                                      //         'Add Photo',
                                      //         style: normalTextWithGrey700,
                                      //         textAlign: TextAlign.left,
                                      //       ),
                                      //     ),
                                      //   ],
                                      // ),
                                      // SizedBox(height: 4),
                                      // (photos.length <= 0)
                                      //     ? InkWell(
                                      //         onTap: () {
                                      //           showModalBottomSheet(
                                      //               isDismissible: false,
                                      //               context: this.context,
                                      //               builder: ((builder) =>
                                      //                   bottomSheet()));
                                      //         },
                                      //         child: Row(
                                      //           mainAxisAlignment:
                                      //               MainAxisAlignment.start,
                                      //           children: [
                                      //             Container(
                                      //                 margin: EdgeInsets.zero,
                                      //                 padding: EdgeInsets.zero,
                                      //                 //color: Colors.green,
                                      //                 alignment:
                                      //                     Alignment.topLeft,
                                      //                 child: Image.asset(
                                      //                   'assets/imgs/no_image.png',
                                      //                   width: 80,
                                      //                   height: 90,
                                      //                 )),
                                      //           ],
                                      //         ),
                                      //       )
                                      //     : Padding(
                                      //         padding: EdgeInsets.only(
                                      //             right: 6, top: 5),
                                      //         child: GridView.builder(
                                      //           physics: ScrollPhysics(),
                                      //           shrinkWrap: true,
                                      //           gridDelegate:
                                      //               SliverGridDelegateWithFixedCrossAxisCount(
                                      //                   crossAxisCount: 5),
                                      //           itemCount: photos.length,
                                      //           itemBuilder: (_, index) =>
                                      //               Padding(
                                      //             padding: EdgeInsets.only(
                                      //                 top: 8,
                                      //                 bottom: 8,
                                      //                 right: 8),
                                      //             child: Container(
                                      //               width: size.width,
                                      //               child: Image.file(
                                      //                 photos[index],
                                      //                 fit: BoxFit.cover,
                                      //               ),
                                      //             ),
                                      //           ),
                                      //         ),
                                      //       ),
                                      SizedBox(
                                        height: 30,
                                      ),
                                      SizedBox(
                                          height: 45,
                                          width: double.infinity,
                                          child: ElevatedButton(
                                              style: ButtonStyle(
                                                  backgroundColor:
                                                      MaterialStateProperty.all(
                                                          ColorObj.mainColor),
                                                  shape: MaterialStateProperty.all(
                                                      const RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          5))))),
                                              onPressed: _submitRequest,
                                              child: Text(
                                                "Submit Request",
                                                style: normalLargeWhiteText,
                                              ))),
                                      GestureDetector(
                                        onTap: () {
                                          _openFileExplorer();
                                        },
                                        child: Container(
                                          padding:
                                              EdgeInsets.only(left: 5, top: 10),
                                          child: Row(
                                            children: [
                                              Icon(
                                                MdiIcons.attachment,
                                                color: ColorObj.secondColor,
                                              ),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              Text(
                                                'Attachment ( optional )',
                                                style: normalMediumGreyText,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            EdgeInsets.symmetric(vertical: 10),
                                        child: Text(path != null ? path : " "),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ])))))),
      ),
    );
  }

  _submitRequest() async {
    bool checkInternet = await InternetConnectionChecker.instance.hasConnection;
    if (checkInternet == false) {
      showDialog(context: context, builder: (_) => CustomEventDialog());
      return;
    }

    if (descController.text == null || descController.text == '') {
      toast!.showToast(
        child: Widgets().getWarningToast('Please enter description'),
        gravity: ToastGravity.BOTTOM,
        toastDuration: Duration(seconds: 2),
      );
      return;
    }

    if (selectedExpense == null) {
      toast!.showToast(
        child: Widgets().getWarningToast('Please select expense product'),
        gravity: ToastGravity.BOTTOM,
        toastDuration: Duration(seconds: 2),
      );
      return;
    }

    // if (billRefController.text == null || billRefController.text == '') {
    //   toast!.showToast(
    //     child: Widgets().getWarningToast('Please enter bill reference'),
    //     gravity: ToastGravity.BOTTOM,
    //     toastDuration: Duration(seconds: 2),
    //   );
    //   return;
    // }

    if (totalAmountController.text == null ||
        totalAmountController.text == '') {
      toast!.showToast(
        child: Widgets().getWarningToast('Please enter total amount'),
        gravity: ToastGravity.BOTTOM,
        toastDuration: Duration(seconds: 2),
      );
      return;
    }

    // if (noteController.text == null || noteController.text == '') {
    //   toast!.showToast(
    //     child: Widgets().getWarningToast('Please enter note'),
    //     gravity: ToastGravity.BOTTOM,
    //     toastDuration: Duration(seconds: 2),
    //   );
    //   return;
    // }

    EasyLoading.show(status: 'Submitting. Please Wait...');

    var amount = totalAmountController.text.toString().replaceAll(",", "");
    print('amount-------$amount');

    print(
        'selectedExpenseTax-${selectedExpenseTax} : ${selectedExpenseTax.runtimeType.toString()}');

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
        base64Image);

    var createResult = await expenseApi.createExpense(expense);

    print('createResult-----$createResult');

    if (createResult['result'] == 'fail') {
      var resultMessage;
      if (createResult['message'] == '') {
        resultMessage = 'Fail';
      } else {
        resultMessage = createResult['message'];
        if (resultMessage == 'Invalid cookie.') {
          EasyLoading.dismiss();
          toast!.showToast(
            child:
                Widgets().getErrorToast('Session Expired.Please login again.'),
            gravity: ToastGravity.BOTTOM,
            toastDuration: Duration(seconds: 3),
          );
          await pref.setString('jwt_token', "null");
          await Future.delayed(Duration(seconds: 4));
          // timer = Timer.periodic(Duration(seconds: 3), (timer) {
          Navigator.of(_scaffoldCtx).pushAndRemoveUntil(
              MaterialPageRoute(builder: (BuildContext context) {
            return LoginScreen();
          }), (route) => false);

          //});
          return;
        }
      }

      EasyLoading.dismiss();
      toast!.showToast(
        child: Widgets().getErrorToast('$resultMessage'),
        gravity: ToastGravity.BOTTOM,
        toastDuration: Duration(seconds: 2),
      );
      return;
    }

    EasyLoading.dismiss();

    toast!.showToast(
      child: Widgets().getSuccessToast('Request successfully created.'),
      gravity: ToastGravity.BOTTOM,
      toastDuration: Duration(seconds: 2),
    );

    await Navigator.pushReplacementNamed(context, '/expense');
  }

  void dispose() {
    super.dispose();
  }

  Widget bottomSheet() {
    return SingleChildScrollView(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.12,
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          children: [
            Text(
              'Take attachment photo',
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 20.0,
              ),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  icon: Icon(
                    Icons.camera,
                    color: ColorObj.mainColor,
                  ),
                  onPressed: () {
                    takephoto(ImageSource.camera);
                    Navigator.pop(this.context);
                  },
                  label: Text(
                    'Camera',
                    style: smallTextWithPurple,
                  ),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: BorderSide(
                        color: ColorObj.mainColor,
                        width: 1,
                      )),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  takephoto(ImageSource source) async {
    final pickedFile = await _picker.getImage(
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
