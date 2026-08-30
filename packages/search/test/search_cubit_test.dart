import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies_data/movies_data.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movies_data_mocks/movies_data_mocks.dart';
import 'package:network_service/network_service.dart';
import 'package:search/src/search_cubit.dart';
import 'package:search/src/search_state.dart';
/// An api answering `searchMovies` with a page holding [ids].
MoviesApiMock apiReturning(List<int> ids) {
  final api = MoviesApiMock();
  when(
    () => api.searchMovies(query: any(named: 'query'), page: any(named: 'page')),
  ).thenAnswer((_) async => movieResponse(ids: ids));
  return api;
}
MoviesApiMock apiFailing(Object error) {
  final api = MoviesApiMock();
  when(
    () => api.searchMovies(query: any(named: 'query'), page: any(named: 'page')),
  ).thenThrow(error);
  return api;
}
SearchCubit makeCubit({
  MoviesApiMock? api,
  MovieCache? cache,
  void Function(int movieId) navigation = _ignore,
  Duration debounce = const Duration(milliseconds: 10),
}) => SearchCubit(
  service: api ?? apiReturning(const []),
  cache: cache ?? MovieCache(),
  navigation: navigation,
  // The debounce itself is asserted separately; the rest of the suite would
  // only be waiting on a timer.
  debounce: debounce,
);
void _ignore(int movieId) {}
Future<void> settle() => Future<void>.delayed(const Duration(milliseconds: 60));
TypeMatcher<SearchState> searching(String query) => isA<SearchState>()
    .having((s) => s.isSearching, 'isSearching', true)
    .having((s) => s.searchQuery, 'searchQuery', query)
    .having((s) => s.showEmptyLabel, 'showEmptyLabel', false);
TypeMatcher<SearchState> settled({
  Object? results,
  Object? showEmptyLabel,
  String? query,
}) => isA<SearchState>()
    .having((s) => s.isSearching, 'isSearching', false)
    .having((s) => s.searchResults, 'searchResults', results ?? anything)
    .having((s) => s.showEmptyLabel, 'showEmptyLabel', showEmptyLabel ?? anything)
    .having((s) => s.searchQuery, 'searchQuery', query ?? anything)
    .having((s) => s.errorMessage, 'errorMessage', isNull);
void main() {
  blocTest<SearchCubit, SearchState>(
    'search debounces and returns results',
    build: () => makeCubit(api: apiReturning(const [10, 11])),
    act: (cubit) async {
      cubit.updateSearchQuery('test');
      await settle();
    },
    expect: () => [searching('test'), settled(results: hasLength(2))],
    verify: (cubit) => expect(cubit.state.searchResults.first.id, 10),
  );
  test('only the last query of a burst reaches the service', () async {
    final api = apiReturning(const [10]);
    final cubit = makeCubit(api: api, debounce: const Duration(milliseconds: 50));
    cubit.updateSearchQuery('b');
    cubit.updateSearchQuery('ba');
    cubit.updateSearchQuery('bat');
    await Future<void>.delayed(const Duration(milliseconds: 150));
    expect(cubit.state.searchQuery, 'bat');
    verify(() => api.searchMovies(query: 'bat', page: 1)).called(1);
    verifyNever(() => api.searchMovies(query: 'b', page: any(named: 'page')));
    verifyNever(() => api.searchMovies(query: 'ba', page: any(named: 'page')));
    await cubit.close();
  });
  blocTest<SearchCubit, SearchState>(
    'clearing the search clears the results',
    build: () =>
        makeCubit(api: apiReturning(const [10])),
    act: (cubit) async {
      cubit.updateSearchQuery('test');
      await settle();
      cubit.updateSearchQuery('');
    },
    expect: () => [
      searching('test'),
      settled(results: hasLength(1)),
      settled(results: isEmpty, query: '', showEmptyLabel: false),
    ],
  );
  blocTest<SearchCubit, SearchState>(
    'an empty result set shows the empty label',
    build: () =>
        makeCubit(api: apiReturning(const [])),
    act: (cubit) async {
      cubit.updateSearchQuery('xyzzy');
      await settle();
    },
    expect: () => [
      searching('xyzzy'),
      settled(results: isEmpty, showEmptyLabel: true),
    ],
  );
  blocTest<SearchCubit, SearchState>(
    'a failed search reports the error, not an empty result set',
    build: () =>
        makeCubit(api: apiFailing(const NetworkError.noConnection())),
    act: (cubit) async {
      cubit.updateSearchQuery('test');
      await settle();
    },
    expect: () => [
      searching('test'),
      isA<SearchState>()
          .having((s) => s.isSearching, 'isSearching', false)
          .having((s) => s.searchResults, 'searchResults', isEmpty)
          .having((s) => s.errorMessage, 'errorMessage', isNotNull)
          // The user must not be told the search simply found nothing.
          .having((s) => s.showEmptyLabel, 'showEmptyLabel', false),
    ],
  );

  blocTest<SearchCubit, SearchState>(
    'a later successful query clears the error',
    build: () {
      final api = MoviesApiMock();
      var first = true;
      when(
        () => api.searchMovies(
          query: any(named: 'query'),
          page: any(named: 'page'),
        ),
      ).thenAnswer((_) async {
        if (first) {
          first = false;
          throw const NetworkError.noConnection();
        }
        return movieResponse(ids: const [10]);
      });
      return makeCubit(api: api);
    },
    act: (cubit) async {
      cubit.updateSearchQuery('test');
      await settle();
      cubit.updateSearchQuery('other');
      await settle();
    },
    verify: (cubit) {
      expect(cubit.state.errorMessage, isNull);
      expect(cubit.state.searchResults, hasLength(1));
    },
  );
  blocTest<SearchCubit, SearchState>(
    'repeating the current query is ignored',
    build: () =>
        makeCubit(api: apiReturning(const [10])),
    act: (cubit) async {
      cubit.updateSearchQuery('test');
      await settle();
      cubit.updateSearchQuery('test');
      await settle();
    },
    expect: () => [searching('test'), settled(results: hasLength(1))],
  );
  test('show details caches the result and navigates to its id', () async {
    int? navigated;
    final cache = MovieCache();
    final cubit = makeCubit(
      api: apiReturning(const [42]),
      cache: cache,
      navigation: (id) => navigated = id,
    );
    cubit.updateSearchQuery('test');
    await settle();
    cubit.showDetails(movieId: 42);
    expect(navigated, 42);
    expect(cache[42], isNotNull);
    await cubit.close();
  });
}
