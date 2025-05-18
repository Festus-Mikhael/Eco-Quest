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
  late String userId;
  String? activeQuestId;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    final user = _auth.currentUser;
    if (user != null) {
      userId = user.uid;
      _fetchActiveQuest();
    }
  }

  Future<void> _fetchActiveQuest() async {
    final userDoc = await _firestore.collection('users').doc(userId).get();
    setState(() {
      activeQuestId = userDoc.data()?['activeQuest'];
    });
  }

  Future<void> _takeQuest(String questId) async {
    if (activeQuestId != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kamu sudah mengambil quest lain.')),
      );
      return;
    }

    try {
      final questDocSnapshot =
      await _firestore.collection('quests').doc(questId).get();
      if (!questDocSnapshot.exists) throw Exception('Quest tidak ditemukan');
      final questTitle = questDocSnapshot['title'];

      await _firestore.runTransaction((transaction) async {
        final questDoc =
        await transaction.get(_firestore.collection('quests').doc(questId));
        if (!questDoc.exists) throw Exception('Quest tidak ditemukan');

        transaction.update(_firestore.collection('users').doc(userId), {
          'activeQuest': questId,
        });

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

      // ⬇ Langsung setState agar UI langsung berubah
      setState(() {
        activeQuestId = questId;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Quest "$questTitle" berhasil diambil!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    }
  }

  Future<void> _cancelQuest(String questId) async {
    try {
      await _firestore.runTransaction((transaction) async {
        transaction.update(_firestore.collection('users').doc(userId), {
          'activeQuest': null,
        });

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

      setState(() => activeQuestId = null);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Quest dibatalkan')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal membatalkan quest: $e')),
      );
    }
  }

  Future<void> _completeQuest(String questId) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final questDoc =
        await transaction.get(_firestore.collection('quests').doc(questId));
        final points = questDoc['points'] as int;

        final userRef = _firestore.collection('users').doc(userId);
        final userDoc = await transaction.get(userRef);
        final currentPoints = userDoc.data()?['points'] ?? 0;

        transaction.update(userRef, {
          'points': currentPoints + points,
          'activeQuest': null,
        });

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

      setState(() => activeQuestId = null);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Quest selesai! Poin bertambah.')),
      );
    } catch (e) {
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
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('quests').snapshots(),
        builder: (context, questsSnapshot) {
          if (questsSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (questsSnapshot.hasError) {
            return const Center(child: Text('Terjadi kesalahan.'));
          }

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

              final statusMap = {
                for (var doc in statusSnapshot.data?.docs ?? [])
                  doc.id: doc['status']
              };

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
                  activeQuestId: activeQuestId,
                  onTakeQuest: () => _takeQuest(questId),
                  onCancelQuest: () => _cancelQuest(questId),
                  onCompleteQuest: () => _completeQuest(questId),
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
