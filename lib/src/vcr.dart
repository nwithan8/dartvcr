import 'package:dartvcr/src/advanced_settings.dart';
import 'package:dartvcr/src/easyvcr_client.dart';

import 'cassette.dart';
import 'mode.dart';

class VCR {
  Cassette? _currentCassette;

  Mode _mode;

  AdvancedSettings? advancedSettings;

  VCR({this.advancedSettings})
      : _mode = Mode.bypass;

  String? get cassetteName => _currentCassette?.name;

  EasyVCRClient get client => _currentCassette == null
      ? throw Exception('No cassette is loaded')
      : EasyVCRClient(_currentCassette!, _mode,
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
    _mode = Mode.bypass;
  }

  void record() {
    _mode = Mode.record;
  }

  void replay() {
    _mode = Mode.replay;
  }

  void recordIfNeeded() {
    _mode = Mode.auto;
  }
}
