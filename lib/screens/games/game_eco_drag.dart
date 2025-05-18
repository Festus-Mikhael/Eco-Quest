import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../config/app_theme.dart';
import '../../models/game_model.dart';
import '../../widgets/custom_white_appbar.dart';

class EcoDragGameScreen extends StatefulWidget {
  // Properti game dan callback saat game selesai dengan skor
  final GameModel game;
  final Function(int score) onGameFinished;

  const EcoDragGameScreen({
    super.key,
    required this.game,
    required this.onGameFinished,
  });

  @override
  State<EcoDragGameScreen> createState() => _EcoDragGameScreenState();
}

class _EcoDragGameScreenState extends State<EcoDragGameScreen> {
  // List item yang akan di-drag, tiap item adalah Map data dari Firestore
  List<Map<String, dynamic>> items = [];
  // Status loading data
  bool isLoading = true;
  // Skor game
  int score = 0;

  @override
  void initState() {
    super.initState();
    _loadItems(); // Load data item dari Firestore saat inisialisasi
  }

  // Fungsi untuk mengambil data item dari Firestore
  Future<void> _loadItems() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('games')
          .doc('dragGame')
          .collection('dragItems')
          .get();

      setState(() {
        // Simpan data ke dalam list items
        items = snapshot.docs.map((doc) => doc.data()).toList();
        isLoading = false; // Nonaktifkan loading
      });
    } catch (e) {
      print('Error loading items: $e');
    }
  }

  // Fungsi yang dipanggil saat item diterima oleh target kategori tong sampah
  void _onAccept(String category, Map<String, dynamic> item) {
    final itemCategory = (item['category'] ?? '').toString().toLowerCase();
    final targetCategory = category.toLowerCase();

    debugPrint('Item category: $itemCategory, Target: $targetCategory');

    // Cek apakah kategori item sesuai dengan kategori target
    if (itemCategory == targetCategory) {
      setState(() {
        items.remove(item); // Hapus item yang sudah benar dikategorikan
        score += 1;         // Tambah skor
      });
    } else {
      // Jika salah, tampilkan snackbar peringatan
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ups! Salah tempat 😅')),
      );
    }

    // Jika semua item sudah di-sort, tampilkan hasil
    if (items.isEmpty) {
      _showResult();
    }
  }

  // Tampilkan dialog hasil skor setelah selesai
  void _showResult() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text('Selesai!', style: TextStyle(color: Colors.white)),
        content: Text('Skor kamu: $score/${widget.game.maxScore}',
            style: const TextStyle(color: Colors.white, fontSize: 18)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Tutup dialog
              widget.onGameFinished(score); // Callback ke parent dengan skor
              Navigator.pop(context); // Kembali ke layar sebelumnya
            },
            child: const Text('OK', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Tampilkan loading indicator jika data belum siap
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Membagi items menjadi dua kolom kiri dan kanan
    final int half = (items.length / 2).ceil();
    final leftItems = items.take(half).toList();
    final rightItems = items.skip(half).toList();

    return Scaffold(
      appBar: const WhiteAppBar(
          title: 'Eco Drag Game'
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),

          // Baris skor di kanan atas
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Spacer(),
                Text(
                  'Skor: $score',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.lightTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Kolom kiri berisi item draggable
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: leftItems.map((item) {
                      final label = item['label'] ?? '[no label]';
                      return _draggableText(item, label);
                    }).toList(),
                  ),
                  // Kolom kanan berisi item draggable
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: rightItems.map((item) {
                      final label = item['label'] ?? '[no label]';
                      return _draggableText(item, label);
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),

          const Divider(),

          // Baris target drag berupa tong sampah organik dan anorganik
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _trashBinTarget('organik', 'Organik'),
                _trashBinTarget('anorganik', 'Anorganik'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget untuk item draggable dengan teks label
  Widget _draggableText(Map<String, dynamic> item, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Draggable<Map<String, dynamic>>(
        data: item, // Data yang dibawa saat drag
        feedback: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.primaryColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        // Tampilan saat sedang di-drag (transparan)
        childWhenDragging: Opacity(
          opacity: 0.4,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.primaryColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        // Tampilan normal item
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.primaryColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  // Widget target drag berupa tong sampah kategori tertentu
  Widget _trashBinTarget(String category, String label) {
    return DragTarget<Map<String, dynamic>>(
      onAccept: (item) => _onAccept(category, item), // Terima item drop dan cek kategori
      builder: (context, candidateData, rejectedData) {
        return Column(
          children: [
            Container(
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: AssetImage('assets/images/$category.png'), // Gambar tong sampah
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.primaryColor,
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        );
      },
    );
  }
}
