import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:lapor_balongmojo/models/laporan_model.dart';
import 'package:lapor_balongmojo/models/berita_model.dart';
import 'package:lapor_balongmojo/services/secure_storage_service.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart';

class ApiService {
  // Ganti sesuai IP Anda jika perlu
  static const String _baseUrl = 'http://10.0.2.2:3000'; 
  static const String publicBaseUrl = _baseUrl;
  final SecureStorageService _storageService = SecureStorageService();

  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _storageService.readToken();
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    };
  }

  // --- FUNGSI POST BERITA YANG DIPERBAIKI ---
  Future<void> postBerita(
    String judul,
    String isi,
    String? gambarUrl,
    bool isPeringatanDarurat,
  ) async {
    final headers = await _getAuthHeaders();
    
    // Kita siapkan datanya dulu agar bisa di-print
    final Map<String, dynamic> dataToSend = {
        'judul': judul,
        'isi': isi,
        'gambar_url': gambarUrl,
        'is_peringatan_darurat': isPeringatanDarurat, // <--- INI KUNCINYA
    };

    // --- [CCTV 2] DEBUG API ---
    print("==================================================");
    print(">>> [FLUTTER API] Mengirim JSON ke Backend:");
    print(jsonEncode(dataToSend)); 
    print("==================================================");

    final response = await http.post(
      Uri.parse('$_baseUrl/berita'),
      headers: headers,
      body: jsonEncode(dataToSend),
    );

    if (response.statusCode != 201) {
      throw Exception(jsonDecode(response.body)['message']);
    }
  }
  // ------------------------------------------

  // --- (SISA FUNGSI LAINNYA TETAP SAMA, SAYA COPYKAN SUPAYA AMAN) ---

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(jsonDecode(response.body)['message']);
    }
  }

  Future<void> registerMasyarakat(String nama, String email, String noTelp, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/register/masyarakat'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({'nama_lengkap': nama, 'email': email, 'no_telepon': noTelp, 'password': password}),
    );
    if (response.statusCode != 201) throw Exception(jsonDecode(response.body)['message']);
  }

  Future<List<LaporanModel>> getLaporan() async {
    final headers = await _getAuthHeaders();
    final response = await http.get(Uri.parse('$_baseUrl/laporan'), headers: headers);
    if (response.statusCode == 200) {
      List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => LaporanModel.fromJson(json)).toList();
    } else {
      throw Exception('Gagal memuat laporan');
    }
  }

  Future<void> postLaporan(String judul, String deskripsi, String? fotoUrl) async {
    final headers = await _getAuthHeaders();
    final response = await http.post(
      Uri.parse('$_baseUrl/laporan'),
      headers: headers,
      body: jsonEncode({'judul': judul, 'deskripsi': deskripsi, 'foto_url': fotoUrl}),
    );
    if (response.statusCode != 201) throw Exception(jsonDecode(response.body)['message']);
  }

  Future<void> updateStatusLaporan(int id, String status) async {
    final headers = await _getAuthHeaders();
    final response = await http.put(
      Uri.parse('$_baseUrl/laporan/$id'),
      headers: headers,
      body: jsonEncode({'status': status}),
    );
    if (response.statusCode != 200) throw Exception(jsonDecode(response.body)['message']);
  }

  Future<List<BeritaModel>> getBerita() async {
    final response = await http.get(Uri.parse('$_baseUrl/berita'));
    if (response.statusCode == 200) {
      List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => BeritaModel.fromJson(json)).toList();
    } else {
      throw Exception('Gagal memuat berita');
    }
  }

  Future<String> uploadImage(File imageFile) async {
    final token = await _storageService.readToken();
    var request = http.MultipartRequest('POST', Uri.parse('$_baseUrl/upload'));
    request.headers['Authorization'] = 'Bearer $token';
    request.files.add(await http.MultipartFile.fromPath('image', imageFile.path, filename: basename(imageFile.path), contentType: MediaType('image', 'jpeg')));
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);
    if (response.statusCode == 201) {
      return jsonDecode(response.body)['imageUrl'];
    } else {
      throw Exception('Gagal upload gambar: ${response.body}');
    }
  }

  Future<List<dynamic>> getPendingUsers() async {
    final headers = await _getAuthHeaders();
    final response = await http.get(Uri.parse('$_baseUrl/admin/users-pending'), headers: headers);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Gagal memuat user pending');
    }
  }

  Future<void> verifikasiUser(int userId) async {
    final headers = await _getAuthHeaders();
    final response = await http.put(Uri.parse('$_baseUrl/admin/verifikasi/$userId'), headers: headers);
    if (response.statusCode != 200) throw Exception(jsonDecode(response.body)['message']);
  }

  Future<void> tolakUser(int userId) async {
    final headers = await _getAuthHeaders();
    final response = await http.delete(Uri.parse('$_baseUrl/admin/tolak/$userId'), headers: headers);
    if (response.statusCode != 200) throw Exception(jsonDecode(response.body)['message']);
  }

  Future<int> getTotalLaporan() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/stats/laporan-total'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['total_laporan'] as int;
      } else {
        return 0;
      }
    } catch (e) {
      print('Error getTotalLaporan: $e');
      return 0;
    }
  }
}