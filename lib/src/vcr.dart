import 'package:dartvcr/src/advanced_options.dart';
import 'package:dartvcr/src/dartvcr_client.dart';

import 'cassette.dart';
import 'mode.dart';

/// A [VCR] can store consistent settings and control a cassette.
class VCR {
  /// The cassette that is currently being used.
  Cassette? _currentCassette;

  /// The mode that the VCR is currently in.
  Mode mode;

  /// The [AdvancedOptions] the VCR is currently using during requests.
  ///
  /// These options will be passed to the [DartVCRClient] when making requests.
  AdvancedOptions? advancedOptions;

  /// Creates a new [VCR] with the given [AdvancedOptions]. The [mode] defaults to [Mode.bypass].
  ///
  /// ```dart
  /// final vcr = VCR(AdvancedOptions());
  /// ```
  VCR({this.advancedOptions}) : mode = Mode.bypass;

  /// Get the name of the current [Cassette], or null if there is no cassette.
  String? get cassetteName => _currentCassette?.name;

  /// Get a configured [DartVCRClient] with the current [AdvancedOptions], [Mode] and [Cassette].
  DartVCRClient get client => _currentCassette == null
      ? throw Exception('No cassette is loaded')
      : DartVCRClient(_currentCassette!, mode,
          advancedOptions: advancedOptions ?? AdvancedOptions());

  /// Unload the current [Cassette].
  ///
  /// ```dart
  /// final vcr = VCR();
  /// vcr.insert(Cassette());
  /// vcr.eject();
  /// ```
  void eject() {
    _currentCassette = null;
  }

  /// Load a [Cassette].
  ///
  /// ```dart
  /// final vcr = VCR();
  /// vcr.insert(Cassette());
  /// ```
  void insert(Cassette cassette) {
    _currentCassette = cassette;
  }

  /// Delete all recorded interactions from the current [Cassette].
  ///
  /// ```dart
  /// final vcr = VCR();
  /// vcr.insert(Cassette());
  /// vcr.erase();
  /// ```
  void erase() {
    _currentCassette?.erase();
  }

  /// Set the [Mode] of the VCR to [Mode.bypass].
  ///
  /// ```dart
  /// final vcr = VCR();
  /// vcr.pause();
  /// ```
  void pause() {
    mode = Mode.bypass;
  }

  /// Set the [Mode] of the VCR to [Mode.record].
  ///
  /// ```dart
  /// final vcr = VCR();
  /// vcr.record();
  /// ```
  void record() {
    mode = Mode.record;
  }

  /// Set the [Mode] of the VCR to [Mode.replay].
  ///
  /// ```dart
  /// final vcr = VCR();
  /// vcr.replay();
  /// ```
  void replay() {
    mode = Mode.replay;
  }

  /// Set the [Mode] of the VCR to [Mode.auto].
  ///
  /// ```dart
  /// final vcr = VCR();
  /// vcr.recordIfNeeded();
  /// ```
  void recordIfNeeded() {
    mode = Mode.auto;
  }
}
