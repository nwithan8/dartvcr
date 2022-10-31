const String viaRecordingHeaderKey = "X-Via-EasyVCR-Recording";

Map<String, dynamic> get replayHeaders => {
      viaRecordingHeaderKey: "true",
    };

List<String> get credentialHeadersToHide => [
      "authorization",
      "cookie",
    ];

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
