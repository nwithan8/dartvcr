import 'package:dartvcr/src/advanced_options.dart';
import 'package:dartvcr/src/dartvcr_client.dart';

import 'cassette.dart';
import 'mode.dart';

class VCR {
  Cassette? _currentCassette;

  Mode mode;

  AdvancedOptions? advancedOptions;

  VCR({this.advancedOptions})
      : mode = Mode.bypass;

  String? get cassetteName => _currentCassette?.name;

  DartVCRClient get client => _currentCassette == null
      ? throw Exception('No cassette is loaded')
      : DartVCRClient(_currentCassette!, mode,
          advancedOptions: advancedOptions ?? AdvancedOptions());

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
