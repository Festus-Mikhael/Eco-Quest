import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../widgets/custom_white_appbar.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderScreenState();
}

class _LeaderScreenState extends State<LeaderboardScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Ambil tema dari context

    return Scaffold(
      appBar: const WhiteAppBar(title: 'Leaderboard', actions: []),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: StreamBuilder<QuerySnapshot>(
          // Stream realtime top 5 user berdasarkan points descending
          stream: FirebaseFirestore.instance
              .collection('users')
              .orderBy('points', descending: true)
              .limit(10)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // Loading indikator saat menunggu data
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              // Tampilkan pesan error jika ada masalah
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final docs = snapshot.data?.docs ?? [];
            if (docs.isEmpty) {
              // Jika tidak ada user data sama sekali
              return const Center(child: Text('Tidak ada data user'));
            }

            // Buat list user dengan rank (index + 1), nama, dan points
            final users = docs.asMap().entries.map((entry) {
              final index = entry.key;
              final doc = entry.value;
              return {
                'rank': index + 1,
                'name': doc['name'],
                'points': doc['points'],
              };
            }).toList();

            // Susun top 3 user untuk ditampilkan secara khusus
            // Urutan top 3 dibuat: posisi 2 (index 1), posisi 1 (index 0), posisi 3 (index 2)
            final top3 = [
              if (users.length > 1) users[1], // rank 2 di tengah
              if (users.isNotEmpty) users[0], // rank 1 di tengah
              if (users.length > 2) users[2], // rank 3 di kanan
            ];

            // Sisanya (rank 4 dan 5) ditampilkan di list bawah
            final others = users.length > 3 ? users.sublist(3) : [];

            return Column(
              children: [
                // Widget untuk menampilkan top 3 user dengan gaya khusus
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: top3.map((user) {
                      return Column(
                        children: [
                          CircleAvatar(
                            radius: 36,
                            backgroundColor: theme.colorScheme.primary,
                            child: Text(
                              user['rank'].toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            user['name'],
                            style: theme.textTheme.displayLarge?.copyWith(
                              fontSize: 16,
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 4, horizontal: 12),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${user['points']} pts',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 16),

                // Widget untuk menampilkan user selain top 3 (rank 4 dan 5)
                Expanded(
                  child: ListView.separated(
                    itemCount: others.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final user = others[index];
                      return Container(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(32),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 20,
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.white,
                              child: Text(
                                user['rank'].toString(),
                                style: TextStyle(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                user['name'],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Text(
                              '${user['points']} pts',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
