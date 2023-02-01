import 'dart:convert';

import 'package:dartvcr/src/request_elements/request.dart';
import 'package:dartvcr/src/censors.dart';

import 'censor_element.dart';

/// A class representing a set of rules to determine if two requests match.
class MatchRules {
  /// The list of rules that will be used to match requests.
  final List<MatchRule> _rules;

  /// Creates a new [MatchRules].
  ///
  /// ```dart
  /// MatchRules rules = MatchRules();
  /// ```
  MatchRules() : _rules = [];

  /// A pre-configured set of rules that will match requests based on the full URL and method.
  static MatchRules get defaultMatchRules {
    return MatchRules().byMethod().byFullUrl(preserveQueryOrder: false);
  }

  /// A pre-configured set of rules that will match requests based on the full URL, method, and body.
  static MatchRules get defaultStrictMatchRules {
    return MatchRules().byMethod().byFullUrl(preserveQueryOrder: true).byBody();
  }

  /// Returns true if the given [received] request matches the given [recorded] request based on the configured rules.
  bool requestsMatch(Request received, Request recorded) {
    if (_rules.isEmpty) {
      return true;
    }

    for (var rule in _rules) {
      if (!rule(received, recorded)) {
        return false;
      }
    }
    return true;
  }

  /// Enforces that both requests have the base URL (host).
  ///
  /// ```dart
  /// MatchRules rules = MatchRules().byBaseUrl();
  /// ```
  MatchRules byBaseUrl() {
    _by((Request received, Request recorded) {
      return received.uri.host == recorded.uri.host;
    });
    return this;
  }

  /// Enforces that both requests have the same full URL.
  ///
  /// If [preserveQueryOrder] is true, the order of the query parameters must match as well.
  /// If [preserveQueryOrder] is false, the order of the query parameters is ignored.
  ///
  /// ```dart
  /// MatchRules rules = MatchRules().byFullUrl();
  /// ```
  MatchRules byFullUrl({bool preserveQueryOrder = false}) {
    _by((Request received, Request recorded) {
      if (preserveQueryOrder) {
        return received.uri.toString() == recorded.uri.toString();
      } else {
        if (received.uri.path != recorded.uri.path) {
          return false;
        }
        Map<String, String> receivedQuery = received.uri.queryParameters;
        Map<String, String> recordedQuery = recorded.uri.queryParameters;
        if (receivedQuery.length != recordedQuery.length) {
          return false;
        }
        for (String key in receivedQuery.keys) {
          if (!recordedQuery.containsKey(key)) {
            return false;
          }
          if (receivedQuery[key] != recordedQuery[key]) {
            return false;
          }
        }
        return true;
      }
    });
    return this;
  }

  /// Enforces that both requests have the same HTTP method.
  ///
  /// ```dart
  /// MatchRules rules = MatchRules().byMethod();
  MatchRules byMethod() {
    _by((Request received, Request recorded) {
      return received.method == recorded.method;
    });
    return this;
  }

  /// Enforces that both requests have the same body.
  ///
  /// Ignore specific [ignoreElements] in the body when comparing.
  ///
  /// ```dart
  /// MatchRules rules = MatchRules().byBody();
  MatchRules byBody({List<CensorElement> ignoreElements = const []}) {
    _by((Request received, Request recorded) {
      if (received.body == null && recorded.body == null) {
        // both have null bodies, so they match
        return true;
      } else if (received.body == null || recorded.body == null) {
        // one has a null body, so they don't match
        return false;
      } else {
        String receivedBody =
            Censors.censorJsonData(received.body!, "FILTERED", ignoreElements);
        String recordedBody =
            Censors.censorJsonData(recorded.body!, "FILTERED", ignoreElements);

        if (receivedBody == recordedBody) {
          return true;
        }
      }
      return false;
    });
    return this;
  }

  /// Enforces that both requests are the exact same (headers, body, etc.).
  ///
  /// ```dart
  /// MatchRules rules = MatchRules().byEverything();
  /// ```
  MatchRules byEverything() {
    _by((Request received, Request recorded) {
      String receivedRequest = jsonEncode(received);
      String recordedRequest = jsonEncode(recorded);
      return receivedRequest == recordedRequest;
    });
    return this;
  }

  /// Enforces that both requests have the same header with the given [headerKey].
  ///
  /// ```dart
  /// MatchRules rules = MatchRules().byHeader("Content-Type");
  /// ```
  MatchRules byHeader(String headerKey) {
    _by((Request received, Request recorded) {
      if (received.headers.containsKey(headerKey) &&
          recorded.headers.containsKey(headerKey)) {
        return received.headers[headerKey] == recorded.headers[headerKey];
      } else {
        return false;
      }
    });
    return this;
  }

  /// Enforces that both requests have the same headers.
  ///
  /// If [exact] is true, then both requests must have the exact same headers.
  /// If [exact] is false, then as long as the evaluated request has all the headers of the matching request (and potentially more), the match is considered valid.
  ///
  /// ```dart
  /// MatchRules rules = MatchRules().byHeaders();
  /// ```
  MatchRules byHeaders({bool exact = false}) {
    if (exact) {
      // first, we'll check that there are the same number of headers in both requests. If they're are, then the second check is guaranteed to compare all headers.
      _by((Request received, Request recorded) {
        return received.headers.length == recorded.headers.length;
      });
    }

    // now we'll check that all headers in the evaluated request are present in the matching request.
    _by((Request received, Request recorded) {
      for (String key in received.headers.keys) {
        if (!recorded.headers.containsKey(key)) {
          return false;
        }
      }
      return true;
    });
    return this;
  }

  /// Enforces that both requests match the given [rule].
  void _by(MatchRule rule) {
    _rules.add(rule);
  }
}

/// A function that determines if two requests match.
typedef MatchRule = bool Function(Request received, Request recorded);
