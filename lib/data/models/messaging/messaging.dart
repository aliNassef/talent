import 'package:json_annotation/json_annotation.dart';
part 'messaging.g.dart';

@JsonSerializable()
class Messaging {
  String? id;
  String? name;
  String? reason;
  String? description;
  String? requested_date;
  String? date_start;
  String? date_end;
  String? type; // Announcement = announce, Notification = noti
  String? notiType;
  int? isRead; //bool
  String? state;
  int? count;

  Messaging(
      this.name,
      this.reason,
      this.description,
      this.requested_date,
      this.date_start,
      this.date_end,
      this.type,
      this.notiType,
      this.state,
      this.count,
      this.isRead,
      {this.id});
  factory Messaging.fromJson(Map<String, dynamic> json) =>
      _$MessagingFromJson(json);

  Map<String, dynamic> toJson() => _$MessagingToJson(this);
}
