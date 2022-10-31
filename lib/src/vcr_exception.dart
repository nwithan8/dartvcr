class VCRException implements Exception {
  final String message;

  VCRException(this.message);

  @override
  String toString() => message;
}
