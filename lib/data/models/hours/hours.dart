import 'package:json_annotation/json_annotation.dart';
part 'hours.g.dart';

@JsonSerializable()
class Hours {
  int? id;
  String? key;
  String? value;
  String? type;

  Hours(this.key, this.value, this.type, {this.id});

  factory Hours.fromJson(Map<String, dynamic> json) => _$HoursFromJson(json);

  Map<String, dynamic> toJson() => _$HoursToJson(this);
}
