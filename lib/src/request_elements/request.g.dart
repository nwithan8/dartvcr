// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Request _$RequestFromJson(Map<String, dynamic> json) => Request(
      json['body'] as String?,
      Map<String, String>.from(json['headers'] as Map),
      json['method'] as String,
      Uri.parse(json['uri'] as String),
    );

Map<String, dynamic> _$RequestToJson(Request instance) => <String, dynamic>{
      'body': instance.body,
      'headers': instance.headers,
      'method': instance.method,
      'uri': instance.uri.toString(),
    };
