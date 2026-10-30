//
//  movie_details.dart
//

import 'movie_extras.dart';

/// One movie as the details screen needs it.
///
/// Assembled in two passes. The list and search screens build the cheap half
/// out of the page they already fetched, so the screen can paint at once; the
/// details screen then fetches the rest and puts the filled-in copy back into
/// the cache. [extras] tells the two apart: null means "not fetched yet".
final class MovieDetails {
  const MovieDetails({
    required this.id,
    required this.title,
    required this.poster,
    required this.rating,
    required this.releaseDate,
    required this.overview,
    this.extras,
  });

  final int id;
  final String title;
  final Uri? poster;
  final String rating;
  final String? releaseDate;
  final String overview;

  /// Genres, trailers and credits — null until the per-movie request lands.
  final MovieExtras? extras;

  /// True once the per-movie request has landed, so it need not run again.
  bool get isComplete => extras != null;

  MovieDetails withExtras(MovieExtras extras) => MovieDetails(
    id: id,
    title: title,
    poster: poster,
    rating: rating,
    releaseDate: releaseDate,
    overview: overview,
    extras: extras,
  );

  @override
  bool operator ==(Object other) =>
      other is MovieDetails &&
      other.id == id &&
      other.title == title &&
      other.poster == poster &&
      other.rating == rating &&
      other.releaseDate == releaseDate &&
      other.overview == overview &&
      other.extras == extras;

  @override
  int get hashCode =>
      Object.hash(id, title, poster, rating, releaseDate, overview, extras);
}
