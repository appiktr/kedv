import 'dart:convert';
import 'package:kedv/model/register_request_model.dart';
import 'package:kedv/model/register_response_model.dart';
import 'package:kedv/service/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final ApiService _apiService = ApiService();
  static const String _tokenKey = 'auth_token';

  Future<RegisterResponseModel> register(RegisterRequestModel request) async {
    final response = await _apiService.post('register', data: request.toJson());

    if (response['status_code'] == 201) {
      final registerResponse = RegisterResponseModel.fromJson(response['data']);
      await saveToken(registerResponse.token);
      return registerResponse;
    } else {
      throw Exception(response['message'] ?? 'Registration failed');
    }
  }

  Future<RegisterResponseModel> login(String login, String password) async {
    final response = await _apiService.post('login', data: {'login': login, 'password': password});

    if (response['status_code'] == 200) {
      final loginResponse = RegisterResponseModel.fromJson(response['data']);
      await saveToken(loginResponse.token);
      return loginResponse;
    } else {
      throw Exception(response['message'] ?? 'Login failed');
    }
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await clearCredentials();
  }

  // --- Remember Me Feature ---

  Future<void> saveCredentials(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('saved_email', email);
    // Simple encryption (Base64) - NOT SECURE for production but requested by user
    final encryptedPassword = _encrypt(password);
    await prefs.setString('saved_password', encryptedPassword);
  }

  Future<Map<String, String>?> getCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('saved_email');
    final encryptedPassword = prefs.getString('saved_password');

    if (email != null && encryptedPassword != null) {
      final password = _decrypt(encryptedPassword);
      return {'email': email, 'password': password};
    }
    return null;
  }

  Future<void> clearCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('saved_email');
    await prefs.remove('saved_password');
  }

  String _encrypt(String text) {
    if (text.isEmpty) return '';
    return base64Encode(utf8.encode(text));
  }

  String _decrypt(String text) {
    if (text.isEmpty) return '';
    try {
      return utf8.decode(base64Decode(text));
    } catch (e) {
      return '';
    }
  }
}
