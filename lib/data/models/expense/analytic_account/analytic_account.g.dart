// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analytic_account.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AnalyticAccount _$AnalyticAccountFromJson(Map<String, dynamic> json) =>
    AnalyticAccount(
      json['analyticAccountId'] as int?,
      json['name'] as String?,
      id: json['id'] as int?,
    );

Map<String, dynamic> _$AnalyticAccountToJson(AnalyticAccount instance) =>
    <String, dynamic>{
      'id': instance.id,
      'analyticAccountId': instance.analyticAccountId,
      'name': instance.name,
    };
