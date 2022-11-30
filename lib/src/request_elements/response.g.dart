// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Response _$ResponseFromJson(Map<String, dynamic> json) => Response(
      json['body'] as String?,
      Map<String, String>.from(json['headers'] as Map),
      Status.fromJson(json['status'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ResponseToJson(Response instance) => <String, dynamic>{
      'body': instance.body,
      'headers': instance.headers,
      'status': instance.status.toJson(),
    };
