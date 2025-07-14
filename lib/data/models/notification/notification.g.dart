// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppNotification _$AppNotificationFromJson(Map<String, dynamic> json) =>
    AppNotification(
      json['notificationId'] as String?,
      json['title'] as String?,
      json['body'] as String?,
      json['model'] as String?,
      json['orderId'] as int?,
      json['currentTime'] as String?,
      json['isRead'] as int?,
      id: json['id'] as int?,
    );

Map<String, dynamic> _$AppNotificationToJson(AppNotification instance) =>
    <String, dynamic>{
      'id': instance.id,
      'notificationId': instance.notificationId,
      'title': instance.title,
      'body': instance.body,
      'model': instance.model,
      'orderId': instance.orderId,
      'currentTime': instance.currentTime,
      'isRead': instance.isRead,
    };
