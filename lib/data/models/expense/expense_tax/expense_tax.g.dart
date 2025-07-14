// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense_tax.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExpenseTax _$ExpenseTaxFromJson(Map<String, dynamic> json) => ExpenseTax(
      json['expenseTaxId'] as int?,
      json['name'] as String?,
      json['description'] as String?,
      json['amount_type'] as String?,
      json['type_tax_use'] as String?,
      (json['amount'] as num?)?.toDouble(),
      json['tax_scope'] as String?,
      json['write_date'] as String?,
      id: json['id'] as int?,
    );

Map<String, dynamic> _$ExpenseTaxToJson(ExpenseTax instance) =>
    <String, dynamic>{
      'id': instance.id,
      'expenseTaxId': instance.expenseTaxId,
      'name': instance.name,
      'description': instance.description,
      'amount_type': instance.amount_type,
      'type_tax_use': instance.type_tax_use,
      'amount': instance.amount,
      'tax_scope': instance.tax_scope,
      'write_date': instance.write_date,
    };
