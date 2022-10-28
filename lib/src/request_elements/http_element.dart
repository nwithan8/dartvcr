import 'package:json_annotation/json_annotation.dart';

part 'http_element.g.dart';

@JsonSerializable(explicitToJson: true)
class HttpElement {
  HttpElement();

  factory HttpElement.fromJson(Map<String, dynamic> input) =>
      _$HttpElementFromJson(input);

  Map<String, dynamic> toJson() => _$HttpElementToJson(this);
}
