// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense_product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExpenseProduct _$ExpenseProductFromJson(Map<String, dynamic> json) =>
    ExpenseProduct(
      json['expenseProductId'] as int?,
      json['name'] as String?,
      id: json['id'] as int?,
    );

Map<String, dynamic> _$ExpenseProductToJson(ExpenseProduct instance) =>
    <String, dynamic>{
      'id': instance.id,
      'expenseProductId': instance.expenseProductId,
      'name': instance.name,
    };
