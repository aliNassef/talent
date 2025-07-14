// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hours.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Hours _$HoursFromJson(Map<String, dynamic> json) => Hours(
      json['key'] as String?,
      json['value'] as String?,
      json['type'] as String?,
      id: json['id'] as int?,
    );

Map<String, dynamic> _$HoursToJson(Hours instance) => <String, dynamic>{
      'id': instance.id,
      'key': instance.key,
      'value': instance.value,
      'type': instance.type,
    };
