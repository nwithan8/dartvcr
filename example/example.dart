import 'package:dartvcr/dartvcr.dart';

Future<void> useClientDirectly() async {
  // Create a cassette to handle HTTP interactions
  var cassette = Cassette("path/to/cassettes", "my_cassette");

  // hide the api_key query parameter for all requests recorded by the client
  var advancedOptions = AdvancedOptions(
      censors: Censors().censorQueryElementsByKeys(["api_key"]));

  // create an DartVCRClient using the cassette
  DartVCRClient client =
      DartVCRClient(cassette, Mode.record, advancedOptions: advancedOptions);

  // Use this DartVCRClient in any class making HTTP calls
  // Note: DartVCRClient extends BaseClient from the 'http/http' package, so it can be used anywhere a BaseClient is expected
  await client.post(Uri.parse('https://api.example.com/v1/users'));
}

Future<void> useClientViaVCR() async {
  // hide the api_key query parameter for all requests recorded by the VCR
  var advancedOptions = AdvancedOptions(
      censors: Censors().censorQueryElementsByKeys(["api_key"]));

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
  await client.post(Uri.parse('https://api.example.com/v1/users'));

  // remove the cassette from the VCR
  vcr.eject();
}
