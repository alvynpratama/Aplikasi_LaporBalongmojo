// File: lib/providers/auth_provider.dart

import 'package:flutter/material.dart';
import 'package:lapor_balongmojo/services/api_service.dart';
import 'package:lapor_balongmojo/services/secure_storage_service.dart';
import 'package:lapor_balongmojo/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

// --- 1. IMPORT FCM SERVICE ---
import 'package:lapor_balongmojo/services/fcm_service.dart';

enum AuthStatus { uninitialized, authenticated, unauthenticated }

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final SecureStorageService _storageService = SecureStorageService();

  // --- 2. BUAT INSTANCE FCM SERVICE ---
  final FcmService _fcmService = FcmService();

  AuthStatus _status = AuthStatus.uninitialized;
  UserModel? _user;
  String? _token;

  AuthStatus get status => _status;
  UserModel? get user => _user;
  String? get token => _token;
  bool get isLoggedIn => _status == AuthStatus.authenticated;
  String get userRole => _user?.role ?? 'masyarakat';

  AuthProvider() {
    tryAutoLogin();
  }

  Future<void> tryAutoLogin() async {
    final token = await _storageService.readToken();
    if (token == null) {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return;
    }

    _token = token;

    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('userRole') ?? 'masyarakat';
    final nama = prefs.getString('userName') ?? 'User';
    final id = prefs.getInt('userId') ?? 0;

    _user = UserModel(id: id, nama: nama, email: '', role: role);
    _status = AuthStatus.authenticated;
    
    // --- PANGGIL INITIALIZE FCM (Langganan Topik) ---
    await _fcmService.initialize();

    notifyListeners();
  }

  // Proses login
  Future<void> login(String email, String password) async {
    try {
      final responseData = await _apiService.login(email, password);

      _token = responseData['token'];
      _user = UserModel.fromJson(responseData['user']);

      await _storageService.writeToken(_token!);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userRole', _user!.role);
      await prefs.setString('userName', _user!.nama);
      await prefs.setInt('userId', _user!.id);

      _status = AuthStatus.authenticated;
      
      // --- PANGGIL INITIALIZE FCM (Langganan Topik) ---
      await _fcmService.initialize();

      notifyListeners();
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      rethrow;
    }
  }

  // Proses registrasi
  Future<void> registerMasyarakat(
      String nama, String email, String noTelp, String password) async {
    await _apiService.registerMasyarakat(nama, email, noTelp, password);
  }

  // Proses logout
  Future<void> logout() async {
    _token = null;
    _user = null;
    _status = AuthStatus.unauthenticated;

    await _storageService.deleteToken();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    // --- PERBAIKAN: Panggil UNSUBSCRIBE TOPIK ---
    await _fcmService.unsubscribeFromTopic();

    notifyListeners();
  }
}