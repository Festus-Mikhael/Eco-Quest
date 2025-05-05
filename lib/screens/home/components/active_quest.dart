import 'package:flutter/material.dart';
import '../../../models/quest_model.dart';

class ActiveQuest extends StatelessWidget {
  final QuestModel quest;

  const ActiveQuest({super.key, required this.quest});

  @override
  Widget build(BuildContext context) {
    // Display active quest with progress bar and details
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quest Aktif',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade800,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              quest.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              quest.description,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 12),
            // Progress bar based on quest status
            LinearProgressIndicator(
              value: quest.status == QuestStatus.inProgress
                  ? 0.5
                  : (quest.status == QuestStatus.completed ? 1.0 : 0.0),
              color: Colors.green,
              backgroundColor: Colors.green.shade100,
            ),
            const SizedBox(height: 8),
            Text(
              'Poin: ${quest.points}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}