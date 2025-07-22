import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:frontend/models/user.dart';
import 'package:frontend/services/secure_storage.dart';

class AuthProvider with ChangeNotifier {
  late SecureStorageService _storage;
  User? _user;
  bool _isLoading = false;

  User? get user => _user;
  bool get isLoading => _isLoading;

  // Initialize storage
  Future<void> init() async {
    _storage = SecureStorageService('your-app-master-key-here');
    await _storage.init();
    await autoLogin();
  }

  // Check if user is already logged in
  Future<void> autoLogin() async {
    _isLoading = true;
    notifyListeners();

    try {
      final userData = await _storage.read(key: 'user_data');
      final token = await _storage.read(key: 'auth_token');

      if (token != null && userData != null) {
        _user = User.fromJson(json.decode(userData));
      }
    } catch (e) {
      print("Auto-login error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Login user
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('http://localhost:8081/user/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final token = data['token'];
        final userData = data['user'];

        await _storage.write(key: 'auth_token', value: token);
        await _storage.write(key: 'user_data', value: json.encode(userData));

        _user = User.fromJson(userData);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        print('Login failed: ${response.body}');
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      print('Error during login: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Logout user
  Future<void> logout() async {
    await _storage.delete(key: 'auth_token');
    await _storage.delete(key: 'user_data');
    _user = null;
    notifyListeners();
  }

  // Get auth token (for API calls)
  Future<String?> get authToken async {
    return await _storage.read(key: 'auth_token');
  }

  // Is the user logged in?
  bool get isAuthenticated => _user != null;
  // Inside AuthProvider class
  String? get userRole => _user?.role;
}
