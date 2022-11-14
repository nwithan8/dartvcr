import 'dart:convert';

import 'package:http/http.dart';
import 'package:json_annotation/json_annotation.dart';

part 'ip_address_data.g.dart';

@JsonSerializable(explicitToJson: true)
class IPAddressData {
  @JsonKey(name: 'ip')
  final String? ipAddress;

  IPAddressData(this.ipAddress) : super();

  factory IPAddressData.fromJson(Map<String, dynamic> input) =>
      _$IPAddressDataFromJson(input);

  Map<String, dynamic> toJson() => _$IPAddressDataToJson(this);

  /// Creates a new HTTP response by waiting for the full body to become
  /// available from a [StreamedResponse].
  static Future<IPAddressData> fromStream(StreamedResponse response) async {
    String body = await response.stream.bytesToString();
    return IPAddressData.fromJson(jsonDecode(body));
  }
}
