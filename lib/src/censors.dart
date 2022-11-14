import 'dart:convert';

import 'package:dartvcr/src/utilities.dart';
import 'package:dartvcr/src/vcr_exception.dart';

import 'censor_element.dart';
import 'internal_utilities/content_type.dart';

class Censors {
  final String _censorString;

  final List<CensorElement> _bodyElementsToCensor;

  final List<CensorElement> _headerElementsToCensor;

  final List<CensorElement> _queryElementsToCensor;

  Censors({String censorString = "******"})
      : _censorString = censorString,
        _bodyElementsToCensor = [],
        _headerElementsToCensor = [],
        _queryElementsToCensor = [];

  Censors censorBodyElements(List<CensorElement> elements) {
    _bodyElementsToCensor.addAll(elements);
    return this;
  }

  Censors censorBodyElementsByKeys(List<String> keys,
      {bool caseSensitive = false}) {
    _bodyElementsToCensor
        .addAll(keys.map((key) => CensorElement(key, caseSensitive)));
    return this;
  }

  Censors censorHeaderElements(List<CensorElement> elements) {
    _headerElementsToCensor.addAll(elements);
    return this;
  }

  Censors censorHeaderElementsByKeys(List<String> keys,
      {bool caseSensitive = false}) {
    _headerElementsToCensor
        .addAll(keys.map((key) => CensorElement(key, caseSensitive)));
    return this;
  }

  Censors censorQueryElements(List<CensorElement> elements) {
    _queryElementsToCensor.addAll(elements);
    return this;
  }

  Censors censorQueryElementsByKeys(List<String> keys,
      {bool caseSensitive = false}) {
    _queryElementsToCensor
        .addAll(keys.map((key) => CensorElement(key, caseSensitive)));
    return this;
  }

  // TODO: Only works on JSON bodies
  String applyBodyParameterCensors(String body, ContentType contentType) {
    if (body.isEmpty) {
      // short circuit if body is empty
      return body;
    }

    if (_bodyElementsToCensor.isEmpty) {
      // short circuit if there are no censors to apply
      return body;
    }

    try {
      switch (contentType) {
        case ContentType.html:
        case ContentType.text:
          return body; // We can't censor plaintext bodies or HTML bodies
        case ContentType.xml:
          return body; // XML parsing is not supported yet, so we can't censor XML bodies
        case ContentType.json:
          return censorJsonData(body, _censorString, _bodyElementsToCensor);
        default:
          throw Exception("Unknown content type: $contentType");
      }
    } catch (e) {
      // short circuit if body is not a valid serializable type
      throw VCRException("Body is not valid serializable type");
    }
  }

  Map<String, String> applyHeaderCensors(Map<String, String> headers) {
    if (headers.isEmpty) {
      // short circuit if headers is empty
      return headers;
    }

    if (_headerElementsToCensor.isEmpty) {
      // short circuit if there are no censors to apply
      return headers;
    }

    Map<String, String> newHeaders = <String, String>{};

    headers.forEach((key, value) {
      if (elementShouldBeCensored(key, _headerElementsToCensor)) {
        newHeaders[key] = _censorString;
      } else {
        newHeaders[key] = value;
      }
    });

    return newHeaders;
  }

  String applyQueryCensors(String url) {
    if (_queryElementsToCensor.isEmpty) {
      // short circuit if there are no censors to apply
      return url;
    }

    Uri uri = Uri.parse(url);

    Map<String, dynamic> newQueryParameters = <String, dynamic>{};

    uri.queryParameters.forEach((key, value) {
      if (elementShouldBeCensored(key, _queryElementsToCensor)) {
        newQueryParameters[key] = _censorString;
      } else {
        newQueryParameters[key] = value;
      }
    });

    return Uri(
      scheme: uri.scheme,
      userInfo: uri.userInfo,
      host: uri.host,
      port: uri.port,
      path: uri.path,
      queryParameters: newQueryParameters,
    ).toString();
  }

  static String censorJsonData(
      String body, String censorString, List<CensorElement> elementsToCensor) {
    try {
      Map<String, dynamic> jsonMap = jsonDecode(body);
      Map<String, dynamic> censoredJsonMap =
          censorMap(jsonMap, censorString, elementsToCensor);
      return jsonEncode(censoredJsonMap);
    } catch (e) {
      // body is not a JSON dictionary
      try {
        List<dynamic> jsonList = jsonDecode(body);
        List<dynamic> censoredJsonList =
            censorList(jsonList, censorString, elementsToCensor);
        return jsonEncode(censoredJsonList);
      } catch (e) {
        // short circuit if body is not a JSON dictionary or JSON list
        return body;
      }
    }
  }

  static Map<String, dynamic> censorMap(Map<String, dynamic> map, String censorString,
      List<CensorElement> elementsToCensor) {
    if (elementsToCensor.isEmpty) {
      // short circuit if there are no censors to apply
      return map;
    }

    Map<String, dynamic> censoredMap = <String, dynamic>{};

    map.forEach((key, value) {
      if (elementShouldBeCensored(key, elementsToCensor)) {
        if (value == null) {
          censoredMap[key] =
              null; // don't need to worry about censoring something that's null (don't replace null with the censor string)
        } else if (isJsonMap(value)) {
          // replace with empty dictionary
          censoredMap[key] = <String, dynamic>{};
        } else if (isJsonList(value)) {
          // replace with empty list
          censoredMap[key] = <dynamic>[];
        } else {
          // replace with censor string
          censoredMap[key] = censorString;
        }
      } else {
        if (value == null) {
          censoredMap[key] =
              null; // don't need to worry about censoring something that's null (don't replace null with the censor string)
        } else if (isJsonMap(value)) {
          // recursively censor inner dictionaries
          censoredMap[key] = censorMap(value, censorString, elementsToCensor);
        } else if (isJsonList(value)) {
          // recursively censor list elements
          censoredMap[key] = censorList(value, censorString, elementsToCensor);
        } else {
          // keep value as is
          censoredMap[key] = value;
        }
      }
    });

    return censoredMap;
  }

  static List<dynamic> censorList(List<dynamic> list, String censorString,
      List<CensorElement> elementsToCensor) {
    if (elementsToCensor.isEmpty) {
      // short circuit if there are no censors to apply
      return list;
    }

    List<dynamic> censoredList = <dynamic>[];

    for (var element in list) {
      if (isJsonMap(element)) {
        // recursively censor inner dictionaries
        censoredList.add(censorMap(element, censorString, elementsToCensor));
      } else if (isJsonList(element)) {
        // recursively censor list elements
        censoredList.add(censorList(element, censorString, elementsToCensor));
      } else {
        // either a primitive or null, no censoring needed
        censoredList.add(element);
      }
    }

    return censoredList;
  }

  static bool elementShouldBeCensored(
      String foundKey, List<CensorElement> elementsToCensor) {
    return elementsToCensor.isNotEmpty &&
        elementsToCensor.any((element) => element.matches(foundKey));
  }

  static Censors get defaultCensors {
    return Censors();
  }
}
