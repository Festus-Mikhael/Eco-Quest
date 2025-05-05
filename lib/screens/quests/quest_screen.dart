import 'package:flutter/material.dart';
import '../../models/quest_model.dart';
import 'components/quest_card.dart';
import '../../widgets/custom_appbar.dart';

class QuestScreen extends StatefulWidget {
  const QuestScreen({super.key});

  @override
  State createState() => _QuestScreenState();
}

class _QuestScreenState extends State {
  // Mock list of quests
  List quests = [
    QuestModel(
      id: 'q1',
      title: 'Kurangi Sampah Plastik',
      description: 'Kurangi penggunaan plastik sekali pakai selama 7 hari.',
      points: 50,
    ),
    QuestModel(
      id: 'q2',
      title: 'Tanam Pohon',
      description: 'Tanam minimal 1 pohon di lingkungan sekitar.',
      points: 70,
    ),
    QuestModel(
      id: 'q3',
      title: 'Kenali Keanekaragaman Hayati',
      description: 'Pelajari dan kenali 5 jenis tumbuhan lokal.',
      points: 40,
    ),
  ];

  // Handle quest take action
  void _takeQuest(int index) {
    setState(() {
      quests[index].status = QuestStatus.inProgress;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Quest "${quests[index].title}" berhasil diambil!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Quest'),
      body: ListView.builder(
        itemCount: quests.length,
        itemBuilder: (context, index) {
          return QuestCard(
            quest: quests[index],
            onTakeQuest: () => _takeQuest(index),
          );
        },
      ),
    );
  }
}