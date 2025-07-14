// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payslip.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Payslip _$PayslipFromJson(Map<String, dynamic> json) => Payslip(
      json['payslipId'] as int?,
      json['name'] as String?,
      json['employee_id'] as int?,
      json['number'] as String?,
      json['employee_code'] as String?,
      json['employee_name'] as String?,
      json['department'] as String?,
      json['position'] as String?,
      json['join_date'] as String?,
      json['work_location'] as String?,
      json['date_from'] as String?,
      json['date_to'] as String?,
      json['total_ot_hours'] as String?,
      json['total_working_days'] as String?,
      json['total_leave_days'] as String?,
      json['write_date'] as String?,
      id: json['id'] as int?,
    );

Map<String, dynamic> _$PayslipToJson(Payslip instance) => <String, dynamic>{
      'id': instance.id,
      'payslipId': instance.payslipId,
      'name': instance.name,
      'employee_id': instance.employee_id,
      'number': instance.number,
      'employee_name': instance.employee_name,
      'employee_code': instance.employee_code,
      'department': instance.department,
      'position': instance.position,
      'join_date': instance.join_date,
      'work_location': instance.work_location,
      'date_from': instance.date_from,
      'date_to': instance.date_to,
      'total_ot_hours': instance.total_ot_hours,
      'total_working_days': instance.total_working_days,
      'total_leave_days': instance.total_leave_days,
      'write_date': instance.write_date,
    };
