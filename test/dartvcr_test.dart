

import 'package:dartvcr/dartvcr.dart';
import 'package:dartvcr/src/cassette.dart';
import 'package:dartvcr/src/http_client.dart';
import 'package:dartvcr/src/mode.dart';
import 'package:dartvcr/src/vcr.dart';
import 'package:test/test.dart';

import 'package:http/http.dart' as http;

void main() {
  group('A group of tests', () {

    setUp(() {
      // Additional setup goes here.
    });

    test('Client test', () async {
      Cassette cassette = Cassette('test/cassettes', 'client_test');
      HttpClient client = HttpClient(cassette, Mode.auto);
      await client.send(http.Request('GET', Uri.parse('https://www.google.com')));
    });

    test('VCR test', () async {
      VCR vcr = VCR();
      vcr.record();
      vcr.insert(Cassette('test/cassettes', 'vcr_test'));
      await vcr.client.send(http.Request('GET', Uri.parse('https://www.google.com')));
    });
  });
}
