//
//  movie_parser.dart
//

import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:typed_data';

import 'dtos/movie.dart';
import 'dtos/movie_detail.dart';

final class MovieParser {
  const MovieParser();

  MovieResponse parseMovieResponse(Uint8List data) =>
      _parse(data, MovieResponse.fromJson, 'MovieResponse');

  MovieDetailResponse parseMovieDetail(Uint8List data) =>
      _parse(data, MovieDetailResponse.fromJson, 'MovieDetailResponse');

  T _parse<T>(
    Uint8List data,
    T Function(Map<String, dynamic>) build,
    String what,
  ) {
    try {
      final json = jsonDecode(utf8.decode(data)) as Map<String, dynamic>;
      return build(json);
    } catch (error) {
      developer.log(
        'Failed to parse $what: $error',
        name: 'org.kurkin.movies.MovieParser',
        level: 1000,
      );
      rethrow;
    }
  }
}
