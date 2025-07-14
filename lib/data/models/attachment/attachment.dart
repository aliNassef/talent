import 'package:json_annotation/json_annotation.dart';
part 'attachment.g.dart';

@JsonSerializable()
class Attachment {
  int? id;
  // int? attachmentId;
  // int? file_id;
  String? file_name;
  String? data;

  Attachment(this.file_name, this.data, {this.id});

  factory Attachment.fromJson(Map<String, dynamic> json) =>
      _$AttachmentFromJson(json);

  Map<String, dynamic> toJson() => _$AttachmentToJson(this);
}
