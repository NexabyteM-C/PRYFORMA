/// Bilingual movement label: English / Spanish.
///
/// The spec requires movements shown in both English and Spanish, English
/// first. Exercises store `name` (English) and `name_es` (Spanish). This
/// renders "Back Squat / Sentadilla Trasera", collapsing to a single name
/// when one is missing or both are equal.
String exerciseBilingual(String? nameEs, String? name) {
  final es = nameEs?.trim() ?? '';
  final en = name?.trim() ?? '';
  if (en.isEmpty) return es;
  if (es.isEmpty || en.toLowerCase() == es.toLowerCase()) return en;
  return '$en / $es';
}

/// Reads the bilingual label from a raw exercise map (`name_es`, `name`).
String exerciseBilingualFromMap(Map<String, dynamic>? exercise) {
  if (exercise == null) return '';
  return exerciseBilingual(
    exercise['name_es'] as String?,
    exercise['name'] as String?,
  );
}
