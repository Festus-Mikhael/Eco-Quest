import 'package:flutter/material.dart';
import '../../models/game_model.dart';
import 'components/game_card.dart';
import '../../widgets/custom_appbar.dart';

class GameScreen extends StatelessWidget {
  GameScreen({super.key});

  // Mock list of games
  final List games = [
    GameModel(
      id: 'g1',
      title: 'Kuis Lingkungan',
      description: 'Tes pengetahuanmu tentang lingkungan hidup.',
      points: 30,
    ),
    GameModel(
      id: 'g2',
      title: 'Teka-Teki Sampah',
      description: 'Susun sampah sesuai jenisnya dengan benar.',
      points: 40,
    ),
    GameModel(
      id: 'g3',
      title: 'Game Edukasi Tanam Pohon',
      description: 'Pelajari cara menanam pohon secara interaktif.',
      points: 50,
    ),
  ];

  // Handle play game action
  void _playGame(BuildContext context, String gameTitle) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Memulai game "$gameTitle"...')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Game Edukasi'),
      body: ListView.builder(
        itemCount: games.length,
        itemBuilder: (context, index) {
          return GameCard(
            game: games[index],
            onPlay: () => _playGame(context, games[index].title),
          );
        },
      ),
    );
  }
}