// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leave_reason.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LeaveReason _$LeaveReasonFromJson(Map<String, dynamic> json) => LeaveReason(
      json['leaveReasonId'] as int?,
      json['name'] as String?,
      json['writeDate'] as String?,
      id: json['id'] as int?,
    );

Map<String, dynamic> _$LeaveReasonToJson(LeaveReason instance) =>
    <String, dynamic>{
      'id': instance.id,
      'leaveReasonId': instance.leaveReasonId,
      'name': instance.name,
      'writeDate': instance.writeDate,
    };
