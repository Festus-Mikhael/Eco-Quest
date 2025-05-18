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
    final theme = Theme.of(context); // Ambil tema dari context
    final isEven = index % 2 == 0; // Cek apakah index genap
    final colorScheme = Theme.of(context).colorScheme; // Ambil skema warna tema
    // Warna background beda untuk genap (primary) dan ganjil (secondary)
    final backgroundColor = isEven ? colorScheme.primary : colorScheme.secondary;
    // Cek apakah quest ini adalah quest yang aktif sekarang
    final isActive = quest.id == activeQuestId;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16), // Margin luar
      padding: const EdgeInsets.all(16), // Padding dalam container
      decoration: BoxDecoration(
        color: backgroundColor, // Warna background berdasarkan index genap/ganjil
        borderRadius: BorderRadius.circular(20), // Sudut container melengkung
        boxShadow: const [
          BoxShadow(
            color: Colors.black12, // Bayangan halus
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Rata kiri isi kolom
        children: [
          Text(
            quest.title, // Judul quest
            style: theme.textTheme.displayLarge!.copyWith(
              fontSize: 20,
              color: Colors.white, // Teks putih supaya kontras dengan background
            ),
          ),
          const SizedBox(height: 8),
          Text(
            quest.description, // Deskripsi quest
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            'Poin: ${quest.points}', // Tampilkan poin quest
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 16),
          Builder(
            builder: (context) {
              // Tombol berdasarkan status quest dan apakah ada quest aktif lain
              if (quest.status == QuestStatus.notStarted && activeQuestId == null) {
                // Jika quest belum mulai dan tidak ada quest aktif, tampilkan tombol ambil quest
                return ElevatedButton(
                  onPressed: onTakeQuest,
                  child: const Text('Ambil Quest'),
                );
              } else if (quest.status == QuestStatus.inProgress && isActive) {
                // Jika quest sedang berlangsung dan ini quest aktif, tampilkan tombol selesai dan batalkan
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
                        backgroundColor: Colors.white, // Tombol batalkan dengan background putih
                      ),
                      child: const Text('Batalkan'),
                    ),
                  ],
                );
              } else if (quest.status == QuestStatus.completed) {
                // Jika quest sudah selesai, tombol disabled dengan label sudah selesai
                return const ElevatedButton(
                  onPressed: null,
                  child: Text('Sudah Selesai'),
                );
              } else if (activeQuestId != null && quest.id != activeQuestId && quest.status == QuestStatus.notStarted) {
                // Jika ada quest aktif lain, dan quest ini belum diambil, tombol disabled dengan pesan
                return const ElevatedButton(
                  onPressed: null,
                  child: Text('Sedang ada quest aktif lainnya'),
                );
              } else {
                // Kondisi lain, tombol disabled dengan teks tidak tersedia
                return const ElevatedButton(
                  onPressed: null,
                  child: Text('Tidak tersedia'),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
