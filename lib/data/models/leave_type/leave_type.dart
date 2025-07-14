import 'package:json_annotation/json_annotation.dart';
part 'leave_type.g.dart';

@JsonSerializable()
class LeaveType {
  int? id;
  int? leave_type_id;
  String? name;
  int? company_id;
  int? responsible_id;
  //  String? validity_start;
  //  String? validity_stop;
  int? unpaid; //bool
  //  String? allocation_type;
  double? number_of_days;
  String? request_unit;
  String? holiday_type;
  String? leave_type_code;

  LeaveType(
      this.leave_type_id,
      this.name,
      this.company_id,
      this.responsible_id,
      this.unpaid,
      this.number_of_days,
      this.request_unit,
      this.holiday_type,
      this.leave_type_code,
      {this.id});

  factory LeaveType.fromJson(Map<String, dynamic> json) =>
      _$LeaveTypeFromJson(json);

  Map<String, dynamic> toJson() => _$LeaveTypeToJson(this);
}
