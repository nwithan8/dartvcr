import 'package:dartvcr/src/http_client.dart';

import 'cassette.dart';
import 'mode.dart';

class VCR {
  Cassette? _currentCassette;

  Mode _mode;

  VCR() : _mode = Mode.bypass;

  String? get cassetteName => _currentCassette?.name;

  HttpClient get client => _currentCassette == null
      ? throw Exception('No cassette is loaded')
      : HttpClient(_currentCassette!, _mode);

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
