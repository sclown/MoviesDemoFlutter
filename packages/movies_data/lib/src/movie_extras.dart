//
//  movie_extras.dart
//
//  What the second, per-movie request adds on top of the fields the list
//  endpoint already gave us. Wire types stay in `dtos/`; these are what the
//  details screen renders.
//

/// The enrichment for one movie. A [MovieDetails] whose `extras` is null has
/// not been fetched yet — distinct from one fetched and found to have nothing,
/// where these lists are simply empty.
final class MovieExtras {
  const MovieExtras({
    required this.genres,
    required this.trailers,
    required this.cast,
    required this.crew,
  });

  const MovieExtras.empty()
    : genres = const [],
      trailers = const [],
      cast = const [],
      crew = const [];

  final List<String> genres;
  final List<MovieTrailer> trailers;
  final List<MoviePerson> cast;
  final List<MoviePerson> crew;

  @override
  bool operator ==(Object other) =>
      other is MovieExtras &&
      sameList(other.genres, genres) &&
      sameList(other.trailers, trailers) &&
      sameList(other.cast, cast) &&
      sameList(other.crew, crew);

  @override
  int get hashCode => Object.hash(
    Object.hashAll(genres),
    Object.hashAll(trailers),
    Object.hashAll(cast),
    Object.hashAll(crew),
  );
}

final class MovieTrailer {
  const MovieTrailer({
    required this.name,
    required this.url,
    required this.thumbnail,
  });

  final String name;

  /// Where tapping the thumbnail sends the viewer.
  final Uri url;

  /// A still for the video, served by the video host rather than TMDB.
  final Uri thumbnail;

  @override
  bool operator ==(Object other) =>
      other is MovieTrailer &&
      other.name == name &&
      other.url == url &&
      other.thumbnail == thumbnail;

  @override
  int get hashCode => Object.hash(name, url, thumbnail);
}

/// One person on the movie — a cast member with the character they play, or a
/// crew member with the job they did. [role] holds whichever applies.
final class MoviePerson {
  const MoviePerson({
    required this.id,
    required this.name,
    required this.role,
    required this.photo,
  });

  final int id;
  final String name;
  final String role;
  final Uri? photo;

  @override
  bool operator ==(Object other) =>
      other is MoviePerson &&
      other.id == id &&
      other.name == name &&
      other.role == role &&
      other.photo == photo;

  @override
  int get hashCode => Object.hash(id, name, role, photo);
}

/// Element-wise list equality. Hand-rolled to keep this package on the SDK
/// alone — `package:collection` would be the only reason to add a dependency.
bool sameList<T>(List<T> a, List<T> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
