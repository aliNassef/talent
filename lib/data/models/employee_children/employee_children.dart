import 'package:json_annotation/json_annotation.dart';
part 'employee_children.g.dart';

@JsonSerializable()
class EmployeeChildren {
  int? id;
  int? parent_emp_id;
  int? employee_id;
  String? employee_name;
  String? employee_code;
  String? job_name;
  String? mobile_phone;
  String? work_phone;
  int? parent_id;
  int? department_id;
  String? department_name;
  String? gender;
  String? birthday;
  String? email;
  int? user_id;
  String? reg_number;
  String? avatar;
  int? work_schedule_id;

  String? approval_level;
  String? write_date;

  EmployeeChildren(
      this.parent_emp_id,
      this.employee_id,
      this.employee_name,
      this.employee_code,
      this.job_name,
      this.mobile_phone,
      this.work_phone,
      this.parent_id,
      this.department_id,
      this.department_name,
      this.gender,
      this.birthday,
      this.email,
      this.user_id,
      this.reg_number,
      this.avatar,
      this.work_schedule_id,
      this.approval_level,
      this.write_date,
      {this.id});

  factory EmployeeChildren.fromJson(Map<String, dynamic> json) =>
      _$EmployeeChildrenFromJson(json);

  Map<String, dynamic> toJson() => _$EmployeeChildrenToJson(this);
}
