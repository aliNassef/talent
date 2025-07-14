import 'package:json_annotation/json_annotation.dart';
part 'holiday.g.dart';

@JsonSerializable()
class Holiday{

    int? id;
    int? holidayId;
    String? name;
    String? date_from;
    String? date_to;
    String? write_date;

  Holiday(this.holidayId,this.name, this.date_from, this.date_to, this.write_date, {this.id});

  factory Holiday.fromJson(Map<String, dynamic> json) =>
      _$HolidayFromJson(json);

  Map<String, dynamic> toJson() => _$HolidayToJson(this);
}