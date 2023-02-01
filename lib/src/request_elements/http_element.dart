import 'package:json_annotation/json_annotation.dart';

part 'http_element.g.dart';

/// The base class for all request elements.
@JsonSerializable(explicitToJson: true)
class HttpElement {
  /// Creates a new [HttpElement].
  HttpElement();

  /// Creates a new [HttpElement] from a JSON map.
  factory HttpElement.fromJson(Map<String, dynamic> input) =>
      _$HttpElementFromJson(input);

  /// Converts this [HttpElement] to a JSON map.
  Map<String, dynamic> toJson() => _$HttpElementToJson(this);
}
