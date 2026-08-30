//
//  movie_card.dart
//

import 'package:movies_data/movies_data.dart';

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

  final int id;
  final String title;
  final Uri? poster;

  @override
  bool operator ==(Object other) =>
      other is MovieCard &&
      other.id == id &&
      other.title == title &&
      other.poster == poster;

  @override
  int get hashCode => Object.hash(id, title, poster);
}
