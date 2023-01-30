import 'package:json_annotation/json_annotation.dart';

import 'http_element.dart';

part 'status.g.dart';

@JsonSerializable(explicitToJson: true)
class Status extends HttpElement {
  @JsonKey(name: 'code')
  final int? code;

  @JsonKey(name: 'message')
  final String? message;

  Status(this.code, this.message) : super();

  factory Status.fromJson(Map<String, dynamic> input) =>
      _$StatusFromJson(input);

  @override
  Map<String, dynamic> toJson() => _$StatusToJson(this);
}
