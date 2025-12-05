class PersonalPlaylistEntry {
  final String recipeId;
  final String title;
  final String imageUrl;
  final String time;
  final String difficulty;

  const PersonalPlaylistEntry({
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

  factory PersonalPlaylistEntry.fromJson(Map<String, dynamic> json) {
    return PersonalPlaylistEntry(
      recipeId: json['recipeId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      time: json['time'] as String? ?? '',
      difficulty: json['difficulty'] as String? ?? '',
    );
  }
}

class PersonalPlaylist {
  final String id;
  String name;
  final String imageUrl;
  final List<PersonalPlaylistEntry> entries;
  final String ownerId;
  final bool isPublic;
  final bool isChefPlaylist;

  PersonalPlaylist({
    required this.id,
    required this.name,
    this.imageUrl = '',
    List<PersonalPlaylistEntry>? entries,
    this.ownerId = '',
    this.isPublic = false,
    this.isChefPlaylist = false,
  }) : entries = entries ?? <PersonalPlaylistEntry>[];

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'imageUrl': imageUrl,
    'ownerId': ownerId,
    'isPublic': isPublic,
    'isChefPlaylist': isChefPlaylist,
    'entries': entries.map((e) => e.toJson()).toList(),
  };

  factory PersonalPlaylist.fromJson(Map<String, dynamic> json) {
    return PersonalPlaylist(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      ownerId: json['ownerId'] as String? ?? '',
      isPublic: json['isPublic'] as bool? ?? false,
      isChefPlaylist: json['isChefPlaylist'] as bool? ?? false,
      entries:
          (json['entries'] as List<dynamic>?)
              ?.map(
                (e) =>
                    PersonalPlaylistEntry.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          <PersonalPlaylistEntry>[],
    );
  }
}
