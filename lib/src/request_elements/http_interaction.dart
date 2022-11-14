import 'dart:convert';

import 'package:dartvcr/src/request_elements/http_element.dart';
import 'package:dartvcr/src/request_elements/request.dart';
import 'package:dartvcr/src/request_elements/response.dart';
import 'package:dartvcr/src/request_elements/status.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:http/http.dart' as http;

part 'http_interaction.g.dart';

@JsonSerializable(explicitToJson: true)
class HttpInteraction extends HttpElement {
  @JsonKey(name: 'duration')
  int duration;

  @JsonKey(name: 'recorded_at')
  final DateTime recordedAt;

  @JsonKey(name: 'request')
  final Request request;

  @JsonKey(name: 'response')
  final Response response;

  HttpInteraction(this.duration, this.recordedAt, this.request, this.response);

  factory HttpInteraction.fromJson(Map<String, dynamic> input) =>
      _$HttpInteractionFromJson(input);

  Map<String, dynamic> toJson() => _$HttpInteractionToJson(this);

  http.StreamedResponse toStreamedResponse() {
    final streamedResponse = http.StreamedResponse(
      http.ByteStream.fromBytes(utf8.encode(response.body ?? '')),
      response.status.code ?? 200,
      reasonPhrase: response.status.message,
      contentLength: response.body?.length,
      request: http.Request(request.method, request.uri),
      headers: response.headers ?? {},
    );
    return streamedResponse;
  }

  factory HttpInteraction.fromHttpResponse(http.Response response) {
    final body = response.body;
    final headers = response.headers;
    final status = Status(response.statusCode, response.reasonPhrase);
    final request =
        Request(null, headers, response.request!.method, response.request!.url);
    return HttpInteraction(
        0, DateTime.now(), request, Response(body, headers, status));
  }
}
