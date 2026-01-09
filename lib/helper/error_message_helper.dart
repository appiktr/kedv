import 'package:dio/dio.dart';

class ErrorMessageHelper {
  /// Farklı tipte hatalardan kullanıcıya gösterilecek anlamlı bir mesaj üretir.
  static String getErrorMessage(dynamic error) {
    if (error is DioException) {
      // Eğer DioException ise response içindeki message alanını çek
      final data = error.response?.data;
      if (data is Map && data['message'] != null) {
        return data['message'].toString();
      }
      return error.message ?? 'Bir ağ hatası oluştu';
    }

    // Eğer Exception string formatında message içeriyorsa (örneğin HTTP 400: {...})
    final errorString = error.toString();
    if (errorString.contains('message:')) {
      final regex = RegExp(r'message:\s*([^}]+)');
      final match = regex.firstMatch(errorString);
      if (match != null) {
        return match.group(1)?.trim() ?? 'Bilinmeyen hata';
      }
    }

    // Fallback
    return errorString;
  }
}

