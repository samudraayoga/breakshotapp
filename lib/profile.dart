import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? name;
  String? phone;
  String? username;
  String? decryptedPassword;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString('name') ?? '-';
      phone = prefs.getString('phone') ?? '-';
      username = prefs.getString('username') ?? '-';
    });
  }

  Future<void> _decryptPassword() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPassword = prefs.getString('password');
    if (!mounted) return;
    setState(() {
      decryptedPassword = savedPassword ?? 'Password tidak ditemukan';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Pengguna', style: TextStyle(color: Colors.white, shadows: [Shadow(color: Colors.black54, offset: Offset(1,1), blurRadius: 4)])),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
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
          child: Card(
            elevation: 8,
            color: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 36),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.account_circle, size: 80, color: Colors.white),
                  const SizedBox(height: 16),
                  Text(
                    name ?? '-',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white, shadows: [Shadow(color: Colors.black54, offset: Offset(1,1), blurRadius: 4)]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Username: ${username ?? '-'}',
                    style: const TextStyle(fontSize: 16, color: Colors.white, shadows: [Shadow(color: Colors.black54, offset: Offset(1,1), blurRadius: 4)]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No. Telepon: ${phone ?? '-'}',
                    style: const TextStyle(fontSize: 16, color: Colors.white, shadows: [Shadow(color: Colors.black54, offset: Offset(1,1), blurRadius: 4)]),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: _decryptPassword,
                      icon: const Icon(Icons.lock_open, color: Colors.white),
                      label: const Text('Tampilkan Password', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, shadows: [Shadow(color: Colors.black54, offset: Offset(1,1), blurRadius: 4)])),
                    ),
                  ),
                  if (decryptedPassword != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      decryptedPassword!,
                      style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold, shadows: [Shadow(color: Colors.black54, offset: Offset(1,1), blurRadius: 4)]),
                    ),
                  ],
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[900],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () async {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setBool('is_logged_in', false);
                        if (!mounted) return;
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => const LoginForm()),
                          (route) => false,
                        );
                      },
                      icon: const Icon(Icons.logout, color: Colors.white),
                      label: const Text('Logout', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, shadows: [Shadow(color: Colors.black54, offset: Offset(1,1), blurRadius: 4)])),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
