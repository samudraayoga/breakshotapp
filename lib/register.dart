import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
      backgroundColor: theme.colorScheme.background, // Warna latar belakang utama register
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
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
                            'Buat akun baru',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.montserrat(
                              fontSize: 17,
                              color: theme.colorScheme.onSurface.withOpacity(0.85),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 28),
                          DropdownButtonFormField<String>(
                            value: _selectedRole,
                            dropdownColor: theme.colorScheme.surfaceVariant,
                            style: GoogleFonts.montserrat(color: theme.colorScheme.onSurface),
                            decoration: InputDecoration(
                              labelText: 'Daftar Sebagai',
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
                          const SizedBox(height: 24),
                          TextFormField(
                            controller: _nameController,
                            style: GoogleFonts.montserrat(color: theme.colorScheme.onSurface, fontWeight: FontWeight.w500),
                            decoration: InputDecoration(
                              labelText: 'Nama Lengkap',
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
                            validator: (value) => value == null || value.isEmpty ? 'Masukkan nama' : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _phoneController,
                            style: GoogleFonts.montserrat(color: theme.colorScheme.onSurface, fontWeight: FontWeight.w500),
                            decoration: InputDecoration(
                              labelText: 'No. Telepon',
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
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Masukkan nomor telepon';
                              if (!RegExp(r'^[0-9]+$').hasMatch(value)) return 'Nomor telepon hanya boleh angka';
                              if (value.length < 10) return 'Nomor telepon minimal 10 digit';
                              if (value.length > 15) return 'Nomor telepon maksimal 15 digit';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
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
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Masukkan username';
                              if (value.length < 6) return 'Username minimal 6 karakter';
                              if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(value)) return 'Username hanya boleh huruf dan angka';
                              if (value.contains(' ')) return 'Username tidak boleh mengandung spasi';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
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
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Masukkan password';
                              if (value.length < 8) return 'Password minimal 8 karakter';
                              return null;
                            },
                          ),
                          const SizedBox(height: 32),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.primary, // Warna tombol daftar (hijau gelap)
                                foregroundColor: theme.colorScheme.onPrimary, // Warna teks/icon tombol daftar (putih)
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                elevation: 3,
                              ),
                              onPressed: _register,
                              child: Text('Daftar', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 18, color: theme.colorScheme.onPrimary)),
                            ),
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
