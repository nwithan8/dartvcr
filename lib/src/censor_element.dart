/// A censor element is a single element to censor from requests and responses.
class CensorElement {
  /// The name or key of the element to censor.
  final String name;

  /// Whether or not the element should be censored only when matching case exactly.
  final bool caseSensitive;

  /// Creates a new [CensorElement] with the given [name] and [caseSensitive] flag.
  ///
  /// ```dart
  /// CensorElement element = CensorElement('key', caseSensitive: true);
  /// ```
  CensorElement(this.name, {this.caseSensitive = false});

  /// Returns true if the given [key] matches this element.
  ///
  /// ```dart
  /// CensorElement element1 = CensorElement('key');
  /// element1.matches('key'); // true
  /// element1.matches('KEY'); // true
  ///
  /// CensorElement element2 = CensorElement('key', caseSensitive: true);
  /// element2.matches('key'); // true
  /// element2.matches('KEY'); // false
  /// ```
  bool matches(String key) {
    if (caseSensitive) {
      return key == name;
    } else {
      return key.toLowerCase() == name.toLowerCase();
    }
  }
}
