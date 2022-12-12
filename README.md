# DartVCR

[![Pub](https://img.shields.io/pub/v/dartvcr)](https://pub.dev/packages/dartvcr)

DartVCR is a library for recording and replaying HTTP interactions in your test suite. Port of [EasyVCR](https://github.com/EasyPost/easyvcr-csharp) for Dart.

This can be useful for speeding up your test suite, or for running your tests on a CI server which doesn't have
connectivity to the HTTP endpoints you need to interact with.

## How to use DartVCR

#### Step 1.

Run your test suite locally against a real HTTP endpoint in recording mode

```dart
import 'package:dartvcr/dartvcr.dart';

// Create a cassette to handle HTTP interactions
var cassette = Cassette("path/to/cassettes", "my_cassette");

// create an DartVCRClient using the cassette
DartVCRClient client = DartVCRClient(cassette, Mode.record);

// Use this DartVCRClient in any class making HTTP calls
// Note: DartVCRClient extends BaseClient from the 'http/http' package, so it can be used anywhere a BaseClient is expected
var response = await client.post(Uri.parse('https://api.example.com/v1/users'));
```

Real HTTP calls will be made and recorded to the cassette file.

#### Step 2.

Switch to replay mode:

```dart
import 'package:dartvcr/dartvcr.dart';

// Create a cassette to handle HTTP interactions
var cassette = Cassette("path/to/cassettes", "my_cassette");

// create an DartVCRClient using the cassette
DartVCRClient client = DartVCRClient(cassette, Mode.replay);
```

Now when tests are run, no real HTTP calls will be made. Instead, the HTTP responses will be replayed from the cassette
file.

### Available modes

- `Mode.auto`:  Play back a request if it has been recorded before, or record a new one if not. (default mode for `VCR`)
- `Mode.record`: Record a request, including overwriting any existing matching recording.
- `Mode.replay`: Replay a request. Throws an exception if no matching recording is found.
- `Mode.bypass`:  Do not record or replay any requests (client will behave like a normal BaseClient).

## Features

`DartVCR` comes with a number of features, many of which can be customized via the `AdvancedOptions` class.

### Censoring

Censor sensitive data in the request and response bodies and headers, such as API keys and auth tokens.

NOTE: This feature currently only works on JSON response bodies.

**Default**: *Disabled*

```dart
import 'package:dartvcr/dartvcr.dart';

var cassette = Cassette("path/to/cassettes", "my_cassette");

var censors = Censors().censorHeaderElementsByKeys(["authorization"]); // Hide the Authorization header
censors.censorBodyElements([CensorElement("table", caseSensitive: true)]); // Hide the table element (case sensitive) in the request and response body

var advancedOptions = AdvancedOptions(censors: censors);

var client = DartVCRClient(cassette, Mode.record, advancedOptions: advancedOptions);
```

### Delay

Simulate a delay when replaying a recorded request, either using a specified delay or the original request duration.

NOTE: Delays may suffer from a small margin of error. Do not rely on the delay being exact down to the millisecond.

**Default**: *No delay*

```dart
import 'package:dartvcr/dartvcr.dart';

var cassette = Cassette("path/to/cassettes", "my_cassette");

// Simulate a delay of the original request duration when replaying (overrides ManualDelay)
// Simulate a delay of 1000 milliseconds when replaying
var advancedOptions = AdvancedOptions(simulateDelay: true, manualDelay: 1000);

var client = DartVCRClient(cassette, Mode.replay, advancedOptions: advancedOptions);
```

### Expiration

Set expiration dates for recorded requests, and decide what to do with expired recordings.

**Default**: *No expiration*

```dart
import 'package:dartvcr/dartvcr.dart';

var cassette = Cassette("path/to/cassettes", "my_cassette");

// Any matching request is considered expired if it was recorded more than 30 days ago
// Throw exception if the recording is expired
var advancedOptions = AdvancedOptions(validTimeFrame: TimeFrame(days: 30), whenExpired: ExpirationAction.throwException);

var client = DartVCRClient(cassette, Mode.replay, advancedOptions: advancedOptions);
```

### Matching

Customize how a recorded request is determined to be a match to the current request.

**Default**: *Method and full URL must match*

```dart
import 'package:dartvcr/dartvcr.dart';

var cassette = Cassette("path/to/cassettes", "my_cassette");

// Match recorded requests by body and a specific header
var matchRules = MatchRules().byBody().byHeader("x-my-header");
var advancedOptions = AdvancedOptions(matchRules: matchRules);

var client = DartVCRClient(cassette, Mode.replay, advancedOptions: advancedOptions);
```

## VCR

In addition to individual recordable HttpClient instances, `DartVCR` also offers a built-in VCR, which can be used to
easily switch between multiple cassettes and/or modes. Any advanced settings applied to the VCR will be applied on every
request made using the VCR's HttpClient.

```dart
import 'package:dartvcr/dartvcr.dart';

// hide the api_key query parameter
var advancedOptions = AdvancedOptions(censors: Censors().censorQueryElementsByKeys(["api_key"]));

// create a VCR with the advanced options applied
var vcr = VCR(advancedOptions: advancedOptions);

// create a cassette and add it to the VCR
var cassette = Cassette("path/to/cassettes", "my_cassette");
vcr.insert(cassette);

// set the VCR to record mode
vcr.record();

// get a client configured to use the VCR
var client = vcr.client;

// make a request

// remove the cassette from the VCR
vcr.eject();
```

#### Credit

- [EasyVCR by EasyPost](https://github.com/easypost/easyvcr-csharp), which this library is based on.
