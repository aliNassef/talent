import 'dart:async';
import 'dart:core';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'dart:convert' as convert;
import 'package:encrypt/encrypt.dart' as encrypt;

class DatabaseProvider with ChangeNotifier {
  static Database? _database;
  final int _dbversion = 1;
  static final DatabaseProvider db = DatabaseProvider._();
  DatabaseProvider._();

  Future<Database?> get database async {
    if (_database != null) return _database;

    _database = await _initDB();

    return _database;
  }

  _initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'talent_hr.db');
    var db = await openDatabase(
      path,
      version: _dbversion,
      onCreate: _createTable,
    );
    return db;
  }

  Future _createTable(Database db, int version) async {
    await db.execute(
      'create table expense_tax('
      'id INTEGER PRIMARY KEY AUTOINCREMENT,'
      'expenseTaxId INTEGER,'
      'name TEXT,'
      'description TEXT,'
      'amount_type TEXT,'
      'type_tax_use TEXT,'
      'amount DOUBLE,'
      'tax_scope TEXT,'
      'write_date TEXT'
      ')',
    );

    await db.execute(
      'CREATE TABLE employee('
      'id INTEGER PRIMARY KEY AUTOINCREMENT,'
      'employee_id INTEGER,'
      'employee_name TEXT,'
      'employee_code TEXT,'
      'employee_type TEXT,'
      'job_name TEXT,'
      'mobile_phone TEXT,'
      'work_phone TEXT,'
      'parent_id INTEGER,'
      'department_id INTEGER,'
      'department_name TEXT,'
      'gender TEXT,'
      'birthday TEXT,'
      'email TEXT,'
      'user_id INTEGER,'
      'job_grade TEXT,'
      'avatar TEXT,' //image
      'work_schedule_id INTEGER,'
      'childCount INTEGER,'
      'showChildEmpList BOOLEAN,'
      'approval_level TEXT,'
      'write_date TEXT)',
    );

    await db.execute(
      'CREATE TABLE holiday('
      'id INTEGER PRIMARY KEY AUTOINCREMENT,'
      'holidayId INTEGER,'
      'name TEXT,'
      'date_from TEXT,'
      'date_to TEXT,'
      'write_date TEXT)',
    );

    await db.execute(
      'CREATE TABLE leaveType('
      'id INTEGER PRIMARY KEY AUTOINCREMENT,'
      'leave_type_id INTEGER,'
      'name TEXT,'
      'company_id INTEGER,'
      'responsible_id INTEGER,'
      // 'validity_start TEXT,'
      // 'validity_stop TEXT,'
      'unpaid INTEGER,'
      // 'allocation_type TEXT,'
      'number_of_days DOUBLE,'
      'request_unit TEXT,'
      'holiday_type TEXT,'
      'leave_type_code TEXT)',
    );

    await db.execute(
      'CREATE TABLE leaveRemain('
      'id INTEGER PRIMARY KEY AUTOINCREMENT,'
      'leaveRemainId INTEGER,'
      'name TEXT,'
      'remaining_days DOUBLE,'
      'code TEXT,'
      'total_days TEDOUBLEXT)',
    );

    await db.execute(
      'CREATE TABLE attendance('
      'id INTEGER PRIMARY KEY AUTOINCREMENT,'
      'attendanceId INTEGER,'
      'name TEXT,'
      'employee_id INTEGER,'
      'user_id INTEGER,'
      'date TEXT,'
      'check_in_datetime TEXT,'
      'check_out_datetime TEXT,'
      'check_in_time TEXT,'
      'check_out_time TEXT,'
      'working_hr TEXT,'
      'in_latitude DOUBLE,'
      'in_longitude DOUBLE,'
      'out_latitude DOUBLE,'
      'out_longitude DOUBLE,'
      'in_location TEXT,'
      'out_location TEXT,'
      'device_id TEXT,'
      'reason TEXT,'
      'write_date TEXT,'
      'att_type TEXT,'
      'checkInSelfie TEXT,'
      'checkOutSelfie TEXT)',
    );

    await db.execute(
      'CREATE TABLE leaveReason('
      'id INTEGER PRIMARY KEY AUTOINCREMENT,'
      'leaveReasonId INTEGER,'
      'name TEXT,'
      'writeDate TEXT)',
    );

    await db.execute(
      'CREATE TABLE leave('
      'id INTEGER PRIMARY KEY AUTOINCREMENT,'
      'leaveId INTEGER,'
      'name TEXT,'
      'state TEXT,'
      'user_id INTEGER,'
      'holiday_status_id INTEGER,'
      'leave_type TEXT,'
      'employee_id INTEGER,'
      'department_id INTEGER,'
      'requestDate TEXT,'
      'date_from TEXT,'
      'date_to TEXT,'
      'number_of_days DOUBLE,'
      'request_date_from TEXT,'
      'request_date_to TEXT,'
      'hiddenStateId INTEGER,'
      'request_date_from_period TEXT,'
      'request_unit_half BOOLEAN,'
      'holiday_type TEXT,'
      'isSync BOOLEAN,'
      'leaveReasonId INTEGER,'
      'leaveReason TEXT,'
      'emergency_contact TEXT,'
      'pending_task TEXT,'
      'employee_name TEXT,'
      'previous_timeoff TEXT,'
      'previous_timeoff_duration TEXT,'
      'reason TEXT,'
      'approveById INTEGER,'
      'approveByName TEXT,'
      'attachment TEXT,'
      'write_date TEXT,'
      'monthName TEXT,'
      'year TEXT)',
    );

    await db.execute(
      'CREATE TABLE hours('
      'id INTEGER PRIMARY KEY AUTOINCREMENT,'
      'key TEXT,'
      'value TEXT,'
      'type TEXT)',
    );

    await db.execute(
      'CREATE TABLE paySlip('
      'id INTEGER PRIMARY KEY AUTOINCREMENT,'
      'payslipId INTEGER,'
      'name TEXT,'
      'employee_id INTEGER,'
      'number TEXT,'
      'employee_name TEXT,'
      'employee_code TEXT,'
      'department TEXT,'
      'position TEXT,'
      'join_date TEXT,'
      'work_location TEXT,'
      'date_from TEXT,'
      'date_to TEXT,'
      'total_ot_hours TEXT,'
      'total_working_days TEXT,'
      'total_leave_days TEXT,'
      'write_date TEXT)',
    );

    await db.execute(
      'CREATE TABLE paySlipLine('
      'id INTEGER PRIMARY KEY AUTOINCREMENT,'
      'payslipLineId INTEGER,'
      'payslip_id INTEGER,'
      'name TEXT,'
      'category TEXT,'
      'sequence INTEGER,'
      'total DOUBLE,'
      'code TEXT,'
      'type TEXT)',
    );

    await db.execute(
      'CREATE TABLE attachment('
      'id INTEGER PRIMARY KEY AUTOINCREMENT,'
      'file_name TEXT,'
      'data TEXT)',
    );

    await db.execute(
      'create table expense('
      'id INTEGER PRIMARY KEY AUTOINCREMENT,'
      'expenseId INTEGER,'
      'description TEXT,'
      'date TEXT,'
      'billRef TEXT,'
      'expenseProductId INTEGER,'
      'expenseProductName TEXT,'
      'unitPrice DOUBLE,'
      'qty DOUBLE,'
      'total DOUBLE,'
      'paidBy TEXT,'
      'note TEXT,'
      'state TEXT,'
      'isSync BOOLEAN,'
      'analyticAccountId INTEGER,'
      'attachment TEXT'
      ')',
    );

    await db.execute(
      'create table expenseProduct('
      'id INTEGER PRIMARY KEY AUTOINCREMENT,'
      'expenseProductId INTEGER,'
      'name TEXT'
      ')',
    );

    await db.execute(
      'create table analyticAccount('
      'id INTEGER PRIMARY KEY AUTOINCREMENT,'
      'analyticAccountId INTEGER,'
      'name TEXT'
      ')',
    );

    await db.execute(
      'CREATE TABLE notification('
      'id INTEGER PRIMARY KEY AUTOINCREMENT,'
      'notificationId TEXT,'
      'title TEXT,'
      'body TEXT,'
      'model TEXT,'
      'orderId INTEGER,'
      'currentTime TEXT,'
      'isRead BOOLEAN)',
    );
  }

  Future<void> dbClose() async {
    final db = await database;
    db!.close();
  }

  Future<void> cleanDatabase() async {
    print('clean database---');
    try {
      final db = await database;
      await db!.transaction((txn) async {
        var batch = txn.batch();
        batch.delete('township');
        batch.delete('city');
        batch.delete('country_state');
        batch.delete('sales_channel');
        batch.delete('outlet');

        await batch.commit();
      });
    } catch (error) {
      throw Exception('DbBase.cleanDatabase: $error');
    }
  }

  Future<void> cleanDatabase2() async {
    print('clean database---');
    try {
      final db = await database;
      await db!.transaction((txn) async {
        var batch = txn.batch();

        batch.delete('customer');
        batch.delete('product');

        await batch.commit();
      });
    } catch (error) {
      throw Exception('DbBase.cleanDatabase: $error');
    }
  }

  Future<void> cleanSomeTable() async {
    try {
      final db = await database;
      await db!.transaction((txn) async {
        var batch = txn.batch();

        batch.delete('township');
        batch.delete('city');
        batch.delete('country_state');
        batch.delete('sales_channel');
        batch.delete('outlet');

        await batch.commit();
      });
    } catch (error) {
      throw Exception('DbBase.cleanDatabase: $error');
    }
  }

  //--------
  Future<void> deleteDB() async {
    try {
      print('deleting db'); //To Remove log
      _database = null;
      Directory documentsDirectory = await getApplicationDocumentsDirectory();
      final path = join(documentsDirectory.path, 'talent_hr.db');
      deleteDatabase(path);
    } catch (e) {
      print(e.toString()); //To Remove log
    }

    print('db is deleted'); //To Remove log
  }

  List<String> tables = [];
  // static const SECRET_KEY = "2021_PRIVATE_KEY_ENCRYPT_2021";
  static const SECRET_KEY = "TALENTHR_FLUTTER_PRIVATE_KEY";
  static const DATABASE_VERSION = 1;

  Future<String> generateBackup({bool isEncrypted = true}) async {
    print('GENERATE BACKUP');

    var dbs = _database;

    List data = [];

    List<Map<String, dynamic>> listMaps = [];

    tables = ['product', 'customer'];

    for (var i = 0; i < tables.length; i++) {
      listMaps = await dbs!.query(tables[i]);

      data.add(listMaps);
    }
    print('data------------$data');

    List backups = [tables, data];

    String json = convert.jsonEncode(backups);

    print('json-------$json');

    if (isEncrypted) {
      var key = encrypt.Key.fromUtf8(SECRET_KEY);
      var iv = encrypt.IV.fromLength(16);
      var encrypter = encrypt.Encrypter(encrypt.AES(key));
      var encrypted = encrypter.encrypt(json, iv: iv);

      return encrypted.base64;
    } else {
      return json;
    }
  }

  Future<String> restoreBackup(String backup, {bool isEncrypted = true}) async {
    //678718790015-uutjqhfcfjdihhg3809vmjl9vubgd6ft.apps.googleusercontent.com   outhClient ID
    print('restoreBackup-------------$backup');
    var dbs = _database;

    Batch batch = dbs!.batch();

    var key = encrypt.Key.fromUtf8(SECRET_KEY);
    var iv = encrypt.IV.fromLength(16);
    var encrypter = encrypt.Encrypter(encrypt.AES(key));

    List json = convert.jsonDecode(
      isEncrypted ? encrypter.decrypt64(backup, iv: iv) : backup,
    );

    for (var i = 0; i < json[0].length; i++) {
      print('json[0]---------${json[0]}');
      for (var k = 0; k < json[1][i].length; k++) {
        print('json[1][i]-----------------${json[1][i]}');
        batch.insert(json[0][i], json[1][i][k]);
      }
    }

    await batch.commit(continueOnError: false, noResult: true);
    print('RESTORE BACKUP');
    return 'success';
  }
}
