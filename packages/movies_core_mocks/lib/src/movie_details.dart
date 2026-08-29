//
//  movie_details.dart — a placeholder movie for the tests
//

import 'package:movies_core/movies_core.dart';

MovieDetails movieDetails({int id = 1}) => MovieDetails(
  id: id,
  title: 'Test Movie $id',
  poster: null,
  rating: '8.5',
  releaseDate: '2025-06-15',
  overview: 'A great movie about testing software and building apps.',
);
