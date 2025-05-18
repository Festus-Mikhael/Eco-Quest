import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eco_quest/config/app_theme.dart';
import 'package:flutter/material.dart';

class ActiveQuest extends StatelessWidget {
  final String? activeQuest; // ID quest aktif yang diambil user, nullable jika belum ada

  const ActiveQuest({
    super.key,
    required this.activeQuest,
  });

  @override
  Widget build(BuildContext context) {
    // Style kartu quest dengan warna sekunder dan bayangan halus
    final cardStyle = BoxDecoration(
      color: AppTheme.lightTheme.colorScheme.secondary,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 8,
          spreadRadius: 2,
        ),
      ],
    );

    if (activeQuest == null) {
      // Jika tidak ada quest yang aktif, tampilkan pesan ini
      return Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 16),
        width: 300,
        decoration: cardStyle,
        child: const Text(
          "Belum ada quest yang diambil",
          style: TextStyle(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    // Jika ada quest aktif, ambil data quest tersebut dari Firestore
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('quests')
          .doc(activeQuest)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Tampilkan loading spinner saat data quest sedang dimuat
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          // Tampilkan pesan error jika terjadi kesalahan saat pengambilan data
          return const Text("Terjadi kesalahan saat mengambil data quest");
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          // Jika dokumen quest tidak ditemukan di Firestore
          return const Text("Quest tidak ditemukan");
        }

        final questData = snapshot.data!;
        // Ambil field-field quest, dengan default jika null
        final title = questData['title'] ?? 'Unknown Quest';
        final points = questData['points'] ?? 0;
        final description = questData['description'] ?? 'No description available'; // Menambahkan deskripsi

        // Tampilkan kartu quest dengan title, deskripsi, dan poin
        return Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(bottom: 16),
          width: 300,
          decoration: cardStyle,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              // Menampilkan deskripsi quest dengan font kecil dan warna putih
              Text(
                description,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white, // Memberikan warna sedikit lebih terang
                ),
              ),
              Text(
                'Poin: $points',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}
