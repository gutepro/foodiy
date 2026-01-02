class Recipe {
  const Recipe({
    required this.id,
    required this.title,
    required this.chefName,
    required this.description,
    this.imageUrl,
    required this.tags,
  });

  final String id;
  final String title;
  final String chefName;
  final String description;
  final String? imageUrl;
  final List<String> tags;

  factory Recipe.fromMap(Map<String, dynamic> map, {String? id}) {
    return Recipe(
      id: id ?? (map['id'] as String? ?? ''),
      title: map['title'] as String? ?? '',
      chefName: map['chefName'] as String? ?? '',
      description: map['description'] as String? ?? '',
      imageUrl: map['imageUrl'] as String?,
      tags: List<String>.from(map['tags'] as List? ?? const []),
    );
  }

  Map<String, dynamic> toMap() {
    final data = <String, dynamic>{
      'id': id,
      'title': title,
      'chefName': chefName,
      'description': description,
      'tags': tags,
    };
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      data['imageUrl'] = imageUrl;
    }
    return data;
  }
}
