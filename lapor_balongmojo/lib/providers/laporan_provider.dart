// File: lib/providers/laporan_provider.dart
import 'package:flutter/material.dart';
import 'package:lapor_balongmojo/models/laporan_model.dart';
import 'package:lapor_balongmojo/services/api_service.dart';

enum LaporanStatus { initial, loading, loaded, error }

class LaporanProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<LaporanModel> _laporanList = [];
  int _totalLaporan = 0; // <-- TAMBAHKAN INI
  LaporanStatus _status = LaporanStatus.initial;
  String _errorMessage = '';

  // Getter untuk list
  List<LaporanModel> get laporanList => _laporanList;
  // Getter untuk total (BARU)
  int get totalLaporan => _totalLaporan; 
  
  LaporanStatus get status => _status;
  String get errorMessage => _errorMessage;

  // --- MODIFIKASI FUNGSI fetchLaporan ---
  Future<void> fetchLaporan() async {
    _status = LaporanStatus.loading;
    notifyListeners();

    try {
      // Panggil kedua API secara bersamaan (lebih efisien)
      final results = await Future.wait([
        _apiService.getLaporan(),
        _apiService.getTotalLaporan(),
      ]);

      _laporanList = results[0] as List<LaporanModel>; // Hasil pertama
      _totalLaporan = results[1] as int;               // Hasil kedua

      _status = LaporanStatus.loaded;
    } catch (e) {
      _status = LaporanStatus.error;
      _errorMessage = e.toString();
      _totalLaporan = 0; // Set ke 0 jika error
    }
    notifyListeners(); // Beri tahu UI bahwa data baru siap
  }

  // Fungsi addLaporan sudah benar, tidak perlu diubah.
  // Ia sudah otomatis memanggil fetchLaporan() setelah sukses.
  Future<void> addLaporan(String judul, String deskripsi, String? fotoUrl) async {
    try {
      await _apiService.postLaporan(judul, deskripsi, fotoUrl);
      await fetchLaporan(); // Ini akan me-refresh list DAN total
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateStatus(int id, String status) async {
    try {
      await _apiService.updateStatusLaporan(id, status);
      await fetchLaporan(); // Ini juga akan me-refresh list DAN total
    } catch (e) {
      rethrow;
    }
  }
}