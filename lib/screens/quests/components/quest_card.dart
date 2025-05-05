import 'package:flutter/material.dart';
import '../../../models/quest_model.dart';

class QuestCard extends StatelessWidget {
  final QuestModel quest;
  final VoidCallback onTakeQuest;

  const QuestCard({super.key, required this.quest, required this.onTakeQuest});

  @override
  Widget build(BuildContext context) {
    // Card to display quest info and take quest button
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(quest.title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade800,
                )),
            const SizedBox(height: 8),
            Text(quest.description,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade700)),
            const SizedBox(height: 8),
            Text('Poin: ${quest.points}',
                style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: quest.status == QuestStatus.notStarted ? onTakeQuest : null,
              child: Text(quest.status == QuestStatus.notStarted
                  ? 'Ambil Quest'
                  : 'Quest Diambil'),
            ),
          ],
        ),
      ),
    );
  }
}