//
//  movie_parser.dart
//

import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:typed_data';

import 'dtos/movie.dart';

final class MovieParser {
  const MovieParser();

  MovieResponse parseMovieResponse(Uint8List data) {
    try {
      final json = jsonDecode(utf8.decode(data)) as Map<String, dynamic>;
      return MovieResponse.fromJson(json);
    } catch (error) {
      developer.log(
        'Failed to parse MovieResponse: $error',
        name: 'org.kurkin.movies.MovieParser',
        level: 1000,
      );
      rethrow;
    }
  }
}
