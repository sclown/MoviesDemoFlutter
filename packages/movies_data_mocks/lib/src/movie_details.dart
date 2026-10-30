//
//  movie_details.dart — a placeholder movie for the tests
//

import 'package:movies_data/movies_data.dart';

MovieDetails movieDetails({int id = 1, MovieExtras? extras}) => MovieDetails(
  id: id,
  title: 'Test Movie $id',
  poster: null,
  rating: '8.5',
  releaseDate: '2025-06-15',
  overview: 'A great movie about testing software and building apps.',
  extras: extras,
);

/// The enrichment the per-movie request adds — genres, a trailer, and credits
/// on both sides of the camera.
MovieExtras movieExtras() => MovieExtras(
  genres: const ['Drama', 'Science Fiction'],
  trailers: [
    MovieTrailer(
      name: 'Official Trailer',
      url: Uri.parse('https://www.youtube.com/watch?v=abc123'),
      thumbnail: Uri.parse('https://img.youtube.com/vi/abc123/hqdefault.jpg'),
    ),
  ],
  cast: const [
    MoviePerson(id: 11, name: 'Ada Lovelace', role: 'Engineer', photo: null),
    MoviePerson(id: 12, name: 'Alan Turing', role: 'Cryptanalyst', photo: null),
  ],
  crew: const [
    MoviePerson(id: 21, name: 'Grace Hopper', role: 'Director', photo: null),
    MoviePerson(id: 21, name: 'Grace Hopper', role: 'Screenplay', photo: null),
    MoviePerson(id: 22, name: 'Katherine Johnson', role: 'Gaffer', photo: null),
  ],
);
