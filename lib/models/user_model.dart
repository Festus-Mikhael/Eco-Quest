import 'package:cloud_firestore/cloud_firestore.dart';

// Model UserModel merepresentasikan data pengguna dalam aplikasi
class UserModel {
  final String id;              // ID pengguna
  final String name;            // Nama lengkap pengguna
  final String email;           // Alamat email pengguna
  final String avatarUrl;       // URL gambar avatar pengguna
  final int points;             // Poin yang dikumpulkan pengguna
  final List<dynamic> badges;   // Daftar badge/medali yang dimiliki pengguna

  // Konstruktor untuk membuat instance UserModel
  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.avatarUrl,
    this.points = 0,            // Default nilai poin adalah 0
    this.badges = const [],     // Default daftar badge adalah kosong
  });

  // Factory method untuk membuat UserModel dari dokumen Firestore
  static UserModel fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!; // Mendapatkan data map dari dokumen

    return UserModel(
      id: doc.id,                                      // Gunakan ID dokumen sebagai ID pengguna
      name: data['name'] ?? '',                        // Nama, default kosong jika null
      email: data['email'] ?? '',                      // Email, default kosong jika null
      avatarUrl: data['avatarUrl'] ?? '',              // URL avatar, default kosong jika null
      points: data['points'] ?? 0,                     // Poin, default 0 jika null
      badges: List<dynamic>.from(data['badges'] ?? []),// Badge, pastikan dikonversi ke List
    );
  }

  // Mengubah UserModel menjadi Map untuk disimpan ke Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'avatarUrl': avatarUrl,
      'points': points,
      'badges': badges,
    };
  }
}
