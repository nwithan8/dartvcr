import 'package:dartvcr/src/easyvcr_client.dart';
import 'package:dartvcr/src/vcr.dart';
import 'package:http/http.dart' as http;

import 'ip_address_data.dart';

class FakeDataService {
  EasyVCRClient? _client;

  final String format;

  VCR? _vcr;

  FakeDataService(this.format, {EasyVCRClient? client, VCR? vcr}) {
    _client = client;
    _vcr = vcr;
  }

  Future<IPAddressData?> getIPAddressData() async {
    http.StreamedResponse response = await getIPAddressDataRawResponse();
    return await IPAddressData.fromStream(response);
  }

  Future<http.StreamedResponse> getIPAddressDataRawResponse() async {
    String url = _getIPAddressDataUrl(format);
    return await client.send(http.Request('GET', Uri.parse(url)));
  }

  String _getIPAddressDataUrl(String format) {
    return 'https://api.ipify.org?format=$format';
  }
}

extension on FakeDataService {
  EasyVCRClient get client {
    if (_client != null) {
      return _client!;
    }

    if (_vcr != null) {
      return _vcr!.client;
    }

    throw Exception('No client or vcr set');
  }
}
