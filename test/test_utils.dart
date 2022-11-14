import 'dart:io';

import 'package:dartvcr/src/advanced_settings.dart';
import 'package:dartvcr/src/cassette.dart';
import 'package:dartvcr/src/easyvcr_client.dart';
import 'package:dartvcr/src/match_rules.dart';
import 'package:dartvcr/src/mode.dart';
import 'package:dartvcr/src/vcr.dart';

class TestUtils {
  static Cassette getCassette(String cassetteName) {
    return Cassette(_getDirectoryInCurrentDirectory('cassettes'), cassetteName);
  }

  static EasyVCRClient getSimpleClient(String cassetteName, Mode mode) {
    Cassette cassette = getCassette(cassetteName);
    return EasyVCRClient(cassette, mode);
  }

  static VCR getSimpleVCR(Mode mode) {
    VCR vcr = VCR(advancedSettings: AdvancedSettings(
      matchRules: MatchRules.defaultStrictMatchRules
    ));

    switch (mode) {
      case Mode.record:
        vcr.record();
        break;
      case Mode.replay:
        vcr.replay();
        break;
      case Mode.auto:
        vcr.recordIfNeeded();
        break;
      case Mode.bypass:
        vcr.pause();
        break;
    }

    return vcr;
  }

  static Directory getCurrentDirectory() {
    return Directory.current;
  }

  static String _getDirectoryInCurrentDirectory(String directoryPath) {
    return '${getCurrentDirectory().path}/$directoryPath';
  }
}
