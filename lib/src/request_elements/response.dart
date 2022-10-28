import 'dart:convert';

import 'package:dartvcr/src/request_elements/status.dart';
import 'package:json_annotation/json_annotation.dart';

import 'http_element.dart';

part 'response.g.dart';

@JsonSerializable(explicitToJson: true)
class Response extends HttpElement {
  @JsonKey(name: 'body')
  final String? body;

  @JsonKey(name: 'headers')
  final Map<String, String>? headers;

  @JsonKey(name: 'status')
  final Status status;

  Response(this.body, this.headers, this.status) : super();

  factory Response.fromJson(Map<String, dynamic> input) =>
      _$ResponseFromJson(input);

  Map<String, dynamic> toJson() => _$ResponseToJson(this);
}
