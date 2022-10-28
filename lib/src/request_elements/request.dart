import 'package:json_annotation/json_annotation.dart';

import 'http_element.dart';

part 'request.g.dart';

@JsonSerializable(explicitToJson: true)
class Request extends HttpElement {
  @JsonKey(name: 'body')
  final String? body;

  @JsonKey(name: 'headers')
  final Map<String, String> headers;

  @JsonKey(name: 'method')
  final String method;

  @JsonKey(name: 'uri')
  final Uri uri;

  Request(this.body, this.headers, this.method, this.uri) : super();

  factory Request.fromJson(Map<String, dynamic> input) =>
      _$RequestFromJson(input);

  Map<String, dynamic> toJson() => _$RequestToJson(this);
}
