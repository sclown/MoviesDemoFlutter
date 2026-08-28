//
//  movie_card.dart
//

import 'package:movies_api/movies_api.dart';
import 'package:movies_core/movies_core.dart';

/// What a grid cell needs, and nothing more.
final class MovieCard {
  const MovieCard({
    required this.id,
    required this.title,
    required this.poster,
  });

  MovieCard.from(Movie movie)
    : id = movie.id,
      title = movie.title,
      poster = movie.smallPoster();

  factory MovieCard.mock() => MovieCard.mockWith(id: 1);

  factory MovieCard.mockWith({required int id}) =>
      MovieCard(id: id, title: 'Movie title $id', poster: null);

  final int id;
  final String title;
  final Uri? poster;
}
