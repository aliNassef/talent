// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'messaging.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Messaging _$MessagingFromJson(Map<String, dynamic> json) => Messaging(
      json['name'] as String?,
      json['reason'] as String?,
      json['description'] as String?,
      json['requested_date'] as String?,
      json['date_start'] as String?,
      json['date_end'] as String?,
      json['type'] as String?,
      json['notiType'] as String?,
      json['state'] as String?,
      json['count'] as int?,
      json['isRead'] as int?,
      id: json['id'] as String?,
    );

Map<String, dynamic> _$MessagingToJson(Messaging instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'reason': instance.reason,
      'description': instance.description,
      'requested_date': instance.requested_date,
      'date_start': instance.date_start,
      'date_end': instance.date_end,
      'type': instance.type,
      'notiType': instance.notiType,
      'isRead': instance.isRead,
      'state': instance.state,
      'count': instance.count,
    };
