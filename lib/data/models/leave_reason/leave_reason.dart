import 'package:json_annotation/json_annotation.dart';
part 'leave_reason.g.dart';

@JsonSerializable()
class LeaveReason{

   int? id;
   int? leaveReasonId;
   String? name;
   String? writeDate;

  LeaveReason(this.leaveReasonId,this.name,this.writeDate,{this.id,});

  
  factory LeaveReason.fromJson(Map<String, dynamic> json) =>
      _$LeaveReasonFromJson(json);

  Map<String, dynamic> toJson() => _$LeaveReasonToJson(this);
}