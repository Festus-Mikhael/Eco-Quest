import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../widgets/custom_white_appbar.dart';
import '../auth/authentication_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // Fungsi async untuk mengambil data user dari Firestore berdasarkan UID user saat ini
  Future<Map<String, dynamic>?> _fetchUserData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid; // Ambil UID user saat ini
    if (uid == null) return null; // Jika belum login, return null

    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    // Ambil dokumen user berdasarkan UID
    return doc.exists ? doc.data() : null; // Return data user jika dokumen ada
  }

  // Fungsi logout user, lalu navigasi ke halaman Authentication (login)
  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut(); // Logout dari FirebaseAuth
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const AuthScreen()), // Navigasi ulang ke AuthScreen
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Ambil tema dari context

    return Scaffold(
      appBar: const WhiteAppBar(title: 'Profile', actions: []), // AppBar custom putih dengan judul
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _fetchUserData(), // Jalankan future ambil data user
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Saat data masih dimuat, tampilkan loading indikator
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null) {
            // Jika tidak ada data user, tampilkan pesan error sederhana
            return const Center(child: Text('Data pengguna tidak ditemukan.'));
          }

          final user = snapshot.data!; // Data user berhasil didapat
          final name = user['name'] ?? 'Guest'; // Ambil nama user, default 'Guest'
          // Bagian points dihapus sesuai permintaan

          return Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,  // Kolom hanya sebesar isinya
                crossAxisAlignment: CrossAxisAlignment.center, // Align tengah horizontal
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: const AssetImage('assets/images/maskot_1.png'), // Avatar default
                    backgroundColor: Colors.grey.shade200,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    name, // Tampilkan nama user
                    textAlign: TextAlign.center,
                    style: theme.textTheme.displayLarge?.copyWith(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary, // Warna hijau dari tema
                    ),
                  ),
                  // Bagian points sudah dihapus

                  const SizedBox(height: 120),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red, // Tombol warna merah
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12), // Sudut melengkung
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                    ),
                    onPressed: () => _logout(context), // Logout ketika ditekan
                    child: const Text(
                      'Logout',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
