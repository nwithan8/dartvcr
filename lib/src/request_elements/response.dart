import 'package:dartvcr/src/censors.dart';
import 'package:dartvcr/src/request_elements/status.dart';
import 'package:http/http.dart' as http;
import 'package:json_annotation/json_annotation.dart';

import 'http_element.dart';

part 'response.g.dart';

/// A class that represents an HTTP response.
@JsonSerializable(explicitToJson: true)
class Response extends HttpElement {
  /// The body of the response.
  @JsonKey(name: 'body')
  final String? body;

  /// The headers of the response.
  @JsonKey(name: 'headers')
  final Map<String, String> headers;

  /// The HTTP status of the response.
  @JsonKey(name: 'status')
  final Status status;

  /// Creates a new [Response] with the given [body], [headers], and [status].
  Response(this.body, this.headers, this.status) : super();

  /// Creates a new [Response] from a JSON map.
  factory Response.fromJson(Map<String, dynamic> input) =>
      _$ResponseFromJson(input);

  /// Converts this [Response] to a JSON map.
  @override
  Map<String, dynamic> toJson() => _$ResponseToJson(this);

  /// Creates a new [http.StreamedResponse] from a [http.Response] and [Censors] rules.
  static Future<http.StreamedResponse> toStream(
      http.Response response, Censors censors) async {
    Map<String, String> headers = response.headers;
    headers = censors.applyHeaderCensors(headers);

    return http.StreamedResponse(
      Stream.fromIterable([response.bodyBytes]),
      response.statusCode,
      request: response.request,
      headers: headers,
      isRedirect: response.isRedirect,
      persistentConnection: response.persistentConnection,
      reasonPhrase: response.reasonPhrase,
    );
  }

  /// Creates a new [http.Response] from a [http.StreamedResponse] and [Censors] rules.
  static Future<http.Response> fromStream(
      http.StreamedResponse response, Censors censors) async {
    final body = await response.stream.toBytes();
    return http.Response.bytes(body, response.statusCode,
        request: response.request,
        headers: censors.applyHeaderCensors(response.headers),
        isRedirect: response.isRedirect,
        persistentConnection: response.persistentConnection,
        reasonPhrase: response.reasonPhrase);
  }
}
