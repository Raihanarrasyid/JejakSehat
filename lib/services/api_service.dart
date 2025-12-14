import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://api-jejaksehat.alifjian.my.id';

  static Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/auth/login');
    
    try {
      final response = await http.post(
        url,
        headers: {
          'accept': '*/*',
          'Content-Type': 'application/json'
        },
        body: jsonEncode({
          'email': email,
          'password': password
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return data; 
      } else {
        throw Exception(data['message'] ?? 'Login Gagal (Cek Email/Password)');
      }
    } catch (e) {
      throw Exception('Login Error: $e');
    }
  }

  static Future<Map<String, dynamic>> register(String name, String email, String password) async {
    final url = Uri.parse('$baseUrl/auth/register');

    try {
      final response = await http.post(
        url,
        headers: {
          'accept': '*/*',
          'Content-Type': 'application/json'
        },
        body: jsonEncode({
          "name": name,
          "email": email,
          "password": password,
          "savedOffset": 0,
          "step": 0
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Registrasi Gagal');
      }
    } catch (e) {
      throw Exception('Register Error: $e');
    }
  }

  static Future<bool> syncDailySteps(String token, int steps, String date) async {
    await Future.delayed(const Duration(seconds: 2));

    final Map<String, dynamic> payload = {
      "user_id": "user_12345",
      "date": date,
      "total_steps": steps,
      "device_info": "Android/Sensor",
      "client_timestamp": DateTime.now().toIso8601String(),
    };

    try {
      print("[API] Mengirim Data ke Backend...");
      print("Payload: ${jsonEncode(payload)}");
      
      DateTime serverTime = DateTime.now();
      DateTime clientDate = DateTime.parse(date);

      if (clientDate.isAfter(serverTime)) {
        print("[API] Ditolak: User mencoba mengirim data masa depan.");
        return false;
      }

      print("[API] Sukses: Data tersimpan di server.");
      return true;
      
    } catch (e) {
      print("[API] Gagal: $e");
      return false;
    } 
  }
}
