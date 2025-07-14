// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pay_slip.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaySlipModel _$PaySlipModelFromJson(Map<String, dynamic> json) => PaySlipModel(
      employeeName: json['employeeName'] as String,
      address: json['address'] as String,
      refrence: json['refrence'] as String,
      department: json['department'] as String,
      position: json['position'] as String,
      job_grade: json['job_grade'] as String,
      idNumber: json['idNumber'] as int,
      dateFrom: json['dateFrom'] as String,
      dateTo: json['dateTo'] as String,
      registerNum: json['registerNum'] as String,
      gross: (json['gross'] as num).toDouble(),
      net: (json['net'] as num).toDouble(),
      payLineList: json['payLineList'] as List<dynamic>,
    );

Map<String, dynamic> _$PaySlipModelToJson(PaySlipModel instance) =>
    <String, dynamic>{
      'employeeName': instance.employeeName,
      'address': instance.address,
      'refrence': instance.refrence,
      'department': instance.department,
      'position': instance.position,
      'job_grade': instance.job_grade,
      'idNumber': instance.idNumber,
      'dateFrom': instance.dateFrom,
      'dateTo': instance.dateTo,
      'registerNum': instance.registerNum,
      'gross': instance.gross,
      'net': instance.net,
      'payLineList': instance.payLineList,
    };
