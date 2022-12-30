import 'dart:convert';

import 'package:dartvcr/src/censors.dart';
import 'package:dartvcr/src/request_elements/http_element.dart';
import 'package:dartvcr/src/request_elements/request.dart';
import 'package:dartvcr/src/request_elements/response.dart';
import 'package:dartvcr/src/request_elements/status.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:http/http.dart' as http;

import '../internal_utilities/content_type.dart';

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

  http.StreamedResponse toStreamedResponse(Censors censors) {
    final streamedResponse = http.StreamedResponse(
      http.ByteStream.fromBytes(utf8.encode(response.body ?? '')),
      response.status.code ?? 200,
      reasonPhrase: response.status.message,
      contentLength: response.body?.length,
      request: http.Request(request.method, request.uri),
      headers: censors.applyHeaderCensors(response.headers ?? {}),
    );
    return streamedResponse;
  }

  factory HttpInteraction.fromHttpResponse(
      http.Response response, Censors censors) {
    final requestBody = ((response.request!) as http.Request).body;
    ContentType? requestBodyContentType =
        determineContentType(requestBody) ?? ContentType.text;
    final censoredRequestBody =
        censors.applyBodyParameterCensors(requestBody, requestBodyContentType);

    final responseBody = response.body;
    ContentType? responseBodyContentType =
        determineContentType(responseBody) ?? ContentType.text;
    final censoredResponseBody = censors.applyBodyParameterCensors(
        responseBody, responseBodyContentType);

    final requestHeaders = response.request!.headers;
    final censoredRequestHeaders = censors.applyHeaderCensors(requestHeaders);

    final responseHeaders = response.headers;
    final censoredResponseHeaders = censors.applyHeaderCensors(responseHeaders);

    final requestUrl = response.request!.url;
    final censorRequestUrl = censors.applyQueryCensors(requestUrl.toString());

    final requestMethod = response.request!.method;

    final status = Status(response.statusCode, response.reasonPhrase);

    final censoredRequest = Request(censoredRequestBody, censoredRequestHeaders,
        requestMethod, Uri.parse(censorRequestUrl));
    final censoredResponse =
        Response(censoredResponseBody, censoredResponseHeaders, status);

    return HttpInteraction(
        0, DateTime.now(), censoredRequest, censoredResponse);
  }
}
