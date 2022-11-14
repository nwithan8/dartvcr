import 'package:dartvcr/src/vcr_exception.dart';

import 'mode.dart';

enum ExpirationAction {
  warn,
  throwException,
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
