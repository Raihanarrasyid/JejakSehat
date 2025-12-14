import 'package:flutter/material.dart';
import 'services/auth_service.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const JejakSehatApp());
}

class JejakSehatApp extends StatefulWidget {
  const JejakSehatApp({super.key});

  @override
  State<JejakSehatApp> createState() => _JejakSehatAppState();
}

class _JejakSehatAppState extends State<JejakSehatApp> {
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _authService.tryAutoLogin();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _authService,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Jejak Sehat',
          theme: ThemeData(
            primarySwatch: Colors.teal,
            useMaterial3: true,
          ),
          home: _authService.isLoggedIn
              ? HomeScreen(authService: _authService)
              : LoginScreen(authService: _authService),
        );
      },
    );
  }
}