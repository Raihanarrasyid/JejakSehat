import 'package:flutter/material.dart';
import 'register_screen.dart'; // Nanti kita buat
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  final AuthService authService; // Inject service
  const LoginScreen({super.key, required this.authService});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await widget.authService.login(
        _emailController.text, 
        _passwordController.text
      );
      // Jika sukses, main.dart akan otomatis pindah ke HomeScreen karena listener
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.directions_run, size: 80, color: Colors.teal),
                const SizedBox(height: 20),
                const Text("Jejak Sehat", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.teal)),
                const SizedBox(height: 40),
                
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: "Email", border: OutlineInputBorder(), prefixIcon: Icon(Icons.email)),
                  validator: (v) => v!.isEmpty ? "Email tidak boleh kosong" : null,
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: "Password", border: OutlineInputBorder(), prefixIcon: Icon(Icons.lock)),
                  obscureText: true,
                  validator: (v) => v!.isEmpty ? "Password tidak boleh kosong" : null,
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: widget.authService.isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                    child: widget.authService.isLoading 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("MASUK"),
                  ),
                ),
                
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => RegisterScreen(authService: widget.authService)));
                  },
                  child: const Text("Belum punya akun? Daftar di sini"),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}