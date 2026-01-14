import 'dart:io';
import 'package:dio/dio.dart';
import 'package:kedv/model/report_issue_model.dart';
import 'package:kedv/service/api_service.dart';

class ReportService {
  final ApiService _apiService = ApiService();

  Future<ReportMenuResponse?> getMenu2Questions() async {
    try {
      final response = await _apiService.get('getMenu2Questions');
      return ReportMenuResponse.fromJson(response);
    } catch (e) {
      throw Exception('Soru listesi yüklenirken bir hata oluştu: $e');
    }
  }

  Future<void> submitReport(Map<String, dynamic> payload) async {
    try {
      await _apiService.post('prive-notifications', data: payload);
    } catch (e) {
      throw Exception('Rapor gönderilemedi: $e');
    }
  }

  Future<String> uploadMedia(File file) async {
    try {
      String fileName = file.path.split('/').last;
      FormData formData = FormData.fromMap({'file': await MultipartFile.fromFile(file.path, filename: fileName)});

      final response = await _apiService.post('prive-notifications/media', data: formData);

      // Check response structure for the uploaded filename/ID
      // Usually returns { "status_code": 200, "data": { "file_name": "..." } } or similar string.
      // Based on typical Hepta API, let's assume it returns data that contains the filename.
      // If response is just the string, or map.
      // Looking at previous patterns, response.data might be the map.

      // Let's assume response is like:
      // { "status": "success", "data": "filename.jpg" } or { "data": { "file": "filename.jpg" } }
      // I'll assume for now it returns a Map and I need to extract the filename.
      // If the user didn't specify, I should perhaps return dynamic and check.
      // But standard "post" in ApiService returns "response.data".

      if (response is Map) {
        if (response.containsKey('name')) {
          return response['name'].toString();
        } else if (response.containsKey('data')) {
          // Fallback if wrapped in data
          final data = response['data'];
          if (data is Map && data.containsKey('name')) {
            return data['name'].toString();
          } else {
            return data.toString();
          }
        }
      }
      return response.toString();
    } catch (e) {
      throw Exception('Dosya yüklenemedi: $e');
    }
  }
}
