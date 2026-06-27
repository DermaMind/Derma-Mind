import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../utils/prefs_helper.dart';

class AuthProvider extends ChangeNotifier {
  String _userName = '';
  String _email = '';
  String _phone = '';
  String _dateOfBirth = '';
  String _gender = 'Female';
  String? _profileImageUrl;
  bool _isLoggedIn = false;
  bool _isLoading = false;

  String get userName => _userName;
  String get email => _email;
  String get phone => _phone;
  String get dateOfBirth => _dateOfBirth;
  String get gender => _gender;
  String? get profileImageUrl => _profileImageUrl;
  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;

  Future<void> loadFromPrefs() async {
    final token = await PrefsHelper.getToken();
    if (token != null && token.isNotEmpty) {
      ApiService.setToken(token);
      _isLoggedIn = true;

      // Try to refresh profile from API; fall back to cached prefs.
      final profileRes = await ApiService.getProfile();
      if (profileRes.success && profileRes.data != null) {
        _applyUserModel(profileRes.data!);
      } else {
        final data = await PrefsHelper.loadUserData();
        _userName = data['name'] ?? '';
        _email = data['email'] ?? '';
        _phone = data['phone'] ?? '';
        _dateOfBirth = data['dob'] ?? '';
        _gender = data['gender'] ?? 'Female';
      }
    } else {
      _isLoggedIn = await PrefsHelper.isLoggedIn();
      if (_isLoggedIn) {
        final data = await PrefsHelper.loadUserData();
        _userName = data['name'] ?? '';
        _email = data['email'] ?? '';
        _phone = data['phone'] ?? '';
        _dateOfBirth = data['dob'] ?? '';
        _gender = data['gender'] ?? 'Female';
      }
    }
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final res = await ApiService.login(email: email, password: password);
      if (!res.success || res.data == null) {
        throw Exception(res.message ?? 'Login failed');
      }

      final authData = res.data!;
      final token = authData.token;

      ApiService.setToken(token);
      await PrefsHelper.saveToken(token);

      _applyUserModel(authData.user);
      _email = email;
      _isLoggedIn = true;

      await PrefsHelper.saveLoginData(
        name: _userName,
        email: _email,
        phone: _phone,
        dob: _dateOfBirth,
        gender: _gender,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String phone,
    required String dob,
    required String gender,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final res = await ApiService.register(
        fullName: name,
        email: email,
        password: password,
        confirmPassword: password,
      );
      if (!res.success || res.data == null) {
        throw Exception(res.message ?? 'Registration failed');
      }

      final authData = res.data!;
      final token = authData.token;

      ApiService.setToken(token);
      await PrefsHelper.saveToken(token);

      _userName = authData.user.fullName.isNotEmpty ? authData.user.fullName : name;
      _email = email;
      _phone = phone;
      _dateOfBirth = dob;
      _gender = gender;
      _profileImageUrl = authData.user.profileImage;
      _isLoggedIn = true;

      await PrefsHelper.saveLoginData(
        name: _userName,
        email: _email,
        phone: _phone,
        dob: _dateOfBirth,
        gender: _gender,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshProfile() async {
    try {
      final res = await ApiService.getProfile();
      if (res.success && res.data != null) {
        _applyUserModel(res.data!);
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> updateProfile({
    required String name,
    required String email,
    required String phone,
    required String dob,
    required String gender,
  }) async {
    await ApiService.updateProfile(fullName: name);

    _userName = name;
    _email = email;
    _phone = phone;
    _dateOfBirth = dob;
    _gender = gender;

    await PrefsHelper.saveLoginData(
      name: name,
      email: email,
      phone: phone,
      dob: dob,
      gender: gender,
    );

    notifyListeners();
  }

  Future<void> logout() async {
    ApiService.clearToken();
    await PrefsHelper.clearToken();
    await PrefsHelper.clearSession();
    _userName = '';
    _email = '';
    _phone = '';
    _dateOfBirth = '';
    _gender = 'Female';
    _profileImageUrl = null;
    _isLoggedIn = false;
    notifyListeners();
  }

  Future<void> deleteAccount() async {
    ApiService.clearToken();
    await PrefsHelper.logout();
    _userName = '';
    _email = '';
    _phone = '';
    _dateOfBirth = '';
    _gender = 'Female';
    _profileImageUrl = null;
    _isLoggedIn = false;
    notifyListeners();
  }

  void _applyUserModel(UserModel user) {
    _userName = user.fullName.isNotEmpty ? user.fullName : _userName;
    _profileImageUrl = user.profileImage;
  }
}
