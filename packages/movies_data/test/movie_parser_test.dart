import 'dart:convert';
import 'dart:typed_data';

import 'package:movies_data/movies_data.dart';
import 'package:test/test.dart';

import 'fixtures.dart';

void main() {
  const parser = MovieParser();

  test('parses a valid response', () {
    final response = parser.parseMovieResponse(Json.singleValid);

    expect(response.results, hasLength(1));
    expect(response.totalPages, 5);
    expect(response.results[0].title, 'Test Movie 1');
    expect(response.results[0].posterPath, '/test.jpg');
    expect(response.results[0].releaseDate, '2025-01-01');
    expect(response.results[0].voteAverage, 7.5);
  });

  test('parses a response with null optionals', () {
    final response = parser.parseMovieResponse(Json.lowDataList);

    expect(response.results[0].posterPath, isNull);
    expect(response.results[0].releaseDate, isNull);
  });

  test('throws on invalid JSON', () {
    final data = Uint8List.fromList(utf8.encode('not json'));

    expect(() => parser.parseMovieResponse(data), throwsA(isA<Object>()));
  });

  test('throws when a required field is missing', () {
    expect(
      () => parser.parseMovieResponse(Json.invalidDataList),
      throwsA(isA<FormatException>()),
    );
  });
}
