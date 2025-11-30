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

  factory RecipeStep.fromJson(Map<String, dynamic> json) {
    return RecipeStep(
      text: json['text'] as String,
      durationSeconds: json['durationSeconds'] as int?,
    );
  }
}
