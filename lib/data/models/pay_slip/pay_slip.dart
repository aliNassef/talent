import 'package:json_annotation/json_annotation.dart';
part 'pay_slip.g.dart';

@JsonSerializable()
class PaySlipModel {
  final String employeeName;
  final String address;
  final String refrence;
  final String department;
  final String position;
  final String job_grade;
  final int idNumber;
  final String dateFrom;
  final String dateTo;
  final String registerNum;
  final double gross;
  final double net;
  final List payLineList;

  PaySlipModel(
      {required this.employeeName,
      required this.address,
      required this.refrence,
      required this.department,
      required this.position,
      required this.job_grade,
      required this.idNumber,
      required this.dateFrom,
      required this.dateTo,
      required this.registerNum,
      required this.gross,
      required this.net,
      required this.payLineList});

  factory PaySlipModel.fromJson(Map<String, dynamic> json) =>
      _$PaySlipModelFromJson(json);

  Map<String, dynamic> toJson() => _$PaySlipModelToJson(this);

  // factory PaySlipModel.fromjson(var data) {
  //   // log("work");
  //   List salaryList = data['pay_line_ids'];
  //   double _gross = 0.0;
  //   double _net = 0.0;
  //   for (dynamic i in salaryList) {
  //     if(i['name'] == "Gross"){
  //        _gross = i["total"] == 0 ? 0.0 : i["total"];
  //        _net = i["total"] == 0 ? 0.0 : i["total"];
  //     }
  //   }

  //   PaySlipModel model = PaySlipModel(
  //       employeeName: data['employee_name'],
  //       address: data['email'],
  //       refrence: data['reference'],
  //       idNumber: data['employee_id'],
  //       dateFrom: data['date_from'],
  //       dateTo: data['date_to'],
  //       registerNum: data['employee_code'],
  //       gross: _gross,
  //       net: _net,
  //       payLineList: salaryList
  //       );
  //   // print("work: $model");
  //   return model;
  // }
}
