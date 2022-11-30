import 'package:dartvcr/src/censors.dart';
import 'package:dartvcr/src/defaults.dart';
import 'package:dartvcr/src/request_elements/status.dart';
import 'package:http/http.dart' as http;
import 'package:json_annotation/json_annotation.dart';

import 'http_element.dart';

part 'response.g.dart';

@JsonSerializable(explicitToJson: true)
class Response extends HttpElement {
  @JsonKey(name: 'body')
  final String? body;

  @JsonKey(name: 'headers')
  final Map<String, String> headers;

  @JsonKey(name: 'status')
  final Status status;

  Response(this.body, this.headers, this.status) : super();

  factory Response.fromJson(Map<String, dynamic> input) =>
      _$ResponseFromJson(input);

  Map<String, dynamic> toJson() => _$ResponseToJson(this);

  static Future<http.StreamedResponse> toStream(http.Response response, Censors censors) async {
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

  static Future<http.Response> fromStream(http.StreamedResponse response, Censors censors) async {
    final body = await response.stream.toBytes();
    return http.Response.bytes(body, response.statusCode,
        request: response.request,
        headers: censors.applyHeaderCensors(response.headers),
        isRedirect: response.isRedirect,
        persistentConnection: response.persistentConnection,
        reasonPhrase: response.reasonPhrase);
  }
}
