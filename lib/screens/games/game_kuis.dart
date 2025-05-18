import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eco_quest/config/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:eco_quest/models/game_model.dart';
import 'package:eco_quest/models/question_model.dart';
import '../../widgets/custom_white_appbar.dart';

class GameKuisScreen extends StatefulWidget {
  final GameModel game; // Model game yang sedang dimainkan
  final Function(int score) onGameFinished; // Callback untuk mengembalikan skor saat selesai

  const GameKuisScreen({
    super.key,
    required this.game,
    required this.onGameFinished,
  });

  @override
  State<GameKuisScreen> createState() => _GamePlayScreenState();
}

class _GamePlayScreenState extends State<GameKuisScreen> {
  List<QuestionModel> questions = []; // List soal kuis yang dimuat dari Firestore
  int currentIndex = 0; // Index soal saat ini
  int score = 0; // Skor pemain
  int? selectedIndex; // Index jawaban yang dipilih user

  @override
  void initState() {
    super.initState();
    _loadQuestions(); // Memuat soal saat screen diinisialisasi
  }

  Future<void> _loadQuestions() async {
    // Mengambil data pertanyaan dari Firestore berdasarkan game.id
    final snapshot = await FirebaseFirestore.instance
        .collection('games')
        .doc(widget.game.id)
        .collection('questions')
        .get();

    setState(() {
      // Mengubah dokumen Firestore menjadi model QuestionModel
      questions = snapshot.docs.map((doc) => QuestionModel.fromDoc(doc)).toList();
    });
  }

  void _nextQuestion() {
    final currentQuestion = questions[currentIndex];
    // Jika jawaban yang dipilih benar, tambah skor
    if (selectedIndex != null && selectedIndex == currentQuestion.answerIndex) {
      setState(() {
        score += 1;
      });
    }

    if (currentIndex < questions.length - 1) {
      // Jika masih ada soal, pindah ke soal berikutnya dan reset selectedIndex
      setState(() {
        currentIndex++;
        selectedIndex = null;
      });
    } else {
      // Jika soal sudah habis, tampilkan hasil akhir
      _showResult();
    }
  }

  void _showResult() {
    final maxScore = questions.length;
    final percentage = (score / maxScore * 100).round();

    // Dialog hasil akhir menampilkan skor pemain
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text('Selesai!', style: TextStyle(color: Colors.white)),
        content: Text(
          'Skor kamu: $score/$maxScore',
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Tutup dialog
              widget.onGameFinished(score); // Kirim skor kembali ke pemanggil
              Navigator.pop(context); // Tutup screen kuis
            },
            child: const Text('OK', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Jika pertanyaan belum dimuat, tampilkan loading spinner
    if (questions.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final question = questions[currentIndex];

    return Scaffold(
      appBar: const WhiteAppBar(
        title: 'Kuis',
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Menampilkan skor di bagian atas layar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Skor: $score/${questions.length}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Menampilkan nomor soal saat ini
                    Text(
                      'Pertanyaan ${currentIndex + 1} dari ${questions.length}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.lightTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Kotak pertanyaan dengan background warna utama tema
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        question.question,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Menampilkan pilihan jawaban sebagai tombol
                    ...List.generate(question.options.length, (index) {
                      final isSelected = selectedIndex == index;
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isSelected ? colorScheme.secondary : Colors.white,
                            foregroundColor: isSelected ? Colors.white : colorScheme.primary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: colorScheme.primary.withOpacity(0.3)),
                            ),
                          ),
                          onPressed: () {
                            setState(() => selectedIndex = index); // Set jawaban terpilih
                          },
                          child: Text(
                            question.options[index],
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),

            // Tombol Lanjut atau Selesai, hanya aktif jika sudah memilih jawaban
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: ElevatedButton(
                onPressed: selectedIndex != null ? _nextQuestion : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedIndex != null
                      ? colorScheme.primary
                      : colorScheme.primary.withOpacity(0.5),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  currentIndex < questions.length - 1 ? 'Lanjut' : 'Selesai',
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
