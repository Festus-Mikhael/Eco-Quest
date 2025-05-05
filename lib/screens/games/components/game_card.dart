import 'package:flutter/material.dart';
import '../../../models/game_model.dart';

class GameCard extends StatelessWidget {
  final GameModel game;
  final VoidCallback onPlay;

  const GameCard({super.key, required this.game, required this.onPlay});

  @override
  Widget build(BuildContext context) {
    // Card to display game info and play button
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(game.title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade800,
                )),
            const SizedBox(height: 8),
            Text(game.description,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade700)),
            const SizedBox(height: 8),
            Text('Poin: ${game.points}',
                style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: onPlay,
              child: const Text('Mainkan'),
            ),
          ],
        ),
      ),
    );
  }
}