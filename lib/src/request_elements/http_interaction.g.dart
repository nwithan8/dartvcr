// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'http_interaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HttpInteraction _$HttpInteractionFromJson(Map<String, dynamic> json) =>
    HttpInteraction(
      json['duration'] as int,
      DateTime.parse(json['recorded_at'] as String),
      Request.fromJson(json['request'] as Map<String, dynamic>),
      Response.fromJson(json['response'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$HttpInteractionToJson(HttpInteraction instance) =>
    <String, dynamic>{
      'duration': instance.duration,
      'recorded_at': instance.recordedAt.toIso8601String(),
      'request': instance.request.toJson(),
      'response': instance.response.toJson(),
    };
