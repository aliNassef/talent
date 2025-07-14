import 'package:json_annotation/json_annotation.dart';
part 'expense.g.dart';

@JsonSerializable()
class Expense {
  int? id;
  int? expenseId;
  String? description;
  String? date;
  String? billRef;
  int? expenseProductId;
  String? expenseProductName;
  double? unitPrice;
  double? qty;
  double? total;
  String? paidBy;
  String? note;
  String? state;
  int? isSync;
  int? analyticAccountId;
  String? attachment;


  Expense(
      this.expenseId,
      this.description,
      this.date,
      this.billRef,
      this.expenseProductId,
      this.expenseProductName,
      this.unitPrice,
      this.qty,
      this.total,
      this.paidBy,
      this.note,
      this.state,
      this.isSync,
      this.analyticAccountId,
      this.attachment,
      {this.id});

  factory Expense.fromJson(Map<String, dynamic> json) =>
      _$ExpenseFromJson(json);

  Map<String, dynamic> toJson() => _$ExpenseToJson(this);
}
