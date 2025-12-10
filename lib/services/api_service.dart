import 'dart:convert';
import 'dart:async';

class ApiService {
  // Simulasi URL Backend
  static const String _baseUrl = 'https://api.jejaksehat-dummy.com/v1';

  static Future<bool> syncDailySteps(String date, int steps) async {
    // Simulasi delay jaringan
    await Future.delayed(const Duration(seconds: 2));

    final Map<String, dynamic> payload = {
      "user_id": "user_12345", // Didapat dari login session
      "date": date,
      "total_steps": steps,
      "device_info": "Android/Sensor",
      "client_timestamp": DateTime.now().toIso8601String(), // Waktu di HP User
      // "signature": "sha256_hash_here" // (Opsional) Untuk keamanan data
    };

    try {
      print("[API] Mengirim Data ke Backend...");
      print("Payload: ${jsonEncode(payload)}");
      
      DateTime serverTime = DateTime.now(); // Anggap ini waktu server
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