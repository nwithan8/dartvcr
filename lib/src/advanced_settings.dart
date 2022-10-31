import 'package:dartvcr/src/match_rules.dart';

import 'censors.dart';

class AdvancedSettings {
  final Censors censors;

  final MatchRules matchRules;

  final int manualDelay;

  final bool simulateDelay;

  AdvancedSettings(
      {Censors? censors,
      MatchRules? matchRules,
      int? manualDelay,
      bool? simulateDelay})
      : censors = censors ?? Censors.defaultCensors,
        matchRules = matchRules ?? MatchRules.defaultMatchRules,
        manualDelay = manualDelay ?? 0,
        simulateDelay = simulateDelay ?? false;
}
