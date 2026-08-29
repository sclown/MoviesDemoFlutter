import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movies/src/list/movies_cubit.dart';
import 'package:movies/src/list/movies_list_state.dart';
import 'package:movies_api/movies_api.dart';
import 'package:movies_api_mocks/movies_api_mocks.dart';
import 'package:movies_core/movies_core.dart';
import 'package:network_service/network_service.dart';

/// Answers `fetchPopularMovies` with [pages] in order, repeating the last one.
MoviesApiMock apiReturning(List<MovieResponse> pages) {
  final api = MoviesApiMock();
  var call = 0;
  when(() => api.fetchPopularMovies(page: any(named: 'page'))).thenAnswer((_) async {
    final page = pages[call < pages.length ? call : pages.length - 1];
    call++;
    return page;
  });
  return api;
}

MoviesApiMock apiFailing(Object error) {
  final api = MoviesApiMock();
  when(() => api.fetchPopularMovies(page: any(named: 'page'))).thenThrow(error);
  return api;
}

MoviesCubit makeCubit(
  MoviesApiMock api, {
  MovieCache? cache,
  void Function(int movieId) navigation = _ignore,
}) => MoviesCubit(
  service: api,
  cache: cache ?? MovieCache(),
  navigation: navigation,
);

void _ignore(int movieId) {}

/// Lets an in-flight request settle before the next call.
Future<void> settle() => Future<void>.delayed(const Duration(milliseconds: 10));

/// The in-flight state. `emit` only skips a duplicate after the first one has
/// gone out, so the opening `isLoading: true` is emitted even though it equals
/// the initial state.
TypeMatcher<MoviesListState> loading({Object? errorMessage}) =>
    isA<MoviesListState>()
        .having((s) => s.isLoading, 'isLoading', true)
        .having((s) => s.errorMessage, 'errorMessage', errorMessage ?? isNull);

/// A finished state: not loading, no error unless one is expected.
TypeMatcher<MoviesListState> loaded({
  Object? movies,
  Object? isLoadingMore,
  Object? errorMessage,
}) => isA<MoviesListState>()
    .having((s) => s.isLoading, 'isLoading', false)
    .having((s) => s.movies, 'movies', movies ?? anything)
    .having((s) => s.isLoadingMore, 'isLoadingMore', isLoadingMore ?? false)
    .having((s) => s.errorMessage, 'errorMessage', errorMessage ?? isNull);

void main() {
  late MoviesApiMock api;

  blocTest<MoviesCubit, MoviesListState>(
    'load emits the movies',
    build: () => makeCubit(apiReturning([movieResponse(ids: [1, 2])])),
    act: (cubit) => cubit.load(),
    expect: () => [loading(), loaded(movies: hasLength(2))],
  );

  blocTest<MoviesCubit, MoviesListState>(
    'load emits an error on failure',
    build: () => makeCubit(apiFailing(const NetworkError.noConnection())),
    act: (cubit) => cubit.load(),
    expect: () => [loading(), loaded(movies: isEmpty, errorMessage: isNotNull)],
  );

  blocTest<MoviesCubit, MoviesListState>(
    'load asks the service only once',
    build: () {
      api = apiReturning([movieResponse(ids: [1, 2])]);
      return makeCubit(api);
    },
    act: (cubit) async {
      cubit.load();
      await settle();
      cubit.load();
      await settle();
    },
    expect: () => [loading(), loaded(movies: hasLength(2))],
    // The guard is real: the service is asked exactly once.
    verify: (_) => verify(() => api.fetchPopularMovies(page: 1)).called(1),
  );

  test('load can be retried after a failure', () async {
    final api = MoviesApiMock();
    var attempt = 0;
    when(() => api.fetchPopularMovies(page: any(named: 'page'))).thenAnswer((_) async {
      if (attempt++ == 0) throw const NetworkError.noConnection();
      return movieResponse(ids: [1, 2]);
    });
    final cubit = makeCubit(api);

    cubit.load();
    await settle();
    expect(cubit.state.errorMessage, isNotNull);

    cubit.load();
    await settle();

    expect(cubit.state.errorMessage, isNull);
    expect(cubit.state.movies, hasLength(2));
    await cubit.close();
  });

  blocTest<MoviesCubit, MoviesListState>(
    'load more appends the next page',
    build: () => makeCubit(
      apiReturning([
        movieResponse(ids: [1, 2], totalPages: 5),
        movieResponse(ids: [3, 4], totalPages: 5),
      ]),
    ),
    act: (cubit) async {
      cubit.load();
      await settle();
      cubit.loadMoreIfNeeded(currentMovieId: cubit.state.movies.last.id);
      await settle();
    },
    expect: () => [
      loading(),
      loaded(movies: hasLength(2)),
      isA<MoviesListState>()
          .having((s) => s.isLoadingMore, 'isLoadingMore', true),
      loaded(movies: hasLength(4)),
    ],
  );

  blocTest<MoviesCubit, MoviesListState>(
    'load more de-duplicates overlapping pages',
    build: () => makeCubit(
      apiReturning([
        movieResponse(ids: [1, 2], totalPages: 5),
        // The second page repeats movie 2 and adds movie 3.
        movieResponse(ids: [2, 3], totalPages: 5),
      ]),
    ),
    act: (cubit) async {
      cubit.load();
      await settle();
      cubit.loadMoreIfNeeded(currentMovieId: cubit.state.movies.last.id);
      await settle();
    },
    verify: (cubit) =>
        expect(cubit.state.movies.map((movie) => movie.id), [1, 2, 3]),
  );

  blocTest<MoviesCubit, MoviesListState>(
    'load more ignores a cell that is not the last one',
    build: () =>
        makeCubit(apiReturning([movieResponse(ids: [1, 2], totalPages: 3)])),
    act: (cubit) async {
      cubit.load();
      await settle();
      cubit.loadMoreIfNeeded(currentMovieId: cubit.state.movies.first.id);
      await settle();
    },
    expect: () => [loading(), loaded(movies: hasLength(2))],
  );

  blocTest<MoviesCubit, MoviesListState>(
    'load more stops at the last page',
    build: () =>
        makeCubit(apiReturning([movieResponse(ids: [1, 2])])),
    act: (cubit) async {
      cubit.load();
      await settle();
      cubit.loadMoreIfNeeded(currentMovieId: cubit.state.movies.last.id);
      await settle();
    },
    expect: () => [loading(), loaded(movies: hasLength(2))],
  );

  test('show details caches the movie and navigates to its id', () async {
    int? navigated;
    final cache = MovieCache();
    final cubit = makeCubit(
      apiReturning([movieResponse(ids: [1])]),
      cache: cache,
      navigation: (id) => navigated = id,
    );

    cubit.load();
    await settle();
    cubit.showDetails(movieId: 1);

    expect(navigated, 1);
    // The details screen renders straight out of the cache.
    expect(cache[1], isNotNull);
    expect(cache[1]!.title, 'Test Movie 1');
    await cubit.close();
  });

  test('show details ignores an unknown id', () async {
    int? navigated;
    final cubit = makeCubit(
      apiReturning([movieResponse(ids: [1, 2])]),
      navigation: (id) => navigated = id,
    );

    cubit.load();
    await settle();
    cubit.showDetails(movieId: 999);

    expect(navigated, isNull);
    await cubit.close();
  });
}
