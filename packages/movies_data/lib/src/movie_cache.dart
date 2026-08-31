//
//  movie_cache.dart
//

import 'movie_details.dart';

final class MovieCache {
  final _byId = <int, MovieDetails>{};

  MovieDetails? operator [](int id) => _byId[id];

  bool contains(int id) => _byId.containsKey(id);

  void put(MovieDetails movie) => _byId[movie.id] = movie;

  void putAll(Iterable<MovieDetails> movies) {
    for (final movie in movies) {
      _byId[movie.id] = movie;
    }
  }

  void clear() => _byId.clear();
}
