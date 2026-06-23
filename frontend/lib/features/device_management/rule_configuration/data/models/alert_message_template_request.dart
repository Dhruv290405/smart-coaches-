import 'package:freezed_annotation/freezed_annotation.dart';

part 'alert_message_template_request.freezed.dart';
part 'alert_message_template_request.g.dart';

@freezed
abstract class AlertMessageTemplateRequest with _$AlertMessageTemplateRequest {
  const factory AlertMessageTemplateRequest({
    String? title,
    String? body,
    String? level,
  }) = _AlertMessageTemplateRequest;

  factory AlertMessageTemplateRequest.fromJson(Map<String, dynamic> json) =>
      _$AlertMessageTemplateRequestFromJson(json);
}
