import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/auth_response.dart';
import 'http_service.dart';

class AuthService {
  static const String baseUrl = 'http://localhost/elecom_system/api';

  // Login user
  static Future<AuthResponse> login(String username, String password) async {
    try {
      HttpService.initialize();
      final response = await HttpService.post(
        '/login.php',
        data: {'username': username, 'password': password},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return AuthResponse.fromJson(data);
      } else {
        return AuthResponse(
          success: false,
          message: 'Server error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return AuthResponse(success: false, message: 'Network error: $e');
    }
  }

  // Register user
  static Future<AuthResponse> register({
    required String firstname,
    required String lastname,
    required String username,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      HttpService.initialize();
      final response = await HttpService.post(
        '/register.php',
        data: {
          'firstname': firstname,
          'lastname': lastname,
          'username': username,
          'email': email,
          'password': password,
          'confirm_password': confirmPassword,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return AuthResponse.fromJson(data);
      } else {
        return AuthResponse(
          success: false,
          message: 'Server error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return AuthResponse(success: false, message: 'Network error: $e');
    }
  }

  // Logout user
  static Future<AuthResponse> logout() async {
    try {
      HttpService.initialize();
      final response = await HttpService.post('/logout.php');

      if (response.statusCode == 200) {
        final data = response.data;
        await HttpService.clearCookies(); // Clear cookies on logout
        return AuthResponse.fromJson(data);
      } else {
        return AuthResponse(
          success: false,
          message: 'Server error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return AuthResponse(success: false, message: 'Network error: $e');
    }
  }

  // Check if user is logged in
  static Future<AuthResponse> checkAuth() async {
    try {
      HttpService.initialize();
      final response = await HttpService.get('/check_auth.php');

      if (response.statusCode == 200) {
        final data = response.data;
        return AuthResponse.fromJson(data);
      } else {
        return AuthResponse(
          success: false,
          message: 'Server error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return AuthResponse(success: false, message: 'Network error: $e');
    }
  }
}
