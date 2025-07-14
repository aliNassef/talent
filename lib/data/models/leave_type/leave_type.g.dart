// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leave_type.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LeaveType _$LeaveTypeFromJson(Map<String, dynamic> json) => LeaveType(
      json['leave_type_id'] as int?,
      json['name'] as String?,
      json['company_id'] as int?,
      json['responsible_id'] as int?,
      json['unpaid'] as int?,
      (json['number_of_days'] as num?)?.toDouble(),
      json['request_unit'] as String?,
      json['holiday_type'] as String?,
      json['leave_type_code'] as String?,
      id: json['id'] as int?,
    );

Map<String, dynamic> _$LeaveTypeToJson(LeaveType instance) => <String, dynamic>{
      'id': instance.id,
      'leave_type_id': instance.leave_type_id,
      'name': instance.name,
      'company_id': instance.company_id,
      'responsible_id': instance.responsible_id,
      'unpaid': instance.unpaid,
      'number_of_days': instance.number_of_days,
      'request_unit': instance.request_unit,
      'holiday_type': instance.holiday_type,
      'leave_type_code': instance.leave_type_code,
    };
