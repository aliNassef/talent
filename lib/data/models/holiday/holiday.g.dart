// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'holiday.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Holiday _$HolidayFromJson(Map<String, dynamic> json) => Holiday(
      json['holidayId'] as int?,
      json['name'] as String?,
      json['date_from'] as String?,
      json['date_to'] as String?,
      json['write_date'] as String?,
      id: json['id'] as int?,
    );

Map<String, dynamic> _$HolidayToJson(Holiday instance) => <String, dynamic>{
      'id': instance.id,
      'holidayId': instance.holidayId,
      'name': instance.name,
      'date_from': instance.date_from,
      'date_to': instance.date_to,
      'write_date': instance.write_date,
    };
