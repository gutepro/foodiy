class RecipeStep {
  final String text;
  final int? durationSeconds; // null means no timer

  const RecipeStep({
    required this.text,
    this.durationSeconds,
  });

  RecipeStep copyWith({
    String? text,
    int? durationSeconds,
  }) {
    return RecipeStep(
      text: text ?? this.text,
      durationSeconds: durationSeconds ?? this.durationSeconds,
    );
  }

  Map<String, dynamic> toJson() => {
        'text': text,
        'durationSeconds': durationSeconds,
      };

  factory RecipeStep.fromJson(Map<String, dynamic> json, {int index = 0}) {
    final rawText = json['text'] as String? ?? '';
    final rawDuration = json['durationSeconds'];
    final duration = rawDuration is num && rawDuration > 0
        ? rawDuration.toInt()
        : null;
    final parsedDuration = _extractDurationSeconds(rawText);
    final safeText = rawText.isNotEmpty ? rawText : 'Step ${index + 1}';
    return RecipeStep(
      text: safeText,
      durationSeconds: duration ?? parsedDuration,
    );
  }
}

int? _extractDurationSeconds(String text) {
  final lower = text.toLowerCase();

  // Handle Hebrew "חצי שעה" (half an hour)
  if (lower.contains('חצי שעה')) {
    return 30 * 60;
  }

  // Combined hours and minutes (e.g., "1 hour and 20 minutes" or "שעה ו-20 דקות")
  final combined = RegExp(
    r'(\d+(?:[.,]\d+)?)\s*(hour|hours|hr|hrs|שעה|שעות)\s*(?:and|&|ו|-)?\s*(\d+(?:[.,]\d+)?)\s*(minute|min|minutes|mins|דקה|דקות|דק)?',
    caseSensitive: false,
  ).firstMatch(lower);
  if (combined != null) {
    final hours = double.tryParse(combined.group(1)!.replaceAll(',', '.')) ?? 0;
    final minutes =
        double.tryParse((combined.group(3) ?? '').replaceAll(',', '.')) ?? 0;
    final totalMinutes = (hours * 60) + minutes;
    if (totalMinutes > 0) return (totalMinutes * 60).round();
  }

  // Ranges with minutes (take the first value) e.g. "15-20 minutes"
  final rangeMinutes = RegExp(
    r'(\d+)\s*-\s*(\d+)\s*(minute|min|minutes|mins|דקה|דקות|דק)',
    caseSensitive: false,
  ).firstMatch(lower);
  if (rangeMinutes != null) {
    final first = int.tryParse(rangeMinutes.group(1) ?? '');
    if (first != null) return first * 60;
  }

  // Hours only (e.g., "1 hour", "1.5 hours", "שעה")
  final hoursOnly = RegExp(
    r'(\d+(?:[.,]\d+)?)\s*(hour|hours|hr|hrs|שעה|שעות)',
    caseSensitive: false,
  ).firstMatch(lower);
  if (hoursOnly != null) {
    final hours = double.tryParse(hoursOnly.group(1)!.replaceAll(',', '.'));
    if (hours != null) return (hours * 60 * 60).round();
  }

  // Minutes only (e.g., "10 minutes", "כ-30 דק", "about 30 min")
  final minutesOnly = RegExp(
    r'(\d+(?:[.,]\d+)?)\s*(minute|min|minutes|mins|דקה|דקות|דק)',
    caseSensitive: false,
  ).firstMatch(lower);
  if (minutesOnly != null) {
    final minutes =
        double.tryParse(minutesOnly.group(1)!.replaceAll(',', '.')) ?? 0;
    if (minutes > 0) return (minutes * 60).round();
  }

  return null;
}
