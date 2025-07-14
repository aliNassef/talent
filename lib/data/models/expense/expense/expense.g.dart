// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Expense _$ExpenseFromJson(Map<String, dynamic> json) => Expense(
      json['expenseId'] as int?,
      json['description'] as String?,
      json['date'] as String?,
      json['billRef'] as String?,
      json['expenseProductId'] as int?,
      json['expenseProductName'] as String?,
      (json['unitPrice'] as num?)?.toDouble(),
      (json['qty'] as num?)?.toDouble(),
      (json['total'] as num?)?.toDouble(),
      json['paidBy'] as String?,
      json['note'] as String?,
      json['state'] as String?,
      json['isSync'] as int?,
      json['analyticAccountId'] as int?,
      json['attachment'] as String?,
      id: json['id'] as int?,
    );

Map<String, dynamic> _$ExpenseToJson(Expense instance) => <String, dynamic>{
      'id': instance.id,
      'expenseId': instance.expenseId,
      'description': instance.description,
      'date': instance.date,
      'billRef': instance.billRef,
      'expenseProductId': instance.expenseProductId,
      'expenseProductName': instance.expenseProductName,
      'unitPrice': instance.unitPrice,
      'qty': instance.qty,
      'total': instance.total,
      'paidBy': instance.paidBy,
      'note': instance.note,
      'state': instance.state,
      'isSync': instance.isSync,
      'analyticAccountId': instance.analyticAccountId,
      'attachment': instance.attachment,
    };
