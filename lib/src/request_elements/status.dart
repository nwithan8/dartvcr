import 'package:json_annotation/json_annotation.dart';

import 'http_element.dart';

part 'status.g.dart';

/// A class that represents an HTTP status.
@JsonSerializable(explicitToJson: true)
class Status extends HttpElement {
  /// The code of the status.
  @JsonKey(name: 'code')
  final int? code;

  /// The message of the status.
  @JsonKey(name: 'message')
  final String? message;

  /// Creates a new [Status] with the given [code] and [message].
  Status(this.code, this.message) : super();

  /// Creates a new [Status] from a JSON map.
  factory Status.fromJson(Map<String, dynamic> input) =>
      _$StatusFromJson(input);

  /// Converts this [Status] to a JSON map.
  @override
  Map<String, dynamic> toJson() => _$StatusToJson(this);
}
