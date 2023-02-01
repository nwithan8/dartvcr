import 'package:dartvcr/src/defaults.dart';
import 'package:http/http.dart' as http;

/// Returns true if the given [content] is a JSON map.
///
/// ```dart
/// isJsonMap({}); // true
/// isJsonMap([]); // false
/// isJsonMap(''); // false
/// ```
bool isJsonMap(dynamic content) {
  return content is Map<String, dynamic>;
}

/// Returns true if the given [content] is a JSON list.
///
/// ```dart
/// isJsonList([]); // true
/// isJsonList({}); // false
/// isJsonList(''); // false
/// ```
bool isJsonList(dynamic content) {
  return content is List<dynamic>;
}

/// Returns true if the given [response] came from a recording.
bool responseCameFromRecording(http.Response response) {
  return response.headers.containsKey(viaRecordingHeaderKey);
}
