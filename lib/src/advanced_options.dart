import 'package:dartvcr/src/match_rules.dart';
import 'package:dartvcr/src/time_frame.dart';

import 'censors.dart';
import 'expiration_actions.dart';

/// A collection of configuration options that can be used when recording and replaying requests.
class AdvancedOptions {
  /// A collection of censor rules that will be applied to the request and response bodies.
  final Censors censors;

  /// The rules that will be used to match requests to recorded requests.
  final MatchRules matchRules;

  /// The number of milliseconds to delay before returning a response.
  final int manualDelay;

  /// If true, a replayed request will be delayed by the same amount of time it took to make the original live request.
  final bool simulateDelay;

  /// The time frame during which a request can be replayed.
  ///
  /// If the request is replayed outside of this time frame, the [whenExpired] action will be taken.
  final TimeFrame validTimeFrame;

  /// The action to take when a request is replayed outside of the [validTimeFrame].
  final ExpirationAction whenExpired;

  /// Creates a new [AdvancedOptions].
  ///
  /// ```dart
  /// final options = AdvancedOptions(
  ///  censors: Censors.defaultCensors,
  ///  matchRules: MatchRules.defaultMatchRules,
  ///  manualDelay: 0,
  ///  simulateDelay: false,
  ///  validTimeFrame: TimeFrame.forever,
  ///  whenExpired: ExpirationAction.warn,
  /// );
  AdvancedOptions(
      {Censors? censors,
      MatchRules? matchRules,
      int? manualDelay,
      bool? simulateDelay,
      TimeFrame? validTimeFrame,
      ExpirationAction? whenExpired})
      : censors = censors ?? Censors.defaultCensors,
        matchRules = matchRules ?? MatchRules.defaultMatchRules,
        manualDelay = manualDelay ?? 0,
        simulateDelay = simulateDelay ?? false,
        validTimeFrame = validTimeFrame ?? TimeFrame.forever,
        whenExpired = whenExpired ?? ExpirationAction.warn;
}
