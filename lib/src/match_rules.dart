import 'dart:convert';

import 'package:dartvcr/src/request_elements/request.dart';
import 'package:dartvcr/src/censors.dart';

import 'censor_element.dart';

class MatchRules {
  // store list of functions
  final List<MatchRule> _rules;

  MatchRules() : _rules = [];

  static MatchRules get defaultMatchRules {
    return MatchRules().byMethod().byFullUrl(preserveQueryOrder: false);
  }

  static MatchRules get defaultStrictMatchRules {
    return MatchRules().byMethod().byFullUrl(preserveQueryOrder: true).byBody();
  }

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

  MatchRules byBaseUrl() {
    _by((Request received, Request recorded) {
      return received.uri.host == recorded.uri.host;
    });
    return this;
  }

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

  MatchRules byMethod() {
    _by((Request received, Request recorded) {
      return received.method == recorded.method;
    });
    return this;
  }

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

  MatchRules byEverything() {
    _by((Request received, Request recorded) {
      String receivedRequest = jsonEncode(received);
      String recordedRequest = jsonEncode(recorded);
      return receivedRequest == recordedRequest;
    });
    return this;
  }

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

  // If true, both requests must have the exact same headers.
  // If false, as long as the evaluated request has all the headers of the matching request (and potentially more), the match is considered valid.
  MatchRules byHeaders(bool exact) {
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

  void _by(MatchRule rule) {
    _rules.add(rule);
  }
}

typedef MatchRule = bool Function(Request received, Request recorded);
