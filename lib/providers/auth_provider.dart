import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _setUser(User? user) {
    _user = user;
    notifyListeners();
  }

  Future<bool> login(String username, String password) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await AuthService.login(username, password);

      if (response.success && response.user != null) {
        _setUser(response.user);
        _setLoading(false);
        return true;
      } else {
        _setError(response.message);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Login failed: $e');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> register({
    required String firstname,
    required String lastname,
    required String username,
    required String password,
    required String confirmPassword,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await AuthService.register(
        firstname: firstname,
        lastname: lastname,
        username: username,
        password: password,
        confirmPassword: confirmPassword,
      );

      _setLoading(false);

      if (response.success) {
        return true;
      } else {
        _setError(response.message);
        return false;
      }
    } catch (e) {
      _setError('Registration failed: $e');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> logout() async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await AuthService.logout();

      _setUser(null);
      _setLoading(false);

      if (response.success) {
        return true;
      } else {
        _setError(response.message);
        return false;
      }
    } catch (e) {
      _setError('Logout failed: $e');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> checkAuth() async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await AuthService.checkAuth();

      if (response.success && response.user != null) {
        _setUser(response.user);
        _setLoading(false);
        return true;
      } else {
        _setUser(null);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setUser(null);
      _setLoading(false);
      return false;
    }
  }

  void clearError() {
    _setError(null);
  }
}
