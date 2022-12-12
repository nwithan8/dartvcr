import 'dart:math';

import 'package:dartvcr/dartvcr.dart';
import 'package:test/test.dart';

import 'package:http/http.dart' as http;

import 'fake_data_service.dart';
import 'ip_address_data.dart';
import 'test_utils.dart';

Future<IPAddressData?> getIPAddressDataRequest(
    Cassette cassette, Mode mode) async {
  DartVCRClient client = DartVCRClient(cassette, mode,
      advancedOptions:
          AdvancedOptions(matchRules: MatchRules.defaultStrictMatchRules));

  FakeDataService service = FakeDataService("json", client: client);

  return await service.getIPAddressData();
}

Future<http.StreamedResponse> getIPAddressDataRawRequest(
    Cassette cassette, Mode mode) async {
  DartVCRClient client = DartVCRClient(cassette, mode,
      advancedOptions:
          AdvancedOptions(matchRules: MatchRules.defaultStrictMatchRules));

  FakeDataService service = FakeDataService("json", client: client);

  return await service.getIPAddressDataRawResponse();
}

void main() {
  group('Client tests', () {
    setUp(() {
      // Additional setup goes here.
    });

    test('Auto mode', () async {
      Cassette cassette = TestUtils.getCassette("test_auto_mode");
      cassette.erase(); // Erase cassette before recording

      // in replay mode, if cassette is empty, should throw an exception
      expect(() => getIPAddressDataRequest(cassette, Mode.replay),
          throwsA(isA<VCRException>()));
      assert(cassette.numberOfInteractions ==
          0); // Make sure cassette is still empty

      // in auto mode, if cassette is empty, should make and record a real request
      IPAddressData? data = await getIPAddressDataRequest(cassette, Mode.auto);
      assert(data != null);
      assert(data!.ipAddress != null);
      assert(cassette.numberOfInteractions >
          0); // Make sure cassette is no longer empty
    });

    test('Read stream', () async {
      Cassette cassette = TestUtils.getCassette("test_read_stream");
      cassette.erase(); // Erase cassette before recording

      IPAddressData? data =
          await getIPAddressDataRequest(cassette, Mode.record);

      // if we've gotten here, it means we've recorded an interaction (requiring a read of the stream),
      // and then read the stream again to deserialize the response
      assert(data != null);

      // just to be certain
      cassette.erase();
      assert(cassette.numberOfInteractions == 0);
      http.StreamedResponse response =
          await getIPAddressDataRawRequest(cassette, Mode.record);
      assert((await response.stream.bytesToString()).isNotEmpty);
    });

    test('Censors', () async {
      Cassette cassette = TestUtils.getCassette("test_censors");
      cassette.erase(); // Erase cassette before recording

      // set up advanced settings
      String censorString = "censored-by-test";
      AdvancedOptions advancedOptions = AdvancedOptions(
          censors: Censors(censorString: censorString)
              .censorHeaderElementsByKeys(["date"]));

      // record cassette with advanced settings first
      DartVCRClient client = DartVCRClient(cassette, Mode.record,
          advancedOptions: advancedOptions);
      FakeDataService service = FakeDataService("json", client: client);
      await service.getIPAddressDataRawResponse();

      // now replay cassette
      client = DartVCRClient(cassette, Mode.replay,
          advancedOptions: advancedOptions);
      service = FakeDataService("json", client: client);
      http.StreamedResponse response =
          await service.getIPAddressDataRawResponse();

      // check that the replayed response contains the censored header
      Map<String, String> headers = response.headers;
      assert(headers.containsKey("date"));
      assert(headers["date"] == censorString);
    });

    test('Default request matching', () async {
      // test that match by method and url works
      Cassette cassette =
          TestUtils.getCassette("test_default_request_matching");
      cassette.erase(); // Erase cassette before recording

      Uri url = Uri.parse("https://google.com");
      String postBody = "test post body";

      // record cassette first
      DartVCRClient client = DartVCRClient(cassette, Mode.record,
          advancedOptions: AdvancedOptions(
              matchRules: MatchRules
                  .defaultMatchRules) // doesn't really matter for initial record
          );
      http.Response response = await client.post(url, body: postBody);
      assert(responseCameFromRecording(response) == false);

      // replay cassette
      client = DartVCRClient(cassette, Mode.replay,
          advancedOptions:
              AdvancedOptions(matchRules: MatchRules.defaultMatchRules));
      response = await client.post(url, body: postBody);

      // check that the request body was matched and that a recording was used
      assert(responseCameFromRecording(response) == true);
    });

    test('Delay', () async {
      Cassette cassette = TestUtils.getCassette("test_delay");
      cassette.erase(); // Erase cassette before recording

      // record cassette first
      DartVCRClient client = DartVCRClient(cassette, Mode.record);
      FakeDataService service = FakeDataService("json", client: client);
      await service.getIPAddressDataRawResponse();

      // baseline - how much time does it take to replay the cassette?
      client = DartVCRClient(cassette, Mode.replay);
      service = FakeDataService("json", client: client);
      Stopwatch stopwatch = Stopwatch()..start();
      await service.getIPAddressDataRawResponse();
      stopwatch.stop();

      // note normal playback time
      int normalReplayTime = max(0, stopwatch.elapsedMilliseconds);

      // set up advanced settings
      int delay = normalReplayTime +
          3000; // add 3 seconds to the normal replay time, for good measure
      client = DartVCRClient(cassette, Mode.replay,
          advancedOptions: AdvancedOptions(manualDelay: delay));
      service = FakeDataService("json", client: client);

      // time replay request
      stopwatch = Stopwatch()..start();
      await service.getIPAddressDataRawResponse();
      stopwatch.stop();

      // check that the delay was respected (within margin of error)
      int forcedReplayTime = max(0, stopwatch.elapsedMilliseconds);
      double requestedDelayWithMarginOfError =
          (delay * 0.95); // allow for 5% margin of error
      assert(forcedReplayTime >= requestedDelayWithMarginOfError);
    });

    test('Erase', () async {
      Cassette cassette = TestUtils.getCassette("test_erase");

      // record something to the cassette
      DartVCRClient client = DartVCRClient(cassette, Mode.record);
      FakeDataService service = FakeDataService("json", client: client);
      await service.getIPAddressDataRawResponse();

      // make sure the cassette is no longer empty
      assert(cassette.numberOfInteractions > 0);

      // erase the cassette
      cassette.erase();

      // make sure the cassette is now empty
      assert(cassette.numberOfInteractions == 0);
    });

    test('Erase and playback', () async {
      Cassette cassette = TestUtils.getCassette("test_erase_and_playback");
      cassette.erase(); // Erase cassette before recording

      // cassette is empty, so replaying should throw an exception
      DartVCRClient client = DartVCRClient(cassette, Mode.replay);
      FakeDataService service = FakeDataService("json", client: client);
      expect(service.getIPAddressDataRawResponse(), throwsException);
    });

    test('Erase and record', () async {
      Cassette cassette = TestUtils.getCassette("test_erase_and_record");
      cassette.erase(); // Erase cassette before recording

      // cassette is empty, so recording should work
      DartVCRClient client = DartVCRClient(cassette, Mode.record);
      FakeDataService service = FakeDataService("json", client: client);
      await service.getIPAddressDataRawResponse();

      // make sure the cassette is no longer empty
      assert(cassette.numberOfInteractions > 0);
    });

    test('Expiration settings', () async {
      Cassette cassette = TestUtils.getCassette("test_expiration_settings");
      cassette.erase(); // Erase cassette before recording

      Uri url = Uri.parse("https://google.com");

      // record cassette first
      DartVCRClient client = DartVCRClient(cassette, Mode.record);
      await client.post(url);

      // replay cassette with default expiration rules, should find a match
      client = DartVCRClient(cassette, Mode.replay);
      http.Response response = await client.post(url);
      assert(responseCameFromRecording(response) == true);

      // replay cassette with custom expiration rules, should not find a match because recording is expired (throw exception)
      AdvancedOptions advancedOptions = AdvancedOptions(
          validTimeFrame: TimeFrame.never,
          whenExpired: ExpirationAction
              .throwException // throw exception when in replay mode
          );
      await Future.delayed(Duration(
          milliseconds:
              1000)); // Allow 1 second to lapse to ensure recording is now "expired"
      client = DartVCRClient(cassette, Mode.replay,
          advancedOptions: advancedOptions);
      expect(client.post(url), throwsException);

      // replay cassette with bad expiration rules, should throw an exception because settings are bad
      advancedOptions = AdvancedOptions(
          validTimeFrame: TimeFrame.never,
          whenExpired: ExpirationAction
              .recordAgain // invalid settings for replay mode, should throw exception
          );
      client = DartVCRClient(cassette, Mode.replay,
          advancedOptions: advancedOptions);
    });

    test('Ignore elements fail match', () async {
      Cassette cassette =
          TestUtils.getCassette("test_ignore_elements_fail_match");
      cassette.erase(); // Erase cassette before recording

      Uri url = Uri.parse("https://google.com");
      String body1 =
          "{\"name\": \"Jack Sparrow\",\n    \"company\": \"EasyPost\"}";
      String body2 =
          "{\"name\": \"Different Name\",\n    \"company\": \"EasyPost\"}";

      // record baseline request first
      DartVCRClient client = DartVCRClient(cassette, Mode.record);
      await client.post(url, body: body1);

      // try to replay the request with different body data
      client = DartVCRClient(cassette, Mode.replay,
          advancedOptions: AdvancedOptions(
              matchRules: MatchRules().byBody().byMethod().byFullUrl()));

      // should fail since we're strictly in replay mode and there's no exact match
      expect(client.post(url, body: body2), throwsException);
    });

    test('Ignore element pass match', () async {
      Cassette cassette =
          TestUtils.getCassette("test_ignore_elements_pass_match");
      cassette.erase(); // Erase cassette before recording

      Uri url = Uri.parse("https://google.com");
      String body1 =
          "{\"name\": \"Jack Sparrow\",\n    \"company\": \"EasyPost\"}";
      String body2 =
          "{\"name\": \"Different Name\",\n    \"company\": \"EasyPost\"}";

      // record baseline request first
      DartVCRClient client = DartVCRClient(cassette, Mode.record);
      await client.post(url, body: body1);

      List<CensorElement> ignoreElements = [
        CensorElement("name", caseSensitive: false)
      ];

      // try to replay the request with different body data, but ignoring the differences
      client = DartVCRClient(cassette, Mode.replay,
          advancedOptions: AdvancedOptions(
              matchRules: MatchRules()
                  .byBody(ignoreElements: ignoreElements)
                  .byMethod()
                  .byFullUrl()));

      // should succeed since we're ignoring the differences
      http.Response response = await client.post(url, body: body2);
      assert(responseCameFromRecording(response) == true);
    });

    test('Match settings', () async {
      Cassette cassette = TestUtils.getCassette("test_match_settings");
      cassette.erase(); // Erase cassette before recording

      Uri url = Uri.parse("https://google.com");

      // record cassette first
      DartVCRClient client = DartVCRClient(cassette, Mode.record);
      await client.post(url);

      // replay cassette with default match rules, should find a match
      client = DartVCRClient(cassette, Mode.replay);
      // add custom header to request, shouldn't matter when matching by default rules
      // shouldn't throw an exception
      await client.post(url, headers: {"X-Custom-Header": "custom-value"});

      // replay cassette with custom match rules, should not find a match because request is different (throw exception)
      AdvancedOptions advancedOptions =
          AdvancedOptions(matchRules: MatchRules().byEverything());
      client = DartVCRClient(cassette, Mode.replay,
          advancedOptions: advancedOptions);
      // add custom header to request, causing a match failure when matching by everything
      expect(client.post(url, headers: {"X-Custom-Header": "custom-value"}),
          throwsException);
    });

    test('Nested censoring', () async {
      Cassette cassette = TestUtils.getCassette("test_nested_censoring");
      cassette.erase(); // Erase cassette before recording

      Uri url = Uri.parse("https://google.com");
      String body =
          "{\r\n  \"array\": [\r\n    \"array_1\",\r\n    \"array_2\",\r\n    \"array_3\"\r\n  ],\r\n  \"dict\": {\r\n    \"nested_array\": [\r\n      \"nested_array_1\",\r\n      \"nested_array_2\",\r\n      \"nested_array_3\"\r\n    ],\r\n    \"nested_dict\": {\r\n      \"nested_dict_1\": {\r\n        \"nested_dict_1_1\": {\r\n          \"nested_dict_1_1_1\": \"nested_dict_1_1_1_value\"\r\n        }\r\n      },\r\n      \"nested_dict_2\": {\r\n        \"nested_dict_2_1\": \"nested_dict_2_1_value\",\r\n        \"nested_dict_2_2\": \"nested_dict_2_2_value\"\r\n      }\r\n    },\r\n    \"dict_1\": \"dict_1_value\",\r\n    \"null_key\": null\r\n  }\r\n}";

      // set up advanced settings
      const String censorString = "censored-by-test";
      Censors censors = Censors(censorString: censorString);
      censors.censorBodyElementsByKeys(
          ["nested_dict_1_1_1", "nested_dict_2_2", "nested_array", "null_key"]);
      AdvancedOptions advancedOptions = AdvancedOptions(censors: censors);

      // record cassette
      DartVCRClient client = DartVCRClient(cassette, Mode.record,
          advancedOptions: advancedOptions);
      await client.post(url, body: body);

      // NOTE: Have to manually check the cassette
    });

    test('Strict request matching', () async {
      Cassette cassette = TestUtils.getCassette("test_strict_request_matching");
      cassette.erase(); // Erase cassette before recording

      Uri url = Uri.parse("https://google.com");
      String body =
          "{\n  \"address\": {\n    \"name\": \"Jack Sparrow\",\n    \"company\": \"EasyPost\",\n    \"street1\": \"388 Townsend St\",\n    \"street2\": \"Apt 20\",\n    \"city\": \"San Francisco\",\n    \"state\": \"CA\",\n    \"zip\": \"94107\",\n    \"country\": \"US\",\n    \"phone\": \"5555555555\"\n  }\n}";

      // record cassette first
      DartVCRClient client = DartVCRClient(cassette, Mode.record);
      http.Response response = await client.post(url, body: body);
      // check that the request body was not matched (should be a live call)
      assert(responseCameFromRecording(response) == false);

      // replay cassette with default match rules, should find a match
      client = DartVCRClient(cassette, Mode.replay);

      // replay cassette
      client = DartVCRClient(cassette, Mode.replay,
          advancedOptions:
              AdvancedOptions(matchRules: MatchRules.defaultStrictMatchRules));
      response = await client.post(url, body: body);

      // check that the request body was matched
      assert(responseCameFromRecording(response) == true);
    });
  });

  group('VCR tests', () {
    setUp(() {
      // Additional setup goes here.
    });

    test('Advanced settings', () async {
      String censorString = "censored-by-test";
      AdvancedOptions advancedOptions = AdvancedOptions(
          censors: Censors(censorString: censorString)
              .censorHeaderElementsByKeys(["date"]));
      VCR vcr = VCR(advancedOptions: advancedOptions);

      // test that the advanced settings are applied inside the VCR
      assert(vcr.advancedOptions == advancedOptions);

      // test that the advanced settings are passed to the cassette by checking if censor is applied
      Cassette cassette = TestUtils.getCassette("test_vcr_advanced_settings");
      vcr.insert(cassette);
      vcr.erase(); // Erase cassette before recording

      // record cassette first
      vcr.record();
      DartVCRClient client = vcr.client;
      FakeDataService service = FakeDataService("json", client: client);
      await service.getIPAddressDataRawResponse();

      // now replay and confirm that the censor is applied
      vcr.replay();
      // changing the VCR settings won't affect a client after it's been grabbed from the VCR
      // so, we need to re-grab the VCR client and re-create the FakeDataService
      client = vcr.client;
      service = FakeDataService("json", client: client);
      http.StreamedResponse response =
          await service.getIPAddressDataRawResponse();
      Map<String, String> headers = response.headers;
      assert(headers.containsKey("date"));
      assert(headers["date"] == censorString);
    });

    test("Cassette name", () async {
      String cassetteName = "test_vcr_cassette_name";
      Cassette cassette = TestUtils.getCassette(cassetteName);
      VCR vcr = TestUtils.getSimpleVCR(Mode.bypass);
      vcr.insert(cassette);

      // make sure the cassette name is set correctly
      assert(vcr.cassetteName == cassetteName);
    });

    test("Cassette swap", () async {
      String cassette1Name = "test_vcr_cassette_swap_1";
      String cassette2Name = "test_vcr_cassette_swap_2";

      Cassette cassette1 = TestUtils.getCassette(cassette1Name);
      Cassette cassette2 = TestUtils.getCassette(cassette2Name);

      VCR vcr = TestUtils.getSimpleVCR(Mode.bypass);
      vcr.insert(cassette1);
      assert(vcr.cassetteName == cassette1Name);

      vcr.eject();
      assert(vcr.cassetteName == null);

      vcr.insert(cassette2);
      assert(vcr.cassetteName == cassette2Name);
    });

    test("VCR client", () async {
      Cassette cassette = TestUtils.getCassette("test_vcr_client");
      VCR vcr = TestUtils.getSimpleVCR(Mode.bypass);
      vcr.insert(cassette);

      // make sure the VCR client is set correctly
      // no exception thrown when retrieving the client
      DartVCRClient client = vcr.client;
    });

    test("VCR client handoff", () async {
      Cassette cassette = TestUtils.getCassette("test_vcr_client_handoff");
      VCR vcr = TestUtils.getSimpleVCR(Mode.bypass);
      vcr.insert(cassette);

      // test that we can still control the VCR even after it's been handed off to the service using it
      FakeDataService service = FakeDataService("json", vcr: vcr);
      // Client should come from VCR, which has a client because it has a cassette.
      DartVCRClient client = service.client;

      vcr.eject();
      // Client should be null because the VCR's cassette has been ejected.
      expect(() => service.client, throwsException);
    });

    test("No cassette when retrieving client", () async {
      VCR vcr = TestUtils.getSimpleVCR(Mode.bypass);
      // Client should be null because the VCR has no cassette.
      expect(() => vcr.client, throwsException);
    });

    test("Eject cassette", () async {
      Cassette cassette = TestUtils.getCassette("test_vcr_eject_cassette");
      VCR vcr = TestUtils.getSimpleVCR(Mode.bypass);
      vcr.insert(cassette);

      // make sure the cassette is set correctly
      assert(vcr.cassetteName == cassette.name);

      vcr.eject();
      // make sure the cassette is set to null after ejecting
      assert(vcr.cassetteName == null);
    });

    test("Erase cassette in VCR", () async {
      Cassette cassette = TestUtils.getCassette("test_vcr_erase_cassette");
      cassette.erase(); // Erase cassette before recording
      VCR vcr = TestUtils.getSimpleVCR(Mode.record);
      vcr.insert(cassette);

      // record a request to a cassette
      FakeDataService service = FakeDataService("json", vcr: vcr);
      await service.getIPAddressDataRawResponse();

      // make sure the cassette is not empty
      assert(cassette.numberOfInteractions > 0);

      // erase the cassette
      vcr.erase();
      assert(cassette.numberOfInteractions == 0);
    });

    test("Insert cassette into VCR", () async {
      Cassette cassette = TestUtils.getCassette("test_vcr_insert_cassette");
      VCR vcr = TestUtils.getSimpleVCR(Mode.bypass);

      // make sure there is no cassette in the VCR
      assert(vcr.cassetteName == null);

      vcr.insert(cassette);
      // make sure the cassette is set correctly
      assert(vcr.cassetteName == cassette.name);
    });

    test("VCR modes", () async {
      VCR vcr = TestUtils.getSimpleVCR(Mode.bypass);
      assert(vcr.mode == Mode.bypass);
      vcr.record();
      assert(vcr.mode == Mode.record);
      vcr.replay();
      assert(vcr.mode == Mode.replay);
      vcr.pause();
      assert(vcr.mode == Mode.bypass);
      vcr.recordIfNeeded();
      assert(vcr.mode == Mode.auto);
    });

    test("VCR record", () async {
      Cassette cassette = TestUtils.getCassette("test_vcr_record");
      cassette.erase(); // Erase cassette before recording
      VCR vcr = TestUtils.getSimpleVCR(Mode.record);
      vcr.insert(cassette);
      FakeDataService service = FakeDataService("json", vcr: vcr);

      // make sure the cassette is empty
      assert(cassette.numberOfInteractions == 0);

      // record a request to a cassette
      await service.getIPAddressDataRawResponse();

      // make sure the cassette is not empty
      assert(cassette.numberOfInteractions > 0);
    });

    test("VCR replay", () async {
      Cassette cassette = TestUtils.getCassette("test_vcr_replay");
      VCR vcr = TestUtils.getSimpleVCR(Mode.record);
      vcr.insert(cassette);
      FakeDataService service = FakeDataService("json", vcr: vcr);

      // record a request to a cassette first
      await service.getIPAddressDataRawResponse();
      assert(cassette.numberOfInteractions > 0);

      // replay the request from the cassette
      vcr.replay();
      http.StreamedResponse response = await service.getIPAddressDataRawResponse();
      assert(response.statusCode == 200);

      // double check by erasing the cassette and trying to replay
      vcr.erase();
      assert(cassette.numberOfInteractions == 0);
      // should throw an exception because there's no matching interaction now
      expect(() => service.getIPAddressDataRawResponse(), throwsException);
    });

    test("VCR request", () async {
      Cassette cassette = TestUtils.getCassette("test_vcr_request");
      VCR vcr = TestUtils.getSimpleVCR(Mode.bypass);
      vcr.insert(cassette);
      FakeDataService service = FakeDataService("json", vcr: vcr);

      http.StreamedResponse response = await service.getIPAddressDataRawResponse();
      assert(response.statusCode == 200);
    });
  });
}
