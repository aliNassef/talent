import 'package:json_annotation/json_annotation.dart';
part 'leave.g.dart';

@JsonSerializable()
class Leave {
  int? id;
  int? leaveId;
  String? name;
  String? state;
  int? user_id;
  int? holiday_status_id;
  String? leave_type;
  int? employee_id;
  int? department_id;
  String? requestDate;
  String? date_from;
  String? date_to;
  double? number_of_days;
  String? request_date_from;
  String? request_date_to;
  int? hiddenStateId;
  String? request_date_from_period;
  int? request_unit_half; //bool
  String? holiday_type;
  int? isSync; //bool
  int? leaveReasonId;
  String? leaveReason;
  String? emergency_contact;
  String? pending_task;
  String? employee_name;
  String? previous_timeoff;
  String? previous_timeoff_duration;
  String? reason;
  int? approveById;
  String? approveByName;
  String? attachment;
  String? write_date;
  String? monthName;
  String? year;

  Leave(
      this.leaveId,
      this.name,
      this.state,
      this.user_id,
      this.holiday_status_id,
      this.leave_type,
      this.employee_id,
      this.department_id,
      this.requestDate,
      this.date_from,
      this.date_to,
      this.number_of_days,
      this.request_date_from,
      this.request_date_to,
      this.hiddenStateId,
      this.request_date_from_period,
      this.request_unit_half,
      this.holiday_type,
      this.isSync,
      this.leaveReasonId,
      this.leaveReason,
      this.emergency_contact,
      this.pending_task,
      this.employee_name,
      this.previous_timeoff,
      this.previous_timeoff_duration,
      this.reason,
      this.approveById,
      this.approveByName,
      this.attachment,
      this.write_date,
      this.monthName,
      this.year,
      // this.isRead,
      {this.id});

  factory Leave.fromJson(Map<String, dynamic> json) => _$LeaveFromJson(json);

  Map<String, dynamic> toJson() => _$LeaveToJson(this);
}
