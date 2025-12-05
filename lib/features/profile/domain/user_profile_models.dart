class SavedRecipeSummary {
  final String id;
  final String title;
  final String imageUrl;
  final String time;
  final String difficulty;

  const SavedRecipeSummary({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.time,
    required this.difficulty,
  });
}

class UserActivityItem {
  final DateTime timestamp;
  final String description;

  const UserActivityItem({
    required this.timestamp,
    required this.description,
  });
}
