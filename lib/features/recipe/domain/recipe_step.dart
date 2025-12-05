class RecipeStep {
  final String text;
  final int? durationSeconds; // null means no timer

  const RecipeStep({
    required this.text,
    this.durationSeconds,
  });

  Map<String, dynamic> toJson() => {
        'text': text,
        'durationSeconds': durationSeconds,
      };

  factory RecipeStep.fromJson(Map<String, dynamic> json, {int index = 0}) {
    final rawText = json['text'] as String? ?? '';
    final duration = json['durationSeconds'] as int?;
    final safeText = rawText.isNotEmpty ? rawText : 'Step ${index + 1}';
    return RecipeStep(
      text: safeText,
      durationSeconds: duration ?? 0,
    );
  }
}
