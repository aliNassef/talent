import 'package:json_annotation/json_annotation.dart';
part 'payslip_line.g.dart';

@JsonSerializable()
class PayslipLine {
  int? id;
  int? payslipLineId;
  int? payslip_id;
  String? name;
  String? category;
  int? sequence;
  double? total;
  String? code;
  String? type;

  PayslipLine(
    this.payslipLineId,
    this.payslip_id,
    this.name,
    this.category,
    this.sequence,
    this.total,
    this.code,
    this.type, {
    this.id,
  });

  factory PayslipLine.fromJson(Map<String, dynamic> json) =>
      _$PayslipLineFromJson(json);

  Map<String, dynamic> toJson() => _$PayslipLineToJson(this);
}
