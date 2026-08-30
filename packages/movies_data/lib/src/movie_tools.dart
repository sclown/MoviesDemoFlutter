//
//  movie_tools.dart
//

import 'dtos/movie.dart';

import 'movie_details.dart';

extension MovieTools on Movie {
  Uri? fullPoster() {
    final path = posterPath;
    if (path == null) return null;
    return Uri.tryParse('https://image.tmdb.org/t/p/original$path');
  }

  Uri? smallPoster() {
    final path = posterPath;
    if (path == null) return null;
    return Uri.tryParse('https://image.tmdb.org/t/p/w500$path');
  }

  String ratingText() => voteAverage.toStringAsFixed(1);

  MovieDetails details() => MovieDetails(
    id: id,
    title: title,
    poster: fullPoster(),
    rating: ratingText(),
    releaseDate: releaseDate,
    overview: overview,
  );
}
