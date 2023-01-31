const String viaRecordingHeaderKey = "X-Via-DartVCR-Recording";

/// A set of default headers that will be added to all requests replayed by the VCR.
Map<String, String> get replayHeaders => {
      viaRecordingHeaderKey: "true",
    };

/// A set of common credential headers that will be hidden from recordings.
List<String> get credentialHeadersToHide => [
      "authorization",
      "cookie",
    ];

/// A set of common credential parameters that will be hidden from recordings.
List<String> get credentialParametersToHide => [
      "access_token",
      "client_id",
      "client_secret",
      "code",
      "grant_type",
      "password",
      "refresh_token",
      "username",
      "apiKey",
      "apiToken",
      "api_key",
      "api_token",
      "key",
      "secret",
      "token",
    ];
