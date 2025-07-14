import 'package:json_annotation/json_annotation.dart';
part 'expense_tax.g.dart';

@JsonSerializable()
class ExpenseTax {
  int? id;
  int? expenseTaxId;
  String? name;
  String? description;
  String? amount_type;
  String? type_tax_use;
  double? amount;
  String? tax_scope;
  String? write_date;

  ExpenseTax(this.expenseTaxId, this.name, this.description,this.amount_type, this.type_tax_use,this.amount,this.tax_scope ,this.write_date, {this.id});

  factory ExpenseTax.fromJson(Map<String, dynamic> json) =>
      _$ExpenseTaxFromJson(json);

  Map<String, dynamic> toJson() => _$ExpenseTaxToJson(this);
}
