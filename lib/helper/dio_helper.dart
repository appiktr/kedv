import 'package:dio/dio.dart';
import 'package:kedv/core/const.dart';

class DioHelper {
  static late Dio _dio;

  /// Dio'yu başlat
  static void init() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseApiUrl,
        receiveDataWhenStatusError: true,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // İsteğe bağlı: Interceptor ekle (log için)
    _dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestBody: true,
        responseBody: true,
        error: true,
      ),
    );
  }

  /// Token ayarla
  static void setToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  /// Token kaldır
  static void removeToken() {
    _dio.options.headers.remove('Authorization');
  }

  /// GET isteği
  static Future<Response> get({
    required String endpoint,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// POST isteği
  static Future<Response> post({
    required String endpoint,
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.post(
        endpoint,
        data: data,
        queryParameters: queryParameters,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// PUT isteği
  static Future<Response> put({
    required String endpoint,
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.put(
        endpoint,
        data: data,
        queryParameters: queryParameters,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// DELETE isteği
  static Future<Response> delete({
    required String endpoint,
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.delete(
        endpoint,
        data: data,
        queryParameters: queryParameters,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// PATCH isteği
  static Future<Response> patch({
    required String endpoint,
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.patch(
        endpoint,
        data: data,
        queryParameters: queryParameters,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Hata yönetimi
  static String _handleError(DioException error) {
    String errorMessage;

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        errorMessage = 'Bağlantı zaman aşımına uğradı';
        break;
      case DioExceptionType.sendTimeout:
        errorMessage = 'Gönderme zaman aşımına uğradı';
        break;
      case DioExceptionType.receiveTimeout:
        errorMessage = 'Alma zaman aşımına uğradı';
        break;
      case DioExceptionType.badCertificate:
        errorMessage = 'Geçersiz sertifika';
        break;
      case DioExceptionType.badResponse:
        errorMessage = _handleResponseError(error.response?.statusCode);
        break;
      case DioExceptionType.cancel:
        errorMessage = 'İstek iptal edildi';
        break;
      case DioExceptionType.connectionError:
        errorMessage = 'İnternet bağlantısı yok';
        break;
      case DioExceptionType.unknown:
        errorMessage = 'Beklenmeyen bir hata oluştu';
        break;
    }

    return errorMessage;
  }

  /// HTTP durum kodu hata yönetimi
  static String _handleResponseError(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'Geçersiz istek';
      case 401:
        return 'Yetkisiz erişim';
      case 403:
        return 'Erişim reddedildi';
      case 404:
        return 'Bulunamadı';
      case 500:
        return 'Sunucu hatası';
      case 502:
        return 'Geçersiz ağ geçidi';
      case 503:
        return 'Hizmet kullanılamıyor';
      default:
        return 'Bir hata oluştu: $statusCode';
    }
  }
}

