import 'package:dartvcr/src/defaults.dart';

import 'package:http/http.dart' as http;

/// Returns true if the given [content] is a JSON map.
bool isJsonMap(dynamic content) {
  return content is Map<String, dynamic>;
}

/// Returns true if the given [content] is a JSON list.
bool isJsonList(dynamic content) {
  return content is List<dynamic>;
}

/// Returns true if the given [response] is a JSON string.
bool responseCameFromRecording(http.Response response) {
  return response.headers.containsKey(viaRecordingHeaderKey);
}
