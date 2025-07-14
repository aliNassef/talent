import 'package:json_annotation/json_annotation.dart';
part 'leave_remain.g.dart';

@JsonSerializable()
class LeaveRemain {
  int? id;
  int? leaveRemainId;
  String? name;
  double? remaining_days;
  String? code;
  double? total_days;

  LeaveRemain(
    this.leaveRemainId,
    this.name,
    this.remaining_days,
    this.code,
    this.total_days,
     {
    this.id,
  });

  factory LeaveRemain.fromJson(Map<String, dynamic> json) =>
      _$LeaveRemainFromJson(json);

  Map<String, dynamic> toJson() => _$LeaveRemainToJson(this);
}
