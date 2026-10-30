import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/movies.dart';
import 'package:movies_data/movies_data.dart';
import 'package:movies_data_mocks/movies_data_mocks.dart';
import 'package:network_service/network_service.dart';

void main() {
  late MoviesApiMock service;
  late MovieCache cache;

  setUp(() {
    service = MoviesApiMock();
    cache = MovieCache();
  });

  DetailsCubit subject({int movieId = 1}) =>
      DetailsCubit(movieId: movieId, service: service, cache: cache);

  test('paints the cached half before the request lands', () async {
    cache.put(movieDetails());
    when(() => service.fetchMovie(id: 1)).thenAnswer((_) async {
      await Future<void>.delayed(const Duration(milliseconds: 50));
      return movieDetailResponse();
    });

    final cubit = subject();
    cubit.load();

    expect(cubit.state.movie?.title, 'Test Movie 1');
    expect(cubit.state.movie?.extras, isNull);
    expect(cubit.state.isEnriching, isTrue);

    await cubit.close();
  });

  test('fills in the extras and keeps the cached fields', () async {
    cache.put(movieDetails());
    when(
      () => service.fetchMovie(id: 1),
    ).thenAnswer((_) async => movieDetailResponse(genres: ['Drama', 'Crime']));

    final cubit = subject();
    cubit.load();
    await pumpEventQueue();

    final movie = cubit.state.movie!;
    expect(cubit.state.isEnriching, isFalse);
    expect(movie.extras?.genres, ['Drama', 'Crime']);
    expect(movie.extras?.trailers.single.name, 'Official Trailer');
    expect(movie.extras?.cast.single.name, 'Ada Lovelace');
    expect(movie.extras?.crew.single.name, 'Grace Hopper');

    // The cached rating stays, rather than being overwritten by the response's.
    expect(movie.rating, '8.5');

    await cubit.close();
  });

  test('writes the completed movie back into the cache', () async {
    cache.put(movieDetails());
    when(
      () => service.fetchMovie(id: 1),
    ).thenAnswer((_) async => movieDetailResponse());

    final cubit = subject();
    cubit.load();
    await pumpEventQueue();

    expect(cache[1]!.isComplete, isTrue);
    expect(cache[1]!.extras?.genres, ['Drama']);

    await cubit.close();
  });

  test('a second visit reuses the cache and makes no request', () async {
    cache.put(movieDetails(extras: movieExtras()));

    final cubit = subject();
    cubit.load();
    await pumpEventQueue();

    expect(cubit.state.isEnriching, isFalse);
    expect(cubit.state.movie?.extras?.genres, ['Drama', 'Science Fiction']);
    verifyNever(() => service.fetchMovie(id: any(named: 'id')));

    await cubit.close();
  });

  test('a failed enrichment leaves the cached screen standing', () async {
    cache.put(movieDetails());
    when(
      () => service.fetchMovie(id: 1),
    ).thenThrow(const NetworkError.noConnection());

    final cubit = subject();
    cubit.load();
    await pumpEventQueue();

    expect(cubit.state.movie?.title, 'Test Movie 1');
    expect(cubit.state.isEnriching, isFalse);
    expect(cubit.state.errorMessage, isNotNull);
    expect(cubit.state.isUnavailable, isFalse);

    await cubit.close();
  });

  test('an uncached id is built entirely from the request', () async {
    when(
      () => service.fetchMovie(id: 42),
    ).thenAnswer((_) async => movieDetailResponse(id: 42));

    final cubit = subject(movieId: 42);
    cubit.load();
    await pumpEventQueue();

    expect(cubit.state.movie?.title, 'Test Movie 42');
    expect(cubit.state.movie?.rating, '7.5');
    expect(cubit.state.movie?.extras?.genres, ['Drama']);
    expect(cache[42], isNotNull);

    await cubit.close();
  });

  test('an uncached id whose request fails is unavailable', () async {
    when(
      () => service.fetchMovie(id: 99),
    ).thenThrow(const NetworkError.httpError(404));

    final cubit = subject(movieId: 99);
    cubit.load();
    await pumpEventQueue();

    expect(cubit.state.movie, isNull);
    expect(cubit.state.isUnavailable, isTrue);

    await cubit.close();
  });

  test('load is idempotent', () async {
    cache.put(movieDetails());
    when(
      () => service.fetchMovie(id: 1),
    ).thenAnswer((_) async => movieDetailResponse());

    final cubit = subject();
    cubit.load();
    cubit.load();
    await pumpEventQueue();

    verify(() => service.fetchMovie(id: 1)).called(1);

    await cubit.close();
  });
}
