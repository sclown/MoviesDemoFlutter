//
//  movie.dart
//

final class MovieResponse {
  const MovieResponse({required this.results, required this.totalPages});

  factory MovieResponse.fromJson(Map<String, dynamic> json) => MovieResponse(
    results: (json['results'] as List<dynamic>)
        .map((item) => Movie.fromJson(item as Map<String, dynamic>))
        .toList(growable: false),
    totalPages: json['total_pages'] as int,
  );

  final List<Movie> results;
  final int totalPages;
}

final class Movie {
  const Movie({
    required this.id,
    required this.title,
    required this.overview,
    required this.posterPath,
    required this.releaseDate,
    required this.voteAverage,
  });

  factory Movie.fromJson(Map<String, dynamic> json) => Movie(
    id: _require<int>(json, 'id'),
    title: _require<String>(json, 'title'),
    overview: _require<String>(json, 'overview'),
    posterPath: json['poster_path'] as String?,
    releaseDate: json['release_date'] as String?,
    voteAverage: _require<num>(json, 'vote_average').toDouble(),
  );

  final int id;
  final String title;
  final String overview;
  final String? posterPath;
  final String? releaseDate;
  final double voteAverage;

  static T _require<T>(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is! T) {
      throw FormatException('Missing or invalid "$key" in movie payload', json);
    }
    return value;
  }

  @override
  bool operator ==(Object other) =>
      other is Movie &&
      other.id == id &&
      other.title == title &&
      other.overview == overview &&
      other.posterPath == posterPath &&
      other.releaseDate == releaseDate &&
      other.voteAverage == voteAverage;

  @override
  int get hashCode =>
      Object.hash(id, title, overview, posterPath, releaseDate, voteAverage);
}
