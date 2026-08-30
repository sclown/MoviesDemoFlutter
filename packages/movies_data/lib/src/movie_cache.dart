//
//  movie_cache.dart
//

import 'movie_details.dart';

/// Holds the movies the list and search screens have already loaded, so the
/// details screen can render one by id without asking the network again.
///
/// It is filled only by those screens: an id that was never listed is a miss,
/// and the details screen shows its unavailable state.
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
