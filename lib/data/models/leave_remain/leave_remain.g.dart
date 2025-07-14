// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leave_remain.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LeaveRemain _$LeaveRemainFromJson(Map<String, dynamic> json) => LeaveRemain(
      json['leaveRemainId'] as int?,
      json['name'] as String?,
      (json['remaining_days'] as num?)?.toDouble(),
      json['code'] as String?,
      (json['total_days'] as num?)?.toDouble(),
      id: json['id'] as int?,
    );

Map<String, dynamic> _$LeaveRemainToJson(LeaveRemain instance) =>
    <String, dynamic>{
      'id': instance.id,
      'leaveRemainId': instance.leaveRemainId,
      'name': instance.name,
      'remaining_days': instance.remaining_days,
      'code': instance.code,
      'total_days': instance.total_days,
    };
