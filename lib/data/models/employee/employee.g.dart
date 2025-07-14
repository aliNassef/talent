// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'employee.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Employee _$EmployeeFromJson(Map<String, dynamic> json) => Employee(
      json['employee_id'] as int?,
      json['employee_name'] as String?,
      json['employee_code'] as String?,
      json['employee_type'] as String?,
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
      json['job_grade'] as String?,
      json['avatar'] as String?,
      json['work_schedule_id'] as int?,
      json['childCount'] as int?,
      json['showChildEmpList'] as int?,
      json['approval_level'] as String?,
      json['write_date'] as String?,
      id: json['id'] as int?,
    );

Map<String, dynamic> _$EmployeeToJson(Employee instance) => <String, dynamic>{
      'id': instance.id,
      'employee_id': instance.employee_id,
      'employee_name': instance.employee_name,
      'employee_code': instance.employee_code,
      'employee_type': instance.employee_type,
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
      'job_grade': instance.job_grade,
      'avatar': instance.avatar,
      'work_schedule_id': instance.work_schedule_id,
      'childCount': instance.childCount,
      'showChildEmpList': instance.showChildEmpList,
      'approval_level': instance.approval_level,
      'write_date': instance.write_date,
    };
