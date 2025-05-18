import 'package:cloud_firestore/cloud_firestore.dart';

// Model QuestionModel merepresentasikan satu pertanyaan dalam kuis
class QuestionModel {
  final String question;        // Teks pertanyaan
  final List<String> options;   // Daftar pilihan jawaban (opsi)
  final int answerIndex;        // Index dari jawaban yang benar dalam daftar options

  // Konstruktor untuk membuat instance QuestionModel
  QuestionModel({
    required this.question,
    required this.options,
    required this.answerIndex,
  });

  // Factory constructor untuk membuat instance QuestionModel dari dokumen Firestore
  factory QuestionModel.fromDoc(DocumentSnapshot doc) {
    // Mengambil data dari dokumen Firestore dan meng-cast-nya ke Map
    final data = doc.data() as Map<String, dynamic>;

    // Mengembalikan instance QuestionModel berdasarkan data Firestore
    return QuestionModel(
      question: data['question'],                      // Pertanyaan kuis
      options: List<String>.from(data['options']),     // List opsi jawaban
      answerIndex: data['answerIndex'],                // Indeks jawaban yang benar
    );
  }
}
