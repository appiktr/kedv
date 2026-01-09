import 'dart:developer';

import 'package:kedv/model/base_response_model.dart';

/// Tekil obje için BaseResponse parse helper
BaseResponse<T>? fromJsonBaseResponse<T>(
  Map<String, dynamic>? json,
  T Function(Map<String, dynamic>) create,
) {
  if (json == null) return null;

  try {
    return BaseResponse<T>.fromJson(
      json,
      (data) => create(data as Map<String, dynamic>),
    );
  } catch (e) {
    log('Parsing error: $e');
    throw Exception('Veri parse edilemedi: $e');
  }
}

/// Liste için BaseResponse parse helper
BaseResponse<List<T>>? fromJsonBaseResponseList<T>(
  Map<String, dynamic>? json,
  T Function(Map<String, dynamic>) create,
) {
  if (json == null) return null;

  try {
    return BaseResponse<List<T>>.fromJson(
      json,
      (data) => (data as List<dynamic>)
          .map((e) => create(e as Map<String, dynamic>))
          .toList(),
    );
  } catch (e) {
    log('Parsing error: $e');
    throw Exception('Veri parse edilemedi: $e');
  }
}

