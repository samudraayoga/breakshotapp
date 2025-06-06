import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool _obscureText = true;
  String _selectedRole = 'Pengusaha';
  final List<String> _roles = ['Pengusaha', 'Customer'];

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _register() async {
    if (_formKey.currentState!.validate()) {
      // Firestore: check if username exists
      final username = _usernameController.text.trim();
      final userQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: username)
          .get();
      if (userQuery.docs.isNotEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Username sudah terdaftar!')),
        );
        return;
      }
      // Hash password sebelum simpan
      final password = _passwordController.text;
      final hashedPass = sha256.convert(utf8.encode(password)).toString();
      // Save new user to Firestore
      await FirebaseFirestore.instance.collection('users').doc(username).set({
        'username': username,
        'password': hashedPass,
        'name': _nameController.text,
        'phone': _phoneController.text,
        'role': _selectedRole,
        'createdAt': FieldValue.serverTimestamp(),
        'balance': 0.0,
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration successful! Please login.')),
      );
      Navigator.of(context).pop();
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
              color: Colors.white.withOpacity(0.90),
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
                        'Create your account',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.2,
                          shadows: [
                            Shadow(
                              color: Colors.black54,
                              offset: Offset(1, 1),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Isi data diri untuk mendaftar',
                        style: const TextStyle(
                          fontSize: 16,
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
                      const SizedBox(height: 24),
                      DropdownButtonFormField<String>(
                        value: _selectedRole,
                        dropdownColor: Colors.black,
                        style: const TextStyle(color: Colors.white, shadows: [Shadow(color: Colors.black54, offset: Offset(1,1), blurRadius: 4)]),
                        decoration: InputDecoration(
                          labelText: 'Daftar Sebagai',
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
                        onChanged: (value) => setState(() => _selectedRole = value ?? 'pengusaha'),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _nameController,
                        style: const TextStyle(color: Colors.white, shadows: [Shadow(color: Colors.black54, offset: Offset(1,1), blurRadius: 4)]),
                        decoration: InputDecoration(
                          labelText: 'Nama Lengkap',
                          labelStyle: const TextStyle(color: Colors.white, shadows: [Shadow(color: Colors.black54, offset: Offset(1,1), blurRadius: 4)]),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black54),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                        validator: (value) => value == null || value.isEmpty ? 'Masukkan nama' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _phoneController,
                        style: const TextStyle(color: Colors.white, shadows: [Shadow(color: Colors.black54, offset: Offset(1,1), blurRadius: 4)]),
                        decoration: InputDecoration(
                          labelText: 'No. Telepon',
                          labelStyle: const TextStyle(color: Colors.white, shadows: [Shadow(color: Colors.black54, offset: Offset(1,1), blurRadius: 4)]),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black54),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                        validator: (value) => value == null || value.isEmpty ? 'Masukkan nomor telepon' : null,
                      ),
                      const SizedBox(height: 16),
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
                          onPressed: _register,
                          child: const Text('Daftar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white, shadows: [Shadow(color: Colors.black54, offset: Offset(1,1), blurRadius: 4)])),
                        ),
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
