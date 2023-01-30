import 'package:dartvcr/src/censors.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:http/http.dart' as http;

import '../internal_utilities/content_type.dart';
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

  @override
  Map<String, dynamic> toJson() => _$RequestToJson(this);

  factory Request.fromHttpRequest(http.BaseRequest request, Censors censors) {
    String body = "";
    try {
      body = (request as http.Request).body;
      ContentType? contentType = determineContentType(body) ?? ContentType.text;
      body = censors.applyBodyParameterCensors(body, contentType);
    } catch (e) {
      // Do nothing
    }

    String uri = request.url.toString();
    uri = censors.applyQueryCensors(uri);

    Map<String, String> headers = request.headers;
    headers = censors.applyHeaderCensors(headers);

    return Request(body, headers, request.method, Uri.parse(uri));
  }
}
