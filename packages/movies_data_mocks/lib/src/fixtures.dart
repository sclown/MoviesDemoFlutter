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
