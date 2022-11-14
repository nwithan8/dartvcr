import 'package:dartvcr/src/advanced_settings.dart';
import 'package:dartvcr/src/cassette.dart';
import 'package:dartvcr/src/easyvcr_client.dart';
import 'package:dartvcr/src/match_rules.dart';
import 'package:dartvcr/src/mode.dart';
import 'package:dartvcr/src/vcr_exception.dart';
import 'package:test/test.dart';

import 'package:http/http.dart' as http;

import 'fake_data_service.dart';
import 'ip_address_data.dart';
import 'test_utils.dart';

Future<IPAddressData?> getIPAddressDataRequest(
    Cassette cassette, Mode mode) async {
  EasyVCRClient client = EasyVCRClient(cassette, mode,
      advancedSettings:
          AdvancedSettings(matchRules: MatchRules.defaultStrictMatchRules));

  FakeDataService service = FakeDataService("json", client: client);

  return await service.getIPAddressData();
}

Future<http.StreamedResponse> getIPAddressDataRawRequest(
    Cassette cassette, Mode mode) async {
  EasyVCRClient client = EasyVCRClient(cassette, mode,
      advancedSettings:
          AdvancedSettings(matchRules: MatchRules.defaultStrictMatchRules));

  FakeDataService service = FakeDataService("json", client: client);

  return await service.getIPAddressDataRawResponse();
}

void main() {
  group('Client tests', () {
    setUp(() {
      // Additional setup goes here.
    });

    test('Auto mode test', () async {
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

    test('Read stream test', () async {
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
      http.StreamedResponse response = await getIPAddressDataRawRequest(cassette, Mode.record);
      assert((await response.stream.bytesToString()).isNotEmpty);
    });
  });
}
