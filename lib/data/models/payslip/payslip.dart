import 'package:json_annotation/json_annotation.dart';
part 'payslip.g.dart';

@JsonSerializable()
class Payslip {
  int? id;
  int? payslipId;

  String? name;

  int? employee_id;

  String? number;

  String? employee_name;

  String? employee_code;

  String? department;

  String? position;

  String? join_date;

  String? work_location;

  String? date_from;

  String? date_to;

  String? total_ot_hours;

  String? total_working_days;

  String? total_leave_days;

  String? write_date;

  Payslip(
    this.payslipId,
    this.name,
    this.employee_id,
    this.number,
    this.employee_code,
    this.employee_name,
    this.department,
    this.position,
    this.join_date,
    this.work_location,
    this.date_from,
    this.date_to,
    this.total_ot_hours,
    this.total_working_days,
    this.total_leave_days,
    this.write_date, {
    this.id,
  });

  factory Payslip.fromJson(Map<String, dynamic> json) =>
      _$PayslipFromJson(json);

  Map<String, dynamic> toJson() => _$PayslipToJson(this);
}
