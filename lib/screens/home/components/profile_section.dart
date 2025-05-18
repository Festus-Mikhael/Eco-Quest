import 'package:flutter/material.dart';

class ProfileSection extends StatelessWidget {
  final String name;         // Nama user yang akan ditampilkan
  final int points;          // Jumlah poin user
  final List<String> badges; // Daftar lencana/badge user
  final String rank;         // Peringkat user

  const ProfileSection({
    super.key,
    required this.name,
    required this.points,
    required this.badges,
    required this.rank,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme; // Warna tema yang digunakan

    return Column(
      children: [
        // Menampilkan nama user dengan gaya khusus
        Text(
          name,
          style: TextStyle(
            color: colorScheme.primary, // Warna utama dari tema
            fontSize: 24,
            fontWeight: FontWeight.w900, // Tebal dan menonjol
          ),
        ),
        const SizedBox(height: 10), // Jarak vertikal

        // Container yang menampung rank, badges, dan points
        Container(
          padding: const EdgeInsets.all(16),
          width: 300,
          constraints: const BoxConstraints(minHeight: 80),
          decoration: BoxDecoration(
            color: colorScheme.primary, // Latar belakang sesuai tema
            borderRadius: BorderRadius.circular(8), // Sudut membulat
          ),

          // IntrinsicHeight membuat row memiliki tinggi sama pada semua kolom
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Bagian Rank
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.insights, color: colorScheme.onSecondary),
                      const SizedBox(height: 4),
                      Text(
                        rank,
                        style: TextStyle(color: colorScheme.onSecondary),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                // Garis pemisah vertikal pertama
                Container(
                  width: 2,
                  margin: const EdgeInsets.symmetric(vertical: 2),
                  color: colorScheme.onSecondary.withAlpha(200), // Warna garis semi transparan
                ),

                // Bagian Badges
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.emoji_events, color: colorScheme.onSecondary),
                      const SizedBox(height: 4),
                      Text(
                        badges.isEmpty ? 'None' : badges.join(', '),  // Tampilkan daftar badge atau 'None' jika kosong
                        style: TextStyle(color: colorScheme.onSecondary),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                // Garis pemisah vertikal kedua
                Container(
                  width: 2,
                  margin: const EdgeInsets.symmetric(vertical: 2),
                  color: colorScheme.onSecondary.withAlpha(200),
                ),

                // Bagian Points
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.star, color: colorScheme.onSecondary),
                      const SizedBox(height: 4),
                      Text(
                        points.toString(), // Tampilkan poin sebagai string
                        style: TextStyle(color: colorScheme.onSecondary),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}
