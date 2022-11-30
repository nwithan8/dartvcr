import 'package:dartvcr/src/defaults.dart';

import 'package:http/http.dart' as http;

bool isJsonMap(dynamic content) {
  return content is Map<String, dynamic>;
}

bool isJsonList(dynamic content) {
  return content is List<dynamic>;
}

bool responseCameFromRecording(http.Response response) {
  return response.headers.containsKey(viaRecordingHeaderKey);
}
