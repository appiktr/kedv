import 'package:kedv/model/evaluation_model.dart';
import 'package:kedv/model/report_model.dart';
import 'package:kedv/service/api_service.dart';
import 'package:dio/dio.dart';

class EvaluationService {
  final ApiService _apiService = ApiService();

  /// Questions are fetched via GET /getQuestions
  Future<EvaluationResponse?> getQuestions() async {
    try {
      final response = await _apiService.get('getQuestions');

      if (response['status_code'] == 200) {
        return EvaluationResponse.fromJson(response);
      } else {
        throw Exception(response['message'] ?? 'Failed to load questions');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// This is a placeholder for future implementation
  Future<void> submitEvaluation(Map<String, dynamic> payload) async {
    try {
      await _apiService.post('notifications', data: payload);
    } catch (e) {
      throw Exception('Değerlendirme gönderilemedi: $e');
    }
  }

  Future<EvaluationResponse?> getMenu3Questions() async {
    try {
      final response = await _apiService.get('getMenu3Questions');
      return EvaluationResponse.fromJson(response);
    } catch (e) {
      throw Exception('Anket soruları yüklenirken bir hata oluştu: $e');
    }
  }

  Future<void> submitNeighbourhoodEvaluation(Map<String, dynamic> payload) async {
    try {
      await _apiService.post('neighbourhood-evaluations', data: payload);
    } catch (e) {
      throw Exception('Değerlendirme gönderilemedi: $e');
    }
  }

  Future<List<ReportModel>> getReports() async {
    try {
      final results = await Future.wait([
        _apiService.get('notifications'),
        _apiService.get('prive-notifications'),
        _apiService.get('neighbourhood-evaluations'),
      ]);

      List<ReportModel> allReports = [];

      // Process notifications
      final notificationsResponse = results[0];
      if (notificationsResponse['status_code'] == 200 && notificationsResponse['data'] is List) {
        allReports.addAll((notificationsResponse['data'] as List).map((e) => ReportModel.fromJson(e)));
      }

      // Process prive-notifications
      final priveResponse = results[1];
      if (priveResponse['status_code'] == 200 && priveResponse['data'] is List) {
        allReports.addAll((priveResponse['data'] as List).map((e) => ReportModel.fromPriveNotificationJson(e)));
      }

      // Process neighbourhood-evaluations
      final neighbourhoodResponse = results[2];
      if (neighbourhoodResponse['status_code'] == 200 && neighbourhoodResponse['data'] is List) {
        allReports.addAll(
          (neighbourhoodResponse['data'] as List).map((e) => ReportModel.fromNeighbourhoodEvaluationJson(e)),
        );
      }

      // Sort by date descending
      allReports.sort((a, b) => b.completedDate.compareTo(a.completedDate));

      return allReports;
    } catch (e) {
      // If one fails, we might still want to return what we have, or throw.
      // For now, let's log and rethrow.
      throw Exception('Raporlar yüklenirken bir hata oluştu: $e');
    }
  }

  Future<void> updateNotification(int id, Map<String, dynamic> payload) async {
    try {
      await _apiService.put('notifications/$id', data: payload);
    } catch (e) {
      throw Exception('Güncelleme başarısız: $e');
    }
  }

  Future<void> updatePriveNotification(int id, Map<String, dynamic> payload) async {
    try {
      await _apiService.put('prive-notifications/$id', data: payload);
    } catch (e) {
      throw Exception('Güncelleme başarısız: $e');
    }
  }

  Future<void> updateNeighbourhoodEvaluation(int id, Map<String, dynamic> payload) async {
    try {
      await _apiService.put('neighbourhood-evaluations/$id', data: payload);
    } catch (e) {
      throw Exception('Güncelleme başarısız: $e');
    }
  }

  Future<String> uploadMedia(dynamic file) async {
    // accepting dynamic file (File or XFile)
    try {
      String fileName = file.path.split('/').last;

      // FormData is from Dio
      final formData = FormData.fromMap({'file': await MultipartFile.fromFile(file.path, filename: fileName)});

      final response = await _apiService.post('prive-notifications/media', data: formData);

      // Response is directly the data map based on logs
      // {"name":"...", "original_name":"..."}
      if (response is Map && response['name'] != null) {
        return response['name'];
      }

      // Fallback check if it was wrapped (defensive)
      if (response is Map && response['status_code'] == 200 && response['data'] != null) {
        if (response['data'] is Map && response['data']['name'] != null) {
          return response['data']['name'];
        }
      }

      throw Exception('Medya yüklenemedi: Geçersiz yanıt formatı');
    } catch (e) {
      throw Exception('Medya yüklenirken hata oluştu: $e');
    }
  }
}
