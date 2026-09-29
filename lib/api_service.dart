import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Menggunakan IP lokal komputer dan nama folder yang benar (bengkel_api)
  static const String baseUrl = "http://192.168.18.24/bengkel_api/api_pelanggan.php";

  // ==========================================
  // API UNTUK PELANGGAN
  // ==========================================
  static Future<List<dynamic>> getPelanggan() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['data'];
    }
    throw Exception('Gagal mengambil data');
  }

  static Future<bool> tambahPelanggan(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );
    return jsonDecode(response.body)['status'] == 'success';
  }

  static Future<bool> updatePelanggan(Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );
    return jsonDecode(response.body)['status'] == 'success';
  }

  static Future<bool> hapusPelanggan(String id) async {
    final response = await http.delete(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"id_pelanggan": id}),
    );
    return jsonDecode(response.body)['status'] == 'success';
  }

  // ==========================================
  // API UNTUK SERVIS
  // ==========================================
  static Future<List<dynamic>> getServis() async {
    final response = await http.get(Uri.parse("http://192.168.18.24/bengkel_api/api_servis.php"));
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['data'];
    }
    throw Exception('Gagal mengambil data servis');
  }

  static Future<bool> tambahServis(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse("http://192.168.18.24/bengkel_api/api_servis.php"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      return decoded['status'] == 'success';
    }
    return false;
  }

  // ==========================================
  // API UNTUK SPAREPART
  // ==========================================
  static Future<List<dynamic>> getSparepart() async {
    final response = await http.get(Uri.parse("http://192.168.18.24/bengkel_api/api_sparepart.php"));
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['data'];
    }
    throw Exception('Gagal mengambil data sparepart');
  }
  
  static Future<bool> tambahSparepart(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse("http://192.168.18.24/bengkel_api/api_sparepart.php"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      return decoded['status'] == 'success';
    }
    return false;
  }
  
  // ==========================================
  // API UNTUK MEKANIK
  // ==========================================
  static Future<List<dynamic>> getMekanik() async {
    final response = await http.get(Uri.parse("http://192.168.18.24/bengkel_api/api_mekanik.php"));
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['data'];
    }
    throw Exception('Gagal mengambil data mekanik');
  }

  static Future<bool> tambahMekanik(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse("http://192.168.18.24/bengkel_api/api_mekanik.php"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      return decoded['status'] == 'success';
    }
    return false;
  }

  // ==========================================
  // API UNTUK PEMBAYARAN
  // ==========================================
  static Future<bool> bayarServis(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse("http://192.168.18.24/bengkel_api/api_pembayaran.php"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      return decoded['status'] == 'success';
    }
    return false;
  }

  // ==========================================
  // API UNTUK LOGIN
  // ==========================================
  static Future<bool> login(String username, String password, String role) async {
    final response = await http.post(
      Uri.parse("http://192.168.18.24/bengkel_api/api_login.php"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": username,
        "password": password,
        "role": role
      }),
    );
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      return decoded['status'] == 'success';
    }
    return false;
  }
}