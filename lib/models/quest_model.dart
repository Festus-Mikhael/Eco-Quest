enum QuestStatus { notStarted, inProgress, completed }

class QuestModel {
  final String id;
  final String title;
  final String description;
  final int points;
  QuestStatus status;

  QuestModel({
    required this.id,
    required this.title,
    required this.description,
    required this.points,
    this.status = QuestStatus.notStarted,
  });
}