import 'package:dartvcr/src/censors.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:http/http.dart' as http;

import '../internal_utilities/content_type.dart';
import 'http_element.dart';

part 'request.g.dart';

/// A class that represents a single HTTP request.
@JsonSerializable(explicitToJson: true)
class Request extends HttpElement {
  /// The body of the request.
  @JsonKey(name: 'body')
  final String? body;

  /// The headers of the request.
  @JsonKey(name: 'headers')
  final Map<String, String> headers;

  /// The HTTP method of the request.
  @JsonKey(name: 'method')
  final String method;

  /// The URI of the request.
  @JsonKey(name: 'uri')
  final Uri uri;

  /// Creates a new [Request] with the given [body], [headers], [method], and [uri].
  Request(this.body, this.headers, this.method, this.uri) : super();

  /// Creates a new [Request] from a JSON map.
  factory Request.fromJson(Map<String, dynamic> input) =>
      _$RequestFromJson(input);

  /// Converts this [Request] to a JSON map.
  @override
  Map<String, dynamic> toJson() => _$RequestToJson(this);

  /// Creates a new [Request] from a [http.BaseRequest] and [Censors] rules.
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
