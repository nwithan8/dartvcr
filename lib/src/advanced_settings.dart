import 'package:dartvcr/src/match_rules.dart';
import 'package:dartvcr/src/time_frame.dart';

import 'censors.dart';
import 'expiration_actions.dart';

class AdvancedSettings {
  final Censors censors;

  final MatchRules matchRules;

  final int manualDelay;

  final bool simulateDelay;

  final TimeFrame validTimeFrame;

  final ExpirationAction whenExpired;

  AdvancedSettings(
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
