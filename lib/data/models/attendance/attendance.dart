import 'package:json_annotation/json_annotation.dart';
part 'attendance.g.dart';

@JsonSerializable()
class Attendance {
  int? id;
  int? attendanceId;
  String? name;
  int? employee_id;
  int? user_id;
  String? date;
  String? check_in_datetime;
  String? check_out_datetime;
  String? check_in_time;
  String? check_out_time;
  String? working_hr;
  double? in_latitude;
  double? in_longitude;
  double? out_latitude;
  double? out_longitude;
  String? in_location;
  String? out_location;
  String? device_id;
  String? reason;
  String? write_date;
  String? att_type;
  String? checkInSelfie;
  String? checkOutSelfie;

  Attendance(
      this.attendanceId,
      this.name,
      this.employee_id,
      this.user_id,
      this.date,
      this.check_in_datetime,
      this.check_out_datetime,
      this.check_in_time,
      this.check_out_time,
      this.working_hr,
      this.in_latitude,
      this.in_longitude,
      this.out_latitude,
      this.out_longitude,
      this.in_location,
      this.out_location,
      this.device_id,
      this.reason,
      this.write_date,
      this.att_type,
      this.checkInSelfie,
      this.checkOutSelfie,
      {this.id});

  factory Attendance.fromJson(Map<String, dynamic> json) =>
      _$AttendanceFromJson(json);

  Map<String, dynamic> toJson() => _$AttendanceToJson(this);
}
