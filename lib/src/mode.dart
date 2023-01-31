/// The various modes that the VCR can be in.
enum Mode {
  /// The VCR will automatically play back a cassette if it exists, otherwise it will record a new cassette.
  auto,

  /// The VCR will record a new cassette. If a cassette already exists, it will be overwritten.
  record,

  /// The VCR will play back a cassette. If a cassette does not exist, an exception will be thrown.
  replay,

  /// The VCR will not record or play back a cassette. It will make a live request to the server.
  bypass
}
