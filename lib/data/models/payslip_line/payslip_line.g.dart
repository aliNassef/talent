// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payslip_line.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PayslipLine _$PayslipLineFromJson(Map<String, dynamic> json) => PayslipLine(
      json['payslipLineId'] as int?,
      json['payslip_id'] as int?,
      json['name'] as String?,
      json['category'] as String?,
      json['sequence'] as int?,
      (json['total'] as num?)?.toDouble(),
      json['code'] as String?,
      json['type'] as String?,
      id: json['id'] as int?,
    );

Map<String, dynamic> _$PayslipLineToJson(PayslipLine instance) =>
    <String, dynamic>{
      'id': instance.id,
      'payslipLineId': instance.payslipLineId,
      'payslip_id': instance.payslip_id,
      'name': instance.name,
      'category': instance.category,
      'sequence': instance.sequence,
      'total': instance.total,
      'code': instance.code,
      'type': instance.type,
    };
