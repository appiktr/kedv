import 'package:kedv/model/profile_model.dart';
import 'package:kedv/service/api_service.dart';

class ProfileService {
  final ApiService _apiService = ApiService();

  Future<ProfileModel?> getProfile() async {
    final response = await _apiService.get('profiles');
    if (response['status_code'] == 200 && response['data'] != null) {
      if (response['data'] is List && (response['data'] as List).isEmpty) {
        return null;
      }
      return ProfileModel.fromJson(response['data']);
    }
    return null;
  }
}
