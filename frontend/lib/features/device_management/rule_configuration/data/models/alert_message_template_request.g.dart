// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alert_message_template_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AlertMessageTemplateRequest _$AlertMessageTemplateRequestFromJson(
  Map<String, dynamic> json,
) => _AlertMessageTemplateRequest(
  title: json['title'] as String?,
  body: json['body'] as String?,
  level: json['level'] as String?,
);

Map<String, dynamic> _$AlertMessageTemplateRequestToJson(
  _AlertMessageTemplateRequest instance,
) => <String, dynamic>{
  'title': instance.title,
  'body': instance.body,
  'level': instance.level,
};
