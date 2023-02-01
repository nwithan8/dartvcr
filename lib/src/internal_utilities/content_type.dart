/// The various content types available.
enum ContentType {
  /// JSON content type.
  json,

  /// XML content type.
  xml,

  /// Text content type.
  text,

  /// HTML content type.
  html,
}

/// Determines the content type from the given [content].
///
/// Returns the [ContentType] if the content type can be determined.
/// Returns null if the content type cannot be determined.
///
/// ```dart
/// determineContentType("{\"key\": \"value\"}"); // ContentType.json
/// determineContentType("<xml></xml>"); // ContentType.xml
/// determineContentType("<!DOCTYPE html><html></html>"); // ContentType.html
/// determineContentType("text"); // ContentType.text
/// determineContentType(""); // null
/// ```
ContentType? determineContentType(String content) {
  if (content.isEmpty) {
    return null;
  }

  if (isJson(content)) {
    return ContentType.json;
  } else if (isXml(content)) {
    return ContentType.xml;
  } else if (isHtml(content)) {
    return ContentType.html;
  } else {
    return ContentType.text;
  }
}

/// Converts the given [contentType] string to a [ContentType].
///
/// ```dart
/// fromString("{\"key\": \"value\"}"); // ContentType.json
/// fromString("<xml></xml>"); // ContentType.xml
/// fromString("<!DOCTYPE html><html></html>"); // ContentType.html
/// fromString("text"); // ContentType.text
/// fromString(null); // null
/// ```
ContentType? fromString(String? contentType) {
  if (contentType == null) {
    return null;
  }

  String contentTypeString = contentType.toLowerCase();

  switch (contentTypeString) {
    case "json":
      return ContentType.json;
    case "xml":
      return ContentType.xml;
    case "html":
      return ContentType.html;
    default:
      return ContentType.text;
  }
}

/// Checks if the given [content] is JSON.
///
/// Returns true if the content is JSON, false otherwise.
///
/// ```dart
/// isJson("{\"key\": \"value\"}"); // true
/// isJson("text"); // false
/// ```
bool isJson(String content) {
  return content.startsWith("{") || content.startsWith("[");
}

/// Checks if the given [content] is XML.
///
/// Returns true if the content is XML, false otherwise.
///
/// ```dart
/// isXml("<xml></xml>"); // true
/// isXml("text"); // false
/// ```
bool isXml(String content) {
  return content.startsWith("<") && content.endsWith(">");
}

/// Checks if the given [content] is HTML.
///
/// Returns true if the content is HTML, false otherwise.
///
/// ```dart
/// isHtml("<!DOCTYPE html><html></html>"); // true
/// isHtml("text"); // false
/// ```
bool isHtml(String content) {
  return content.startsWith("<!DOCTYPE html>") && content.endsWith("</html>");
}
