// Enum QuestStatus merepresentasikan status dari sebuah quest
enum QuestStatus {
  notStarted,  // Quest belum dimulai/dikerjakan oleh pengguna
  inProgress,  // Quest sedang dalam proses pengerjaan
  completed,   // Quest telah selesai dikerjakan
}

// Model QuestModel merepresentasikan sebuah misi atau tugas (quest) dalam aplikasi
class QuestModel {
  final String id;           // ID unik untuk quest
  final String title;        // Judul quest
  final String description;  // Penjelasan
  final int points;          // Poin yang diberikan jika quest diselesaikan
  QuestStatus status;        // Status quest (belum dimulai, sedang dikerjakan, atau selesai)

  // Konstruktor untuk membuat instance QuestModel
  QuestModel({
    required this.id,
    required this.title,
    required this.description,
    required this.points,
    required this.status,
  });
}
