import 'package:json_annotation/json_annotation.dart';
part 'analytic_account.g.dart';

@JsonSerializable()
class AnalyticAccount {
  int? id;
  int? analyticAccountId;
  String? name;

  AnalyticAccount(this.analyticAccountId, this.name, {this.id});

  factory AnalyticAccount.fromJson(Map<String, dynamic> json) =>
      _$AnalyticAccountFromJson(json);

  Map<String, dynamic> toJson() => _$AnalyticAccountToJson(this);
}
