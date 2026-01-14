import 'package:kedv/model/evaluation_model.dart';
import 'package:kedv/service/api_service.dart';

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

  /// TODO: Submit answers endpoint not yet defined
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
}
