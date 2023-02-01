import 'package:dartvcr/src/advanced_options.dart';
import 'package:dartvcr/src/defaults.dart';
import 'package:dartvcr/src/expiration_actions.dart';
import 'package:dartvcr/src/request_elements/http_interaction.dart';
import 'package:dartvcr/src/request_elements/request.dart';
import 'package:dartvcr/src/request_elements/response.dart';
import 'package:dartvcr/src/vcr_exception.dart';
import 'package:http/http.dart' as http;

import 'cassette.dart';
import 'mode.dart';

/// A [http.BaseClient] that records and replays HTTP interactions.
class DartVCRClient extends http.BaseClient {
  /// The internal [http.Client] that will be used to make requests.
  final http.Client _client;

  /// The [Cassette] the client will use during requests.
  final Cassette _cassette;

  /// The [Mode] the client will use during requests.
  final Mode _mode;

  /// The [AdvancedOptions] the client will use during requests.
  final AdvancedOptions _advancedOptions;

  /// Creates a new [DartVCRClient] with the given [Cassette], [Mode] and [AdvancedOptions].
  ///
  /// ```dart
  /// final client = DartVCRClient(
  ///  cassette: Cassette(),
  ///  mode: Mode.auto,
  ///  advancedOptions: AdvancedOptions(
  ///   censors: Censors.defaultCensors,
  ///   matchRules: MatchRules.defaultMatchRules,
  ///   manualDelay: 0,
  ///   simulateDelay: false,
  ///   validTimeFrame: TimeFrame.forever,
  ///   whenExpired: ExpirationAction.warn,
  ///  ),
  /// );
  DartVCRClient(this._cassette, this._mode, {AdvancedOptions? advancedOptions})
      : _client = http.Client(),
        _advancedOptions = advancedOptions ?? AdvancedOptions();

  /// Simulates an HTTP request and response.
  ///
  /// Makes a real request and records the response if the [Mode] is [Mode.record].
  /// Drops the request and returns a recorded response if the [Mode] is [Mode.replay].
  /// Makes a real request and returns the real response if the [Mode] is [Mode.bypass].
  /// Either makes a real request and records the response, or drops the request and returns a recorded response if the [Mode] is [Mode.auto].
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
          throw VCRException(
              "No matching interaction found for request ${request.method} ${request.url}");
        }
        if (_advancedOptions.validTimeFrame
            .hasLapsed(replayInteraction.recordedAt)) {
          switch (_advancedOptions.whenExpired) {
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
              throw VCRException(
                  "Cannot re-record an expired interaction in Replay mode.");
          }
        }

        // simulate delay if configured
        await _simulateDelay(replayInteraction);
        // return matching interaction's response
        return replayInteraction.toStreamedResponse(_advancedOptions.censors);

      case Mode.auto:
        // try to get recorded request, fallback to live request + record
        HttpInteraction? replayInteraction = _findMatchingInteraction(request);
        if (replayInteraction != null) {
          // found a matching interaction
          if (_advancedOptions.validTimeFrame
              .hasLapsed(replayInteraction.recordedAt)) {
            // interaction has expired
            switch (_advancedOptions.whenExpired) {
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
          await _simulateDelay(replayInteraction);
          // return matching interaction's response
          return replayInteraction.toStreamedResponse(_advancedOptions.censors);
        }

        // no matching interaction found, make real request, record response
        return _recordRequestAndResponse(request);

      case Mode.bypass:
        // make real request, don't record response
        return _client.send(request);
    }
  }

  /// Finds a matching recorded [HttpInteraction] for the given [http.BaseRequest].
  HttpInteraction? _findMatchingInteraction(http.BaseRequest request) {
    List<HttpInteraction> interactions = _cassette.read();

    Request receivedRequest =
        Request.fromHttpRequest(request, _advancedOptions.censors);

    try {
      return interactions.firstWhere((interaction) => _advancedOptions
          .matchRules
          .requestsMatch(receivedRequest, interaction.request));
    } catch (e) {
      return null;
    }
  }

  /// Makes a real request and records the response.
  Future<http.StreamedResponse> _recordRequestAndResponse(
      http.BaseRequest request) async {
    Stopwatch stopwatch = Stopwatch();
    stopwatch.start();
    http.StreamedResponse streamedResponse = await _client.send(request);
    stopwatch.stop();
    http.Response response =
        await Response.fromStream(streamedResponse, _advancedOptions.censors);
    HttpInteraction interaction =
        HttpInteraction.fromHttpResponse(response, _advancedOptions.censors);
    interaction.duration = stopwatch
        .elapsedMilliseconds; // add duration to interaction before saving
    interaction.response.headers.addAll(
        replayHeaders); // add replay headers to interaction before saving
    _cassette.update(interaction);

    // need to rebuild a new streamedResponse since this one has already been read
    return Response.toStream(response, _advancedOptions.censors);
  }

  /// Simulates an HTTP delay if configured to do so.
  Future _simulateDelay(HttpInteraction interaction) async {
    int delay = 0;
    if (_advancedOptions.simulateDelay == true) {
      // original delay takes precedence
      delay = interaction.duration;
    } else {
      // otherwise use manual delay
      delay = _advancedOptions.manualDelay;
    }
    await Future.delayed(Duration(milliseconds: delay));
  }
}
