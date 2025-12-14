import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jejaksehat/services/api_service.dart'; 

class AuthService extends ChangeNotifier {
  bool _isLoggedIn = false;
  String? _token;
  String _userName = "User";
  bool _isLoading = false;

  bool get isLoggedIn => _isLoggedIn;
  String get userName => _userName;
  bool get isLoading => _isLoading;
  String? get token => _token;

  Future<void> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('accessToken')) return;

    _token = prefs.getString('accessToken');
    _userName = prefs.getString('userName') ?? "User";
    _isLoggedIn = true;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await ApiService.login(email, password);
      _token = data['accessToken'];
      _userName = email.split('@')[0]; 
      _isLoggedIn = true;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('accessToken', _token!);
      await prefs.setString('userName', _userName);
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register(String name, String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      await ApiService.register(name, email, password);
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isLoggedIn = false;
    _token = null;
    _userName = "User";
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');
    await prefs.remove('userName');
    
    notifyListeners();
  }
}
