// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'base_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BaseResponse<T> _$BaseResponseFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) => BaseResponse<T>(
  statusCode: (json['status_code'] as num).toInt(),
  message: json['message'] as String,
  messageType: json['message_type'] as String,
  data: fromJsonT(json['data']),
);

Map<String, dynamic> _$BaseResponseToJson<T>(
  BaseResponse<T> instance,
  Object? Function(T value) toJsonT,
) => <String, dynamic>{
  'status_code': instance.statusCode,
  'message': instance.message,
  'message_type': instance.messageType,
  'data': toJsonT(instance.data),
};
