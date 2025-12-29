import 'package:foodiy/features/playlist/application/personal_playlist_service.dart';

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
  final String name;
  final String imageUrl;
  final List<PersonalPlaylistEntry> entries;
  final List<String> recipeIds;
  final String ownerId;
  final bool isPublic;
  final bool isChefPlaylist;
  final bool isFavorites;
  final List<String> categories;
  final DateTime? createdAt;

  PersonalPlaylist({
    required this.id,
    required this.name,
    this.imageUrl = '',
    List<PersonalPlaylistEntry>? entries,
    List<String>? recipeIds,
    this.ownerId = '',
    this.isPublic = false,
    this.isChefPlaylist = false,
    this.isFavorites = false,
    List<String>? categories,
    this.createdAt,
  })  : entries = entries ?? <PersonalPlaylistEntry>[],
        recipeIds = recipeIds ?? const <String>[],
        categories = categories ?? const [];

  bool get isFavoritesCookbook =>
      isFavorites || id.startsWith('favorites_');

  factory PersonalPlaylist.favoritesPlaceholder(String ownerId) {
    return PersonalPlaylist(
      id: PersonalPlaylistService.favoritesCookbookId(ownerId),
      name: 'Favorite recipes',
      ownerId: ownerId,
      isPublic: false,
      isFavorites: true,
      entries: const [],
      categories: const [],
    );
  }

  PersonalPlaylist copyWith({
    String? id,
    String? name,
    String? imageUrl,
    List<PersonalPlaylistEntry>? entries,
    List<String>? recipeIds,
    String? ownerId,
    bool? isPublic,
    bool? isChefPlaylist,
    bool? isFavorites,
    List<String>? categories,
    DateTime? createdAt,
  }) {
    return PersonalPlaylist(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      entries: entries ?? List<PersonalPlaylistEntry>.from(this.entries),
      recipeIds: recipeIds ?? List<String>.from(this.recipeIds),
      ownerId: ownerId ?? this.ownerId,
      isPublic: isPublic ?? this.isPublic,
      isChefPlaylist: isChefPlaylist ?? this.isChefPlaylist,
      isFavorites: isFavorites ?? this.isFavorites,
      categories: categories ?? List<String>.from(this.categories),
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'imageUrl': imageUrl,
        'recipeIds': recipeIds,
        'ownerId': ownerId,
        'isPublic': isPublic,
        'isChefPlaylist': isChefPlaylist,
        'isFavorites': isFavorites,
        'categories': categories,
        'entries': entries.map((e) => e.toJson()).toList(),
        if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      };

  factory PersonalPlaylist.fromJson(Map<String, dynamic> json) {
    DateTime? created;
    final createdRaw = json['createdAt'];
    if (createdRaw is String) {
      created = DateTime.tryParse(createdRaw);
    }
    return PersonalPlaylist(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      ownerId: json['ownerId'] as String? ?? '',
      isPublic: json['isPublic'] as bool? ?? false,
      isChefPlaylist: json['isChefPlaylist'] as bool? ?? false,
      isFavorites: json['isFavorites'] as bool? ?? false,
      createdAt: created,
      recipeIds:
          (json['recipeIds'] as List<dynamic>?)?.whereType<String>().toList() ??
              const <String>[],
      categories: (json['categories'] as List<dynamic>?)
              ?.whereType<String>()
              .toList() ??
          const [],
      entries: (json['entries'] as List<dynamic>?)
              ?.map(
                (e) => PersonalPlaylistEntry.fromJson(
                    e as Map<String, dynamic>),
              )
              .toList() ??
          <PersonalPlaylistEntry>[],
    );
  }
}
