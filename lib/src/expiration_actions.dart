import 'package:dartvcr/src/vcr_exception.dart';

import 'mode.dart';

/// The various actions that can be taken when an interaction expires.
enum ExpirationAction {
  /// warn: The VCR will log a warning to the console.
  warn,

  /// throwException: The VCR will throw an exception.
  throwException,

  /// recordAgain: The VCR will silently re-record the interaction.
  recordAgain,
}

extension ExpirationActionExtension on ExpirationAction {
  void checkCompatibleSettings(ExpirationAction action, Mode mode) {
    if (action == ExpirationAction.recordAgain && mode == Mode.replay) {
      throw VCRException(
          "Cannot use the recordAgain expiration action in combination with replay mode.");
    }
  }
}
