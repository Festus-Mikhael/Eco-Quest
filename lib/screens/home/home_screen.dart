import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../../widgets/custom_green_appbar.dart';
import 'components/home_content.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser; // Ambil user yang sedang login
    if (user == null) {
      // Jika tidak ada user, tampilkan pesan
      return const Scaffold(
        body: Center(child: Text('User not logged in')),
      );
    }

    final userDocRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    // Referensi dokumen user di Firestore berdasarkan UID

    return Scaffold(
      backgroundColor: AppTheme.lightTheme.colorScheme.primary,
      appBar: const GreenAppBar(title: 'Eco Hero'),
      body: StreamBuilder<DocumentSnapshot>(
        stream: userDocRef.snapshots(), // Stream realtime data user
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            // Loading indicator saat menunggu data user
            return const Center(child: CircularProgressIndicator());
          }
          if (userSnapshot.hasError) {
            // Tampilkan error jika terjadi error pada stream user
            return _buildErrorState(userSnapshot.error.toString());
          }
          if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
            // Jika data user tidak ada atau tidak ditemukan
            return _buildNoDataState();
          }

          final userData = userSnapshot.data!.data() as Map<String, dynamic>;
          // Data user diambil dari snapshot
          final activeQuest = userData['activeQuest']; // Quest aktif user (bisa null)
          final userPoints = userData['points'] ?? 0; // Points user, default 0

          // Stream untuk leaderboard top 5 user berdasarkan points tertinggi
          final leaderboardStream = FirebaseFirestore.instance
              .collection('users')
              .orderBy('points', descending: true)
              .limit(10)
              .snapshots();

          return StreamBuilder<QuerySnapshot>(
            stream: leaderboardStream,
            builder: (context, leaderboardSnapshot) {
              if (leaderboardSnapshot.connectionState == ConnectionState.waiting) {
                // Loading indicator saat menunggu leaderboard
                return const Center(child: CircularProgressIndicator());
              }
              if (leaderboardSnapshot.hasError) {
                // Tampilkan error jika gagal load leaderboard
                return Center(child: Text('Error loading leaderboard'));
              }

              final leaderboardDocs = leaderboardSnapshot.data?.docs ?? [];

              // Buat list leaderboard user dari dokumen snapshot
              final leaderboardUsers = leaderboardDocs.map((doc) {
                final data = doc.data()! as Map<String, dynamic>;
                return {
                  'uid': doc.id,
                  'name': data['name'] ?? 'No Name',
                  'points': data['points'] ?? 0,
                };
              }).toList();

              // Cari posisi (index) user di dalam top 5 leaderboard
              int rank = leaderboardUsers.indexWhere((u) => u['uid'] == user.uid) + 1;

              // Jika rank = 0 artinya user tidak ada di top 5
              if (rank == 0) {
                // Karena ini async, kita tidak bisa hitung rank tepat di sini
                // Jadi sementara set rank jadi -1 dan di UI nanti tampil '>5'
                rank = -1;
              }

              // Hitung badges berdasarkan poin user
              final badges = _getBadgesFromPoints(userPoints);

              // Kirim data ke widget HomeContent untuk ditampilkan
              return HomeContent(
                userData: userData,
                activeQuest: activeQuest,
                rank: rank == -1 ? '>10' : rank.toString(), // Tampilkan rank atau '>5'
                badges: badges,
              );
            },
          );
        },
      ),
    );
  }

  // Fungsi hitung badges sesuai poin user
  List<String> _getBadgesFromPoints(int points) {
    if (points >= 300) {
      return ['Eco Hero'];
    } else if (points >= 200) {
      return ['Pohon'];
    } else if (points >= 100) {
      return ['Tunas'];
    } else if (points >= 0) {
      return ['Bibit'];
    } else {
      return [];
    }
  }

  // Widget untuk menampilkan error dengan tombol retry
  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 60, color: Colors.red),
          const SizedBox(height: 20),
          Text(
            'Error: $error',
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => setState(() {}), // Reload ulang dengan setState
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  // Widget untuk menampilkan saat data user tidak ditemukan
  Widget _buildNoDataState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_off, size: 60, color: Colors.grey),
          SizedBox(height: 20),
          Text(
            'User data not found',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
