import 'package:dartvcr/src/advanced_settings.dart';
import 'package:dartvcr/src/easyvcr_client.dart';

import 'cassette.dart';
import 'mode.dart';

class VCR {
  Cassette? _currentCassette;

  Mode mode;

  AdvancedSettings? advancedSettings;

  VCR({this.advancedSettings})
      : mode = Mode.bypass;

  String? get cassetteName => _currentCassette?.name;

  EasyVCRClient get client => _currentCassette == null
      ? throw Exception('No cassette is loaded')
      : EasyVCRClient(_currentCassette!, mode,
          advancedSettings: advancedSettings ?? AdvancedSettings());

  void eject() {
    _currentCassette = null;
  }

  void insert(Cassette cassette) {
    _currentCassette = cassette;
  }

  void erase() {
    _currentCassette?.erase();
  }

  void pause() {
    mode = Mode.bypass;
  }

  void record() {
    mode = Mode.record;
  }

  void replay() {
    mode = Mode.replay;
  }

  void recordIfNeeded() {
    mode = Mode.auto;
  }
}
