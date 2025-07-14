import 'package:json_annotation/json_annotation.dart';
part 'employee.g.dart';

@JsonSerializable()
class Employee {
  int? id;
  int? employee_id;
  String? employee_name;
  String? employee_code;
  String? employee_type;
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
  String? job_grade;
  String? avatar;
  int? work_schedule_id;
  int? childCount;
  int? showChildEmpList;
  String? approval_level;
  String? write_date;

  Employee(
      this.employee_id,
      this.employee_name,
      this.employee_code,
      this.employee_type,
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
      this.job_grade,
      this.avatar,
      this.work_schedule_id,
      this.childCount,
      this.showChildEmpList,
      this.approval_level,
      this.write_date,
      {this.id});

  factory Employee.fromJson(Map<String, dynamic> json) =>
      _$EmployeeFromJson(json);

  Map<String, dynamic> toJson() => _$EmployeeToJson(this);
}
