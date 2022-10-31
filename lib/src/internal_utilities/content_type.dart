enum ContentType {
  json,
  xml,
  text,
  html,
}

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

bool isJson(String content) {
  return content.startsWith("{") || content.startsWith("[");
}

bool isXml(String content) {
  return content.startsWith("<") && content.endsWith(">");
}

bool isHtml(String content) {
  return content.startsWith("<!DOCTYPE html>") && content.endsWith("</html>");
}
