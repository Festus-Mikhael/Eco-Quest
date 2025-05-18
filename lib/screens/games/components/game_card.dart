import 'package:flutter/material.dart';
import '../../../models/game_model.dart';

class GameCard extends StatelessWidget {
  final int index;
  final GameModel game;
  final VoidCallback onPlayGame;

  const GameCard({
    super.key,
    required this.index,
    required this.game,
    required this.onPlayGame,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEven = index % 2 == 0;
    final colorScheme = Theme.of(context).colorScheme;
    final backgroundColor = isEven ? colorScheme.primary : colorScheme.secondary;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            game.title,
            style: theme.textTheme.displayLarge!.copyWith(
              fontSize: 20,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            game.description as String,
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            'Poin: ${game.points}',
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 16),
          if (game.status == GameStatus.notStarted)
            ElevatedButton(
              onPressed: onPlayGame,
              child: const Text('Mainkan'),
            )
          else
            ElevatedButton(
              onPressed: null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
              ),
              child: const Text('Sudah Selesai'),
            ),
        ],
      ),
    );
  }
}
