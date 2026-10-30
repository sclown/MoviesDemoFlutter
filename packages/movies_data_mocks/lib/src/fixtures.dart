//
//  fixtures.dart — placeholder values the service can return
//

import 'package:movies_data/movies_data.dart';

Movie movie({required int id, String? title, String? posterPath}) => Movie(
  id: id,
  title: title ?? 'Test Movie $id',
  overview: 'A test movie',
  posterPath: posterPath,
  releaseDate: '2025-01-01',
  voteAverage: 7.5,
);

/// A page holding a movie per entry in [ids].
MovieResponse movieResponse({
  required List<int> ids,
  int totalPages = 1,
}) => MovieResponse(
  results: [for (final id in ids) movie(id: id)],
  totalPages: totalPages,
);

/// The `/movie/{id}` payload with `credits` and `videos` appended, as the
/// details screen's second request receives it.
MovieDetailResponse movieDetailResponse({
  int id = 1,
  List<String> genres = const ['Drama'],
}) => MovieDetailResponse(
  id: id,
  title: 'Test Movie $id',
  overview: 'A test movie',
  posterPath: null,
  releaseDate: '2025-01-01',
  voteAverage: 7.5,
  genres: [
    for (final (index, name) in genres.indexed)
      Genre(id: index + 1, name: name),
  ],
  videos: const [
    Video(
      key: 'abc123',
      name: 'Official Trailer',
      site: 'YouTube',
      type: 'Trailer',
      official: true,
    ),
  ],
  cast: const [
    CastCredit(
      id: 11,
      name: 'Ada Lovelace',
      character: 'Engineer',
      profilePath: null,
      order: 0,
    ),
  ],
  crew: const [
    CrewCredit(
      id: 21,
      name: 'Grace Hopper',
      job: 'Director',
      department: 'Directing',
      profilePath: null,
    ),
  ],
);
