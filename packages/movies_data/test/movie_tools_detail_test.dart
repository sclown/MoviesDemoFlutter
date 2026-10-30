import 'package:movies_data/movies_data.dart';
import 'package:test/test.dart';

import 'fixtures.dart';

void main() {
  const parser = MovieParser();

  MovieExtras extras() => parser.parseMovieDetail(Json.movieDetail).extras();

  test('maps the genres to their names', () {
    expect(extras().genres, ['Drama', 'Science Fiction']);
  });

  test('keeps only playable videos, trailers first', () {
    final trailers = extras().trailers;

    // The Vimeo entry has no playable link, so it is dropped; the trailer
    // outranks the clip regardless of the order TMDB returned them in.
    expect(trailers.map((trailer) => trailer.name), [
      'Official Trailer',
      'A Clip',
    ]);
  });

  test('builds a watch link and a still for each trailer', () {
    final trailer = extras().trailers.first;

    expect(trailer.url.toString(), 'https://www.youtube.com/watch?v=tr1');
    expect(
      trailer.thumbnail.toString(),
      'https://img.youtube.com/vi/tr1/hqdefault.jpg',
    );
  });

  test('orders the cast by billing, not by payload order', () {
    expect(extras().cast.map((person) => person.name), [
      'Ada Lovelace',
      'Alan Turing',
    ]);
  });

  test('carries the character as the cast role', () {
    expect(extras().cast.first.role, 'Engineer');
  });

  test('carries the job as the crew role', () {
    expect(extras().crew.single.role, 'Director');
  });

  test('sizes a profile photo for a row and leaves a missing one null', () {
    final cast = extras().cast;

    expect(
      cast.first.photo.toString(),
      'https://image.tmdb.org/t/p/w185/ada.jpg',
    );
    expect(cast.last.photo, isNull);
  });

  test('builds a whole movie for a details screen opened from cold', () {
    final movie = parser.parseMovieDetail(Json.movieDetail).details();

    expect(movie.id, 42);
    expect(movie.title, 'Test Movie 42');
    expect(movie.rating, '7.5');
    expect(movie.releaseDate, '2025-01-01');
    expect(
      movie.poster.toString(),
      'https://image.tmdb.org/t/p/original/poster.jpg',
    );
    expect(movie.isComplete, isTrue);
  });
}
