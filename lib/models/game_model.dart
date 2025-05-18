// Model GameModel merepresentasikan data dari sebuah game mini
class GameModel {
  final String id;           // ID unik game
  final String title;        // Judul game
  final String description;  // Deskripsi singkat tentang game
  final int points;          // Jumlah poin yang didapatkan dari game ini jika berhasil diselesaikan
  final int maxScore;        // Skor maksimum yang dapat dicapai dalam game
  GameStatus status;         // Status game: belum dimulai atau sudah selesai

  // Konstruktor untuk membuat instance GameModel
  GameModel({
    required this.id,
    required this.title,
    required this.description,
    required this.points,
    required this.maxScore,
    required this.status,
  });
}

// Enum GameStatus digunakan untuk merepresentasikan status dari game
enum GameStatus {
  notStarted,  // Game belum dimainkan atau dimulai
  completed,   // Game telah selesai dimainkan
}
