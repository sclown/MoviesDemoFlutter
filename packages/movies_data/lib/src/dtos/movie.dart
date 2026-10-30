//
//  movie.dart
//

import 'json_field.dart';

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
    id: requireField<int>(json, 'id'),
    title: requireField<String>(json, 'title'),
    overview: requireField<String>(json, 'overview'),
    posterPath: json['poster_path'] as String?,
    releaseDate: json['release_date'] as String?,
    voteAverage: requireField<num>(json, 'vote_average').toDouble(),
  );

  final int id;
  final String title;
  final String overview;
  final String? posterPath;
  final String? releaseDate;
  final double voteAverage;

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
