import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'register.dart';
import 'home.dart';
import 'homepengusaha.dart';

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
  String _selectedRole = 'Pengusaha';
  final List<String> _roles = ['Pengusaha', 'Customer'];

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF212121), // abu tua
              Color(0xFF616161), // abu sedang
              Color(0xFF000000), // hitam
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Card(
              elevation: 10,
              color: Colors.blueGrey[900],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Billiard House',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black54,
                              offset: Offset(1, 1),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Welcome Back!',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[200],
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Login ke akun Anda untuk melanjutkan',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[200], // subtitle abu muda
                        ),
                      ),
                      const SizedBox(height: 24),
                      DropdownButtonFormField<String>(
                        value: _selectedRole,
                        dropdownColor: Colors.black,
                        style: const TextStyle(color: Colors.white, shadows: [Shadow(color: Colors.black54, offset: Offset(1,1), blurRadius: 4)]),
                        decoration: InputDecoration(
                          labelText: 'Login sebagai',
                          labelStyle: const TextStyle(color: Colors.white, shadows: [Shadow(color: Colors.black54, offset: Offset(1,1), blurRadius: 4)]),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black54),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                        items: _roles.map((role) => DropdownMenuItem(
                          value: role,
                          child: Text(role, style: const TextStyle(color: Colors.white, shadows: [Shadow(color: Colors.black54, offset: Offset(1,1), blurRadius: 4)])),
                        )).toList(),
                        onChanged: (value) => setState(() => _selectedRole = value ?? 'Pengusaha'),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _usernameController,
                        style: const TextStyle(color: Colors.white, shadows: [Shadow(color: Colors.black54, offset: Offset(1,1), blurRadius: 4)]),
                        decoration: InputDecoration(
                          labelText: 'Username',
                          labelStyle: const TextStyle(color: Colors.white, shadows: [Shadow(color: Colors.black54, offset: Offset(1,1), blurRadius: 4)]),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black54),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                        validator: (value) => value == null || value.isEmpty ? 'Masukkan username' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscureText,
                        style: const TextStyle(color: Colors.white, shadows: [Shadow(color: Colors.black54, offset: Offset(1,1), blurRadius: 4)]),
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: const TextStyle(color: Colors.white, shadows: [Shadow(color: Colors.black54, offset: Offset(1,1), blurRadius: 4)]),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black54),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off, color: Colors.black54),
                            onPressed: () => setState(() => _obscureText = !_obscureText),
                          ),
                        ),
                        validator: (value) => value == null || value.isEmpty ? 'Masukkan password' : null,
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: _login,
                          child: const Text('Login', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white, shadows: [Shadow(color: Colors.black54, offset: Offset(1,1), blurRadius: 4)])),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => const RegisterForm()),
                          );
                        },
                        child: const Text('Belum punya akun? Daftar', style: TextStyle(color: Colors.white, shadows: [Shadow(color: Colors.black54, offset: Offset(1,1), blurRadius: 4)])),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
