import 'package:json_annotation/json_annotation.dart';
part 'expense_product.g.dart';

@JsonSerializable()
class ExpenseProduct {
  int? id;
  int? expenseProductId;
  String? name;

  ExpenseProduct(this.expenseProductId, this.name, {this.id});

  factory ExpenseProduct.fromJson(Map<String, dynamic> json) =>
      _$ExpenseProductFromJson(json);

  Map<String, dynamic> toJson() => _$ExpenseProductToJson(this);
}
