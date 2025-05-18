import 'package:flutter/material.dart';
import 'package:eco_quest/models/quest_model.dart';

class QuestCard extends StatelessWidget {
  final int index; // Index quest di list, untuk styling ganjil/genap
  final QuestModel quest; // Data quest (judul, deskripsi, poin, status, dll)
  final String? activeQuestId; // ID quest yang sedang aktif, jika ada
  final VoidCallback onTakeQuest; // Callback saat tombol ambil quest ditekan
  final VoidCallback onCancelQuest; // Callback saat tombol batalkan quest ditekan
  final VoidCallback onCompleteQuest; // Callback saat tombol selesai quest ditekan

  const QuestCard({
    super.key,
    required this.index,
    required this.quest,
    required this.activeQuestId,
    required this.onTakeQuest,
    required this.onCancelQuest,
    required this.onCompleteQuest,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEven = index % 2 == 0;
    final colorScheme = theme.colorScheme;
    final backgroundColor = isEven ? colorScheme.primary : colorScheme.secondary;
    final isActive = quest.id == activeQuestId;

    // Debug print untuk bantu cek status dan id aktif
    debugPrint('QuestCard - Quest ID: ${quest.id}, Status: ${quest.status}, ActiveQuestId: $activeQuestId, isActive: $isActive');

    // Untuk safety, kalau status null atau enum tidak dikenali, fallback ke notStarted
    final status = quest.status ?? QuestStatus.notStarted;

    Widget buildButton() {
      switch (status) {
        case QuestStatus.notStarted:
          if (activeQuestId == null) {
            return ElevatedButton(
              onPressed: onTakeQuest,
              child: const Text('Ambil Quest'),
            );
          } else if (activeQuestId != null && quest.id != activeQuestId) {
            return const ElevatedButton(
              onPressed: null,
              child: Text('Sedang ada quest aktif lainnya'),
            );
          } else {
            return const ElevatedButton(
              onPressed: null,
              child: Text('Tidak tersedia'),
            );
          }
        case QuestStatus.inProgress:
          if (isActive) {
            return Row(
              children: [
                ElevatedButton(
                  onPressed: onCompleteQuest,
                  child: const Text('Selesai'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: onCancelQuest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                  ),
                  child: const Text('Batalkan'),
                ),
              ],
            );
          } else {
            return const ElevatedButton(
              onPressed: null,
              child: Text('Tidak tersedia'),
            );
          }
        case QuestStatus.completed:
          return const ElevatedButton(
            onPressed: null,
            child: Text('Sudah Selesai'),
          );
        default:
          return const ElevatedButton(
            onPressed: null,
            child: Text('Tidak tersedia'),
          );
      }
    }

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
            quest.title,
            style: theme.textTheme.displayLarge?.copyWith(
              fontSize: 20,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            quest.description,
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            'Poin: ${quest.points}',
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 16),
          buildButton(),
        ],
      ),
    );
  }
}
