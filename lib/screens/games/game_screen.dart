import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/game_model.dart';
import '../../widgets/custom_white_appbar.dart';
import 'components/game_card.dart';
import 'game_eco_drag.dart';
import 'game_kuis.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late String userId; // Menyimpan userId dari FirebaseAuth saat user login
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    // Mendapatkan user yang sedang login, dan simpan userId-nya
    final user = _auth.currentUser;
    if (user != null) {
      userId = user.uid;
    }
  }

  // Fungsi untuk memperbarui status game user dan menambah poin jika skor mencapai maksimal
  Future<void> _updateGameStatus(String gameId, int score) async {
    try {
      // Ambil dokumen game untuk mendapatkan maxScore dan poin yang akan diberikan
      final gameDoc = await _firestore.collection('games').doc(gameId).get();
      if (!gameDoc.exists) {
        throw Exception('Game document not found');
      }

      final maxScore = gameDoc['maxScore'] as int;
      final gamePoints = gameDoc['points'] as int;

      if (score >= maxScore) {
        // Update poin user dengan menambahkan poin game
        await _firestore.collection('users').doc(userId).update({
          'points': FieldValue.increment(gamePoints),
        });

        // Update status game user menjadi 'completed' dan simpan skor
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('gameStatus')
            .doc(gameId)
            .set({
          'status': 'completed',
          'completedAt': FieldValue.serverTimestamp(),
          'score': score,
        });

        // Tampilkan notifikasi bahwa game selesai dan poin bertambah
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Game selesai! Poin bertambah.')),
        );
      }
    } catch (e) {
      // Jika error, tampilkan snackbar dan debug print
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
      debugPrint('Error updating game status: $e');
    }
  }

  // Navigasi ke layar game sesuai dengan id game
  void _navigateToGame(GameModel game) {
    switch (game.id) {
      case 'dragGame':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EcoDragGameScreen(
              game: game,
              onGameFinished: (score) => _updateGameStatus(game.id, score),
            ),
          ),
        );
        break;
      case 'kuis':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GameKuisScreen(
              game: game,
              onGameFinished: (score) => _updateGameStatus(game.id, score),
            ),
          ),
        );
        break;
      default:
      // Jika game id tidak dikenali, tampilkan pesan error
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Game tidak dikenali')),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const WhiteAppBar(
        title: 'Mini Games',
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Mendengarkan realtime data games dari Firestore
        stream: _firestore.collection('games').snapshots(),
        builder: (context, gamesSnapshot) {
          if (gamesSnapshot.connectionState == ConnectionState.waiting) {
            // Tampilkan loading spinner jika data masih dimuat
            return const Center(child: CircularProgressIndicator());
          }

          if (gamesSnapshot.hasError) {
            // Tampilkan pesan error jika ada kesalahan saat mengambil data
            return const Center(child: Text('Terjadi kesalahan.'));
          }

          return StreamBuilder<QuerySnapshot>(
            // Mendengarkan realtime status game user
            stream: _firestore
                .collection('users')
                .doc(userId)
                .collection('gameStatus')
                .snapshots(),
            builder: (context, statusSnapshot) {
              if (statusSnapshot.connectionState == ConnectionState.waiting) {
                // Loading spinner saat status game user masih dimuat
                return const Center(child: CircularProgressIndicator());
              }

              // Membuat map status game user untuk akses cepat berdasarkan gameId
              final statusDocs = statusSnapshot.data?.docs ?? [];
              final statusMap = {
                for (var doc in statusDocs) doc.id: doc['status']
              };

              // Membuat list widget GameCard berdasarkan data games dan status user
              final games = gamesSnapshot.data!.docs.asMap().entries.map((entry) {
                final doc = entry.value;
                final gameId = doc.id;
                final status = statusMap[gameId] ?? 'notStarted'; // Status default 'notStarted' jika belum ada
                final maxScore = doc['maxScore'] as int;

                return GameCard(
                  key: ValueKey(gameId),
                  index: entry.key,
                  game: GameModel(
                    id: gameId,
                    title: doc['title'],
                    points: doc['points'],
                    description: doc['description'],
                    maxScore: maxScore,
                    // Status game sesuai data user, diset sebagai enum GameStatus
                    status: status == 'notStarted'
                        ? GameStatus.notStarted
                        : GameStatus.completed,
                  ),
                  // Fungsi saat tombol play ditekan, navigasi ke game terkait
                  onPlayGame: () => _navigateToGame(
                    GameModel(
                      id: gameId,
                      title: doc['title'],
                      points: doc['points'],
                      description: doc['description'],
                      maxScore: maxScore,
                      status: status == 'notStarted'
                          ? GameStatus.notStarted
                          : GameStatus.completed,
                    ),
                  ),
                );
              }).toList();

              return ListView(children: games); // Tampilkan daftar game
            },
          );
        },
      ),
    );
  }
}
