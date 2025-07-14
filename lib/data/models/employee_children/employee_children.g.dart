// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'employee_children.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EmployeeChildren _$EmployeeChildrenFromJson(Map<String, dynamic> json) =>
    EmployeeChildren(
      json['parent_emp_id'] as int?,
      json['employee_id'] as int?,
      json['employee_name'] as String?,
      json['employee_code'] as String?,
      json['job_name'] as String?,
      json['mobile_phone'] as String?,
      json['work_phone'] as String?,
      json['parent_id'] as int?,
      json['department_id'] as int?,
      json['department_name'] as String?,
      json['gender'] as String?,
      json['birthday'] as String?,
      json['email'] as String?,
      json['user_id'] as int?,
      json['reg_number'] as String?,
      json['avatar'] as String?,
      json['work_schedule_id'] as int?,
      json['approval_level'] as String?,
      json['write_date'] as String?,
      id: json['id'] as int?,
    );

Map<String, dynamic> _$EmployeeChildrenToJson(EmployeeChildren instance) =>
    <String, dynamic>{
      'id': instance.id,
      'parent_emp_id': instance.parent_emp_id,
      'employee_id': instance.employee_id,
      'employee_name': instance.employee_name,
      'employee_code': instance.employee_code,
      'job_name': instance.job_name,
      'mobile_phone': instance.mobile_phone,
      'work_phone': instance.work_phone,
      'parent_id': instance.parent_id,
      'department_id': instance.department_id,
      'department_name': instance.department_name,
      'gender': instance.gender,
      'birthday': instance.birthday,
      'email': instance.email,
      'user_id': instance.user_id,
      'reg_number': instance.reg_number,
      'avatar': instance.avatar,
      'work_schedule_id': instance.work_schedule_id,
      'approval_level': instance.approval_level,
      'write_date': instance.write_date,
    };
