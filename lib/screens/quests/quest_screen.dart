import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:eco_quest/models/quest_model.dart';
import 'package:eco_quest/screens/quests/components/quest_card.dart';
import '../../widgets/custom_white_appbar.dart';

class QuestScreen extends StatefulWidget {
  const QuestScreen({super.key});

  @override
  State<QuestScreen> createState() => _QuestScreenState();
}

class _QuestScreenState extends State<QuestScreen> {
  late String userId; // Menyimpan userId saat user login
  String? activeQuestId; // Menyimpan ID quest yang sedang aktif diambil user
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    final user = _auth.currentUser;
    if (user != null) {
      userId = user.uid; // Ambil uid user saat initState
      _fetchActiveQuest(); // Fetch quest yang sedang aktif (jika ada)
    }
  }

  // Mengambil quest aktif user dari dokumen user di Firestore
  Future<void> _fetchActiveQuest() async {
    final userDoc = await _firestore.collection('users').doc(userId).get();
    setState(() {
      activeQuestId = userDoc.data()?['activeQuest']; // Set state activeQuestId
    });
  }

  // Fungsi untuk mengambil quest baru
  Future<void> _takeQuest(String questId) async {
    if (activeQuestId != null) {
      // Jika sudah ada quest aktif, tampilkan pesan error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kamu sudah mengambil quest lain.')),
      );
      return;
    }

    try {
      // Ambil data quest dulu (di luar transaksi)
      final questDocSnapshot = await _firestore.collection('quests').doc(questId).get();
      if (!questDocSnapshot.exists) throw Exception('Quest tidak ditemukan');
      final questTitle = questDocSnapshot['title'];

      // Jalankan transaksi untuk update data user dan status quest
      await _firestore.runTransaction((transaction) async {
        final questDoc = await transaction.get(_firestore.collection('quests').doc(questId));
        if (!questDoc.exists) throw Exception('Quest tidak ditemukan');

        // Update field activeQuest user dengan questId baru
        transaction.update(_firestore.collection('users').doc(userId), {
          'activeQuest': questId,
        });

        // Buat dokumen status quest di subcollection questStatus user
        transaction.set(
          _firestore
              .collection('users')
              .doc(userId)
              .collection('questStatus')
              .doc(questId),
          {
            'status': 'inProgress',
            'startedAt': FieldValue.serverTimestamp(),
          },
        );
      });

      await _fetchActiveQuest(); // Refresh data quest aktif di UI
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Quest "$questTitle" berhasil diambil!')),
      );
    } catch (e) {
      // Tampilkan error jika gagal mengambil quest
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    }
  }

  // Fungsi untuk membatalkan quest yang sedang aktif
  Future<void> _cancelQuest(String questId) async {
    try {
      await _firestore.runTransaction((transaction) async {
        // Hapus activeQuest user (set ke null)
        transaction.update(_firestore.collection('users').doc(userId), {
          'activeQuest': null,
        });

        // Update status quest menjadi 'notStarted' dan catat waktu batal
        transaction.update(
          _firestore
              .collection('users')
              .doc(userId)
              .collection('questStatus')
              .doc(questId),
          {
            'status': 'notStarted',
            'canceledAt': FieldValue.serverTimestamp(),
          },
        );
      });

      setState(() => activeQuestId = null); // Reset state quest aktif di UI
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Quest dibatalkan')),
      );
    } catch (e) {
      // Tampilkan error jika gagal batalkan quest
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal membatalkan quest: $e')),
      );
    }
  }

  // Fungsi untuk menyelesaikan quest aktif
  Future<void> _completeQuest(String questId) async {
    try {
      await _firestore.runTransaction((transaction) async {
        // Ambil poin quest dari dokumen quest
        final questDoc = await transaction.get(_firestore.collection('quests').doc(questId));
        final points = questDoc['points'] as int;

        // Ambil data user dan update poin + hapus activeQuest
        final userRef = _firestore.collection('users').doc(userId);
        final userDoc = await transaction.get(userRef);
        final currentPoints = userDoc.data()?['points'] ?? 0;

        transaction.update(userRef, {
          'points': currentPoints + points,
          'activeQuest': null,
        });

        // Update status quest di subcollection menjadi completed dan catat poin yang didapat
        transaction.update(
          _firestore
              .collection('users')
              .doc(userId)
              .collection('questStatus')
              .doc(questId),
          {
            'status': 'completed',
            'completedAt': FieldValue.serverTimestamp(),
            'pointsEarned': points,
          },
        );
      });

      setState(() => activeQuestId = null); // Reset quest aktif di UI
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Quest selesai! Poin bertambah.')),
      );
    } catch (e) {
      // Tampilkan error jika gagal menyelesaikan quest
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyelesaikan quest: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const WhiteAppBar(
        title: 'Quest',
      ),
      // StreamBuilder untuk ambil daftar quests dari Firestore
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('quests').snapshots(),
        builder: (context, questsSnapshot) {
          if (questsSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (questsSnapshot.hasError) {
            return const Center(child: Text('Terjadi kesalahan.'));
          }

          // StreamBuilder untuk ambil status quest user dari subcollection questStatus
          return StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('users')
                .doc(userId)
                .collection('questStatus')
                .snapshots(),
            builder: (context, statusSnapshot) {
              if (statusSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              // Membuat map id quest ke statusnya, misal {'questId1': 'inProgress'}
              final statusMap = {
                for (var doc in statusSnapshot.data?.docs ?? [])
                  doc.id: doc['status']
              };

              // Membuat list widget QuestCard dari data quests dan status
              final quests = questsSnapshot.data!.docs.asMap().entries.map((entry) {
                final doc = entry.value;
                final questId = doc.id;
                final status = statusMap[questId] ?? 'notStarted';

                return QuestCard(
                  index: entry.key,
                  quest: QuestModel(
                    id: questId,
                    title: doc['title'],
                    description: doc['description'],
                    points: doc['points'],
                    status: status == 'notStarted'
                        ? QuestStatus.notStarted
                        : status == 'inProgress'
                        ? QuestStatus.inProgress
                        : QuestStatus.completed,
                  ),
                  activeQuestId: activeQuestId, // Kirim quest aktif agar card bisa sesuaikan UI
                  onTakeQuest: () => _takeQuest(questId), // Callback saat ambil quest
                  onCancelQuest: () => _cancelQuest(questId), // Callback batalkan quest
                  onCompleteQuest: () => _completeQuest(questId), // Callback selesaikan quest
                );
              }).toList();

              return ListView(children: quests);
            },
          );
        },
      ),
    );
  }
}
