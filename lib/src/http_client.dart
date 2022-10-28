import 'package:dartvcr/src/request_elements/http_interaction.dart';
import 'package:http/http.dart' as http;

import 'cassette.dart';
import 'mode.dart';

class HttpClient extends http.BaseClient {
  final http.Client _client;

  final Cassette _cassette;

  final Mode _mode;

  HttpClient(this._cassette, this._mode) : _client = http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    switch (_mode) {
      case Mode.record:
        // make real request, record response
        http.StreamedResponse streamedResponse = await _client.send(request);
        http.Response response = await http.Response.fromStream(streamedResponse);
        HttpInteraction interaction = HttpInteraction.fromHttpResponse(response);
        _cassette.update(interaction);
        return streamedResponse;
      case Mode.replay:
        // try to get recorded request, fallback to exception
        List<HttpInteraction> interactions = _cassette.read();
        for (HttpInteraction interaction in interactions) {
          if (interaction.request.uri == request.url) {
            return interaction.toStreamedResponse();
          }
        }
        throw Exception('No recorded request found for ${request.url}');
      case Mode.auto:
        // try to get recorded request, fallback to live request + record
        List<HttpInteraction> interactions = _cassette.read();
        for (HttpInteraction interaction in interactions) {
          if (interaction.request.uri == request.url) {
            return interaction.toStreamedResponse();
          }
        }
        http.StreamedResponse streamedResponse = await _client.send(request);
        http.Response response = await http.Response.fromStream(streamedResponse);
        HttpInteraction interaction = HttpInteraction.fromHttpResponse(response);
        _cassette.update(interaction);
        return streamedResponse;
      case Mode.bypass:
        // make real request, don't record response
        return _client.send(request);
    }
  }
}
