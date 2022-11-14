import 'package:dartvcr/src/advanced_settings.dart';
import 'package:dartvcr/src/expiration_actions.dart';
import 'package:dartvcr/src/request_elements/http_interaction.dart';
import 'package:dartvcr/src/request_elements/request.dart';
import 'package:dartvcr/src/request_elements/response.dart';
import 'package:dartvcr/src/vcr_exception.dart';
import 'package:http/http.dart' as http;

import 'cassette.dart';
import 'mode.dart';

class EasyVCRClient extends http.BaseClient {
  final http.Client _client;

  final Cassette _cassette;

  final Mode _mode;

  final AdvancedSettings _advancedSettings;

  EasyVCRClient(this._cassette, this._mode, {AdvancedSettings? advancedSettings})
      : _client = http.Client(),
        _advancedSettings = advancedSettings ?? AdvancedSettings();


  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    switch (_mode) {

      case Mode.record:
        // make real request, record response
        return _recordRequestAndResponse(request);

      case Mode.replay:
        // try to get recorded request, fallback to exception
        HttpInteraction? replayInteraction = _findMatchingInteraction(request);
        if (replayInteraction == null) {
          throw VCRException("No matching interaction found for request ${request.method} ${request.url}");
        }
        if (_advancedSettings.validTimeFrame.hasLapsed(replayInteraction.recordedAt)) {
          switch (_advancedSettings.whenExpired) {
            case ExpirationAction.warn:
              // just throw a warning
              // will still simulate delay below
              print("WARNING: Matching interaction has expired");
              break;
            case ExpirationAction.throwException:
              // throw an exception and exit this function
              throw VCRException("Matching interaction has expired");
            case ExpirationAction.recordAgain:
              // we should never get here, the settings check should catch this during construction
              throw VCRException("Cannot re-record an expired interaction in Replay mode.");
          }
        }

        // simulate delay if configured
        _simulateDelay(replayInteraction);
        // return matching interaction's response
        return replayInteraction.toStreamedResponse();

      case Mode.auto:
        // try to get recorded request, fallback to live request + record
        HttpInteraction? replayInteraction = _findMatchingInteraction(request);
        if (replayInteraction != null) {
          // found a matching interaction
          if (_advancedSettings.validTimeFrame.hasLapsed(replayInteraction.recordedAt)) {
            // interaction has expired
            switch (_advancedSettings.whenExpired) {
              case ExpirationAction.warn:
                // just throw a warning
                // will still simulate delay below
                print("WARNING: Matching interaction has expired");
                break;
              case ExpirationAction.throwException:
                // throw an exception and exit this function
                throw VCRException("Matching interaction has expired");
              case ExpirationAction.recordAgain:
                //  re-record over expired interaction
                // this will not execute the simulated delay, but since it's making a live request, a real delay will happen.
                return _recordRequestAndResponse(request);
            }
          }
          // simulate delay if configured
          _simulateDelay(replayInteraction);
          // return matching interaction's response
          return replayInteraction.toStreamedResponse();
        }

        // no matching interaction found, make real request, record response
        return _recordRequestAndResponse(request);

      case Mode.bypass:
        // make real request, don't record response
        return _client.send(request);
    }
  }

  HttpInteraction? _findMatchingInteraction(http.BaseRequest request) {
    List<HttpInteraction> interactions = _cassette.read();

    Request receivedRequest = Request.fromHttpRequest(request, _advancedSettings.censors);

    try {
      return interactions.firstWhere((interaction) => _advancedSettings.matchRules.requestsMatch(receivedRequest, interaction.request));
    } catch (e) {
      return null;
    }
  }

  Future<http.StreamedResponse> _recordRequestAndResponse(http.BaseRequest request) async {
    Stopwatch stopwatch = Stopwatch();
    stopwatch.start();
    http.StreamedResponse streamedResponse = await _client.send(request);
    stopwatch.stop();
    http.Response response = await Response.fromStream(streamedResponse);
    HttpInteraction interaction = HttpInteraction.fromHttpResponse(response);
    interaction.duration = stopwatch.elapsedMilliseconds;
    _cassette.update(interaction);

    // need to rebuild a new streamedResponse since this one has already been read
    return Response.toStream(response);
  }

  void _simulateDelay(HttpInteraction interaction) async {
    if (_advancedSettings.simulateDelay) {
      int delay = 0;
      if (_advancedSettings.simulateDelay == true) {
        // original delay takes precedence
        delay = interaction.duration;
      } else {
        // otherwise use manual delay
        delay = _advancedSettings.manualDelay;
      }
      await Future.delayed(Duration(milliseconds: delay));
    }
  }
}
