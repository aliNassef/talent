import 'package:json_annotation/json_annotation.dart';
part 'notification.g.dart';

@JsonSerializable()
class AppNotification {
  int? id;
  String? notificationId;
  String? title;
  String? body;
  String? model;
  int? orderId;
  String? currentTime;
  int? isRead;

  AppNotification(this.notificationId, this.title,this.body,this.model,this.orderId,this.currentTime, this.isRead,
      {this.id});

  factory AppNotification.fromJson(Map<String, dynamic> json) => _$AppNotificationFromJson(json);

  Map<String, dynamic> toJson() => _$AppNotificationToJson(this);
}
