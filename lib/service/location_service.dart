import 'package:kedv/model/location_model.dart';
import 'package:kedv/service/api_service.dart';

class LocationService {
  final ApiService _apiService = ApiService();

  Future<List<City>> getCities() async {
    final response = await _apiService.get('cities');
    if (response['status_code'] == 200 && response['data'] is List) {
      return (response['data'] as List).map((e) => City.fromJson(e)).toList();
    }
    return [];
  }

  Future<List<District>> getDistricts(int cityId) async {
    final response = await _apiService.get('districts', queryParameters: {'city_id': cityId});
    if (response['status_code'] == 200 && response['data'] is List) {
      return (response['data'] as List).map((e) => District.fromJson(e)).toList();
    }
    return [];
  }

  Future<List<Neighbourhood>> getNeighbourhoods(int districtId) async {
    final response = await _apiService.get('neighbourhoods', queryParameters: {'district_id': districtId});
    if (response['status_code'] == 200 && response['data'] is List) {
      return (response['data'] as List).map((e) => Neighbourhood.fromJson(e)).toList();
    }
    return [];
  }
}
