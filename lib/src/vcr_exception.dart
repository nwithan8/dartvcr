/// An exception throw when an error occurs in the VCR.
class VCRException implements Exception {
  /// The message of the exception.
  final String message;

  /// Creates a new [VCRException] with the given [message].
  VCRException(this.message);

  /// Return a string representation of this exception.
  @override
  String toString() => message;
}
