import 'package:flutter/material.dart';
import 'package:eco_quest/config/app_theme.dart';
import 'package:eco_quest/screens/home/components/profile_section.dart';
import 'package:eco_quest/screens/home/components/active_quest.dart';

class HomeContent extends StatelessWidget {
  final Map<String, dynamic> userData; // Data user seperti nama dan poin
  final String? activeQuest; // ID quest aktif, nullable jika tidak ada quest aktif
  final List<String> badges; // List lencana yang dimiliki user
  final String rank; // Peringkat user

  const HomeContent({
    super.key,
    required this.userData,
    required this.activeQuest,
    required this.badges,
    required this.rank,
  });

  @override
  Widget build(BuildContext context) {
    final name = userData['name'] ?? 'Guest'; // Nama user dengan default 'Guest'
    final points = userData['points'] ?? 0; // Poin user dengan default 0

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(), // Scroll dengan efek bouncing
          child: SizedBox(
            height: constraints.maxHeight, // Tinggi sesuai layout yang tersedia
            child: Stack(
              clipBehavior: Clip.none, // Mengizinkan widget keluar dari batas container
              children: [
                // Container utama yang memuat profile dan quest aktif
                Positioned(
                  top: 100, // Posisi container di bawah maskot
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(32, 50, 32, 32),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.surface, // Warna latar belakang container
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(32), // Sudut atas membulat
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1), // Bayangan halus
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      // Membuat konten dalam container bisa di-scroll jika overflow
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ProfileSection(
                            name: name,
                            points: points,
                            badges: badges,
                            rank: rank,
                          ), // Bagian profile user
                          const SizedBox(height: 20),
                          ActiveQuest(
                            activeQuest: activeQuest,
                          ), // Menampilkan quest aktif jika ada
                        ],
                      ),
                    ),
                  ),
                ),
                // Maskot mengambang di atas container putih
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Image.asset(
                      'assets/images/maskot_2.png',
                      width: 150,
                      height: 150,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
