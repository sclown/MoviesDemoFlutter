//
//  movie_tools.dart
//

import 'dtos/movie.dart';
import 'dtos/movie_detail.dart';

import 'movie_details.dart';
import 'movie_extras.dart';

const _imageBase = 'https://image.tmdb.org/t/p';

extension MovieTools on Movie {
  Uri? fullPoster() => _poster(posterPath, 'original');

  Uri? smallPoster() => _poster(posterPath, 'w500');

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

extension MovieDetailTools on MovieDetailResponse {
  /// The whole movie, enrichment included — what a details screen opened
  /// without a cached entry has to fall back on.
  MovieDetails details() => MovieDetails(
    id: id,
    title: title,
    poster: _poster(posterPath, 'original'),
    rating: voteAverage.toStringAsFixed(1),
    releaseDate: releaseDate,
    overview: overview,
    extras: extras(),
  );

  MovieExtras extras() => MovieExtras(
    genres: [for (final genre in genres) genre.name],
    trailers: _trailers(),
    cast: [
      for (final member in _byBilling())
        MoviePerson(
          id: member.id,
          name: member.name,
          role: member.character,
          photo: _poster(member.profilePath, 'w185'),
        ),
    ],
    crew: [
      for (final member in crew)
        MoviePerson(
          id: member.id,
          name: member.name,
          role: member.job,
          photo: _poster(member.profilePath, 'w185'),
        ),
    ],
  );

  /// Playable videos, official trailers first, then teasers, then the rest —
  /// TMDB returns them in no particular order.
  List<MovieTrailer> _trailers() {
    const rank = {'Trailer': 0, 'Teaser': 1, 'Clip': 2};

    final playable = videos.where((video) => video.site == 'YouTube').toList()
      ..sort((a, b) {
        final byType = (rank[a.type] ?? 3).compareTo(rank[b.type] ?? 3);
        if (byType != 0) return byType;
        if (a.official != b.official) return a.official ? -1 : 1;
        return 0;
      });

    return [
      for (final video in playable)
        MovieTrailer(
          name: video.name,
          url: Uri.parse('https://www.youtube.com/watch?v=${video.key}'),
          thumbnail: Uri.parse(
            'https://img.youtube.com/vi/${video.key}/hqdefault.jpg',
          ),
        ),
    ];
  }

  List<CastCredit> _byBilling() =>
      cast.toList()..sort((a, b) => a.order.compareTo(b.order));
}

Uri? _poster(String? path, String size) {
  if (path == null) return null;
  return Uri.tryParse('$_imageBase/$size$path');
}
