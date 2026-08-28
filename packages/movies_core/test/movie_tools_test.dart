import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:movies_api/movies_api.dart';
import 'package:movies_core/movies_core.dart';

Movie makeMovie({String? posterPath = '/abc.jpg', double vote = 7.45}) {
  final posterField = posterPath == null ? 'null' : '"$posterPath"';
  final json =
      '{"id": 1, "title": "Test", "overview": "Overview", '
      '"poster_path": $posterField, "release_date": "2025-01-02", '
      '"vote_average": $vote}';
  return const MovieParser()
      .parseMovieResponse(
        Uint8List.fromList(utf8.encode('{"results": [$json], "total_pages": 1}')),
      )
      .results
      .first;
}

void main() {
  test('rating text is one decimal', () {
    expect(makeMovie(vote: 7.456).ratingText(), '7.5');
  });

  test('posters are null when the path is missing', () {
    final movie = makeMovie(posterPath: null);
    expect(movie.fullPoster(), isNull);
    expect(movie.smallPoster(), isNull);
  });

  test('posters use the right TMDB size', () {
    final movie = makeMovie();
    expect(
      movie.fullPoster().toString(),
      'https://image.tmdb.org/t/p/original/abc.jpg',
    );
    expect(
      movie.smallPoster().toString(),
      'https://image.tmdb.org/t/p/w500/abc.jpg',
    );
  });

  test('details copies the fields across', () {
    final movie = makeMovie();
    final details = movie.details();

    expect(details.id, movie.id);
    expect(details.title, movie.title);
    expect(details.releaseDate, movie.releaseDate);
    expect(details.overview, movie.overview);
    expect(details.rating, '7.5');
  });
}
