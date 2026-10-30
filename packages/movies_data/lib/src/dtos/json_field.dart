//
//  json_field.dart
//

/// Reads [key] out of [json], failing when it is absent or of the wrong type.
///
/// TMDB documents these fields as always present, so a miss means the payload
/// is not what we think it is — better to fail the parse than to paper over it
/// with a default.
T requireField<T>(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! T) {
    throw FormatException('Missing or invalid "$key" in movie payload', json);
  }
  return value;
}

/// The `[{...}, {...}]` under [key], or an empty list when the key is absent.
///
/// Appended sub-resources are optional by nature — ask for `videos` in a locale
/// that has none and the list comes back empty — so a missing or malformed
/// collection is a normal outcome rather than a parse failure.
List<Map<String, dynamic>> optionalObjects(
  Map<String, dynamic> json,
  String key,
) {
  final value = json[key];
  if (value is! List) return const [];
  return [
    for (final item in value)
      if (item is Map<String, dynamic>) item,
  ];
}
