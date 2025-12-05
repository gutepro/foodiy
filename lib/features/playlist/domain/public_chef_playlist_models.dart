class PublicChefPlaylistEntry {
  final String recipeId;
  final String title;
  final String imageUrl;
  final String time;
  final String difficulty;

  const PublicChefPlaylistEntry({
    required this.recipeId,
    required this.title,
    required this.imageUrl,
    required this.time,
    required this.difficulty,
  });

  Map<String, dynamic> toJson() => {
    'recipeId': recipeId,
    'title': title,
    'imageUrl': imageUrl,
    'time': time,
    'difficulty': difficulty,
  };

  factory PublicChefPlaylistEntry.fromJson(Map<String, dynamic> json) {
    return PublicChefPlaylistEntry(
      recipeId: json['recipeId'] as String,
      title: json['title'] as String,
      imageUrl: json['imageUrl'] as String,
      time: json['time'] as String,
      difficulty: json['difficulty'] as String,
    );
  }
}

class PublicChefPlaylist {
  final String id;
  final String chefName;
  final String? chefId;
  final String title;
  final String description;
  final List<PublicChefPlaylistEntry> entries;

  const PublicChefPlaylist({
    required this.id,
    required this.chefName,
    this.chefId,
    required this.title,
    required this.description,
    required this.entries,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'chefName': chefName,
    'chefId': chefId,
    'title': title,
    'description': description,
    // entries stored in subcollection
  };

  factory PublicChefPlaylist.fromJson(
    Map<String, dynamic> json,
    List<PublicChefPlaylistEntry> entries,
  ) {
    return PublicChefPlaylist(
      id: json['id'] as String,
      chefName: json['chefName'] as String,
      chefId: json['chefId'] as String?,
      title: json['title'] as String,
      description: json['description'] as String,
      entries: entries,
    );
  }
}
