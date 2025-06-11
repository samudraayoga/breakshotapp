import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'register.dart';
import 'home.dart';
import 'homepengusaha.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscureText = true;
  bool _isLoading = false;
  bool _formValid = false;
  String _selectedRole = 'Pengusaha';
  final List<String> _roles = ['Pengusaha', 'Customer'];

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Cek validitas form setiap perubahan
  void _validateForm() {
    setState(() {
      _formValid = _formKey.currentState?.validate() ?? false;
    });
  }

  // Fungsi login 
  void _login() async {
    if (!_formValid) return;
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    String inputUsername = _usernameController.text.trim();
    String inputPassword = _passwordController.text;
    String inputRole = _selectedRole;
    // Hash password sebelum query
    final hashedInput = sha256.convert(utf8.encode(inputPassword)).toString();
    // Query Firestore for user
    final query = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: inputUsername)
        .where('password', isEqualTo: hashedInput)
        .where('role', isEqualTo: inputRole)
        .get();
    if (query.docs.isNotEmpty) {
      final user = query.docs.first.data();
      await prefs.setBool('is_logged_in', true);
      await prefs.setString('username', user['username']);
      await prefs.setString('password', user['password']);
      await prefs.setString('name', user['name']);
      await prefs.setString('phone', user['phone']);
      await prefs.setString('role', user['role']);
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      if (user['role'].toString().toLowerCase() == 'pengusaha') {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomePengusahaPage()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username atau password salah!')),
      );
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).copyWith(
      colorScheme: ColorScheme(
        brightness: Brightness.dark,
        primary: const Color(0xFF1B5E20), // dark green
        onPrimary: Colors.white,
        secondary: const Color(0xFFFFD600), // vibrant yellow
        onSecondary: Colors.black,
        error: Colors.red,
        onError: Colors.white,
        background: const Color(0xFF121212), // dark grey
        onBackground: Colors.white,
        surface: const Color(0xFF2C2C2C), // charcoal grey
        onSurface: Colors.white,
        surfaceVariant: const Color(0xFF232323),
        onSurfaceVariant: Colors.white,
        outline: Colors.grey.shade700,
        outlineVariant: Colors.grey.shade800,
        shadow: Colors.black,
        scrim: Colors.black,
        inverseSurface: Colors.white,
        onInverseSurface: Colors.black,
        inversePrimary: const Color(0xFF1B5E20),
      ),
    );
    return Scaffold(
      backgroundColor: theme.colorScheme.background, // Warna latar belakang utama login
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo atau icon di atas
                Padding(
                  padding: const EdgeInsets.only(bottom: 28.0),
                  child: CircleAvatar(
                    radius: 48,
                    backgroundColor: theme.colorScheme.primary,
                    child: Icon(Icons.sports_bar, size: 52, color: theme.colorScheme.onPrimary),
                  ),
                ),
                Card(
                  color: theme.colorScheme.surface,
                  elevation: 10,
                  shadowColor: theme.colorScheme.shadow.withOpacity(0.18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
                    child: Form(
                      key: _formKey,
                      onChanged: _validateForm,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Judul aplikasi
                          Text(
                            'BreakShot',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.montserrat(
                              fontSize: 30,
                              fontWeight: FontWeight.w800,
                              color: theme.colorScheme.primary,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          // Tagline aplikasi
                          Text(
                            '-break your limit-',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.montserrat(
                              fontSize: 15,
                              color: theme.colorScheme.secondary,
                              fontStyle: FontStyle.italic,
                              letterSpacing: 1.1,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'Login ke akun Anda',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.montserrat(
                              fontSize: 17,
                              color: theme.colorScheme.onSurface.withOpacity(0.85),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 28),
                          // Dropdown role
                          DropdownButtonFormField<String>(
                            value: _selectedRole,
                            dropdownColor: theme.colorScheme.surfaceVariant,
                            style: GoogleFonts.montserrat(color: theme.colorScheme.onSurface),
                            decoration: InputDecoration(
                              labelText: 'Login sebagai',
                              labelStyle: GoogleFonts.montserrat(color: theme.colorScheme.primary),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(color: theme.colorScheme.primary.withOpacity(0.5)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                            items: _roles.map((role) => DropdownMenuItem(
                              value: role,
                              child: Text(role, style: GoogleFonts.montserrat(color: theme.colorScheme.onSurface)),
                            )).toList(),
                            onChanged: (value) => setState(() => _selectedRole = value ?? 'Pengusaha'),
                          ),
                          const SizedBox(height: 18),
                          // Username field
                          TextFormField(
                            controller: _usernameController,
                            style: GoogleFonts.montserrat(color: theme.colorScheme.onSurface, fontWeight: FontWeight.w500),
                            decoration: InputDecoration(
                              labelText: 'Username',
                              labelStyle: GoogleFonts.montserrat(color: theme.colorScheme.primary),
                              filled: true,
                              fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.7),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(color: theme.colorScheme.primary.withOpacity(0.5)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            ),
                            validator: (value) => value == null || value.isEmpty ? 'Masukkan username' : null,
                          ),
                          const SizedBox(height: 16),
                          // Password field
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscureText,
                            style: GoogleFonts.montserrat(color: theme.colorScheme.onSurface, fontWeight: FontWeight.w500),
                            decoration: InputDecoration(
                              labelText: 'Password',
                              labelStyle: GoogleFonts.montserrat(color: theme.colorScheme.primary),
                              filled: true,
                              fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.7),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(color: theme.colorScheme.primary.withOpacity(0.5)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              suffixIcon: IconButton(
                                icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off, color: theme.colorScheme.primary),
                                onPressed: () => setState(() => _obscureText = !_obscureText),
                              ),
                            ),
                            validator: (value) => value == null || value.isEmpty ? 'Masukkan password' : null,
                          ),
                          const SizedBox(height: 26),
                          // Tombol Login
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.primary, // Warna tombol login (hijau gelap)
                                foregroundColor: theme.colorScheme.onPrimary, // Warna teks/icon tombol login (putih)
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                elevation: 3,
                              ),
                              onPressed: _formValid && !_isLoading ? _login : null,
                              child: _isLoading
                                  ? SizedBox(
                                      width: 24, height: 24,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: theme.colorScheme.onPrimary),
                                    )
                                  : Text('Login', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 18, color: theme.colorScheme.onPrimary)),
                            ),
                          ),
                          const SizedBox(height: 18),
                          // Tombol daftar
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (context) => const RegisterForm()),
                              );
                            },
                            child: Text('Belum punya akun? Daftar', style: GoogleFonts.montserrat(color: theme.colorScheme.secondary, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
