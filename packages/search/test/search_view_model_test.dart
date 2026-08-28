import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:movies_api/mocks.dart';
import 'package:movies_api/movies_api.dart';
import 'package:movies_core/movies_core.dart';
import 'package:network_service/mocks.dart';
import 'package:network_service/network_service.dart';
import 'package:search/src/search_state.dart';
import 'package:search/src/search_view_model.dart';

import 'test_state_logger.dart';

SearchViewModel makeSearchViewModel({
  Result? data,
  required TestStateLogger<SearchState> logger,
  void Function(MovieDetails movie) navigation = _ignore,
}) {
  final client = MockNetworkClient(
    result: data ?? Result.success(Json.list(ids: const [], totalPages: 1)),
  );
  final service = MovieService(networkClient: client, apiKey: 'test-key');
  return SearchViewModel(
    service: service,
    navigation: navigation,
    logger: logger.log,
    // The debounce itself is asserted separately; the rest of the suite would
    // only be waiting on a timer.
    debounce: const Duration(milliseconds: 10),
  );
}

void _ignore(MovieDetails movie) {}

void main() {
  late TestStateLogger<SearchState> logger;

  setUp(() => logger = TestStateLogger<SearchState>());
  tearDown(() => logger.dispose());

  test('search debounces and returns results', () async {
    final vm = makeSearchViewModel(
      data: Result.success(Json.list(ids: const [10, 11], totalPages: 1)),
      logger: logger,
    );

    vm.updateSearchQuery('test');
    final searching = await logger.next();
    final searched = await logger.next();

    expect(searching.isSearching, isTrue);
    expect(searched.isSearching, isFalse);
    expect(searched.searchResults, hasLength(2));
    expect(searched.searchResults.first.id, 10);
  });

  test('only the last query of a burst reaches the service', () async {
    final client = _CountingClient(Json.list(ids: const [10], totalPages: 1));
    final service = MovieService(networkClient: client, apiKey: 'test-key');
    final vm = SearchViewModel(
      service: service,
      logger: logger.log,
      debounce: const Duration(milliseconds: 50),
    );

    vm.updateSearchQuery('b');
    vm.updateSearchQuery('ba');
    vm.updateSearchQuery('bat');

    await logger.collect(count: 3); // three "isSearching" transitions
    final searched = await logger.next();

    expect(searched.searchQuery, 'bat');
    expect(client.callCount, 1);
  });

  test('clearing the search clears the results', () async {
    final vm = makeSearchViewModel(
      data: Result.success(Json.list(ids: const [10], totalPages: 1)),
      logger: logger,
    );

    vm.updateSearchQuery('test');
    await logger.collect(count: 1);
    final searched = await logger.next();
    expect(searched.searchResults, hasLength(1));

    vm.updateSearchQuery('');
    final cleared = await logger.next();

    expect(cleared.searchResults, isEmpty);
    expect(cleared.searchQuery, isEmpty);
  });

  test('an empty result set shows the empty label', () async {
    final vm = makeSearchViewModel(
      data: Result.success(Json.list(ids: const [], totalPages: 1)),
      logger: logger,
    );

    vm.updateSearchQuery('xyzzy');
    await logger.collect(count: 1);
    final searched = await logger.next();

    expect(searched.searchResults, isEmpty);
    expect(searched.showEmptyLabel, isTrue);
  });

  test('a failed search shows the empty label rather than an error', () async {
    final vm = makeSearchViewModel(
      data: Result.failure(const NetworkError.noConnection()),
      logger: logger,
    );

    vm.updateSearchQuery('test');
    await logger.collect(count: 1);
    final searched = await logger.next();

    expect(searched.searchResults, isEmpty);
    expect(searched.showEmptyLabel, isTrue);
    expect(searched.isSearching, isFalse);
  });

  test('repeating the current query is ignored', () async {
    final vm = makeSearchViewModel(
      data: Result.success(Json.list(ids: const [10], totalPages: 1)),
      logger: logger,
    );

    vm.updateSearchQuery('test');
    await logger.collect(count: 2);
    vm.updateSearchQuery('test');

    await expectLater(
      logger.collect(count: 1, timeout: const Duration(milliseconds: 100)),
      throwsA(isA<TestLoggerTimeout>()),
    );
  });

  test('show details invokes the navigation callback', () async {
    MovieDetails? navigated;
    final vm = makeSearchViewModel(
      data: Result.success(Json.list(ids: const [42], totalPages: 1)),
      logger: logger,
      navigation: (movie) => navigated = movie,
    );

    vm.updateSearchQuery('test');
    await logger.collect(count: 2);

    vm.showDetails(movieId: 42);

    expect(navigated?.id, 42);
  });
}

/// Counts how many requests actually reach the network.
final class _CountingClient implements NetworkClient {
  _CountingClient(this._payload);

  final Uint8List _payload;
  var callCount = 0;

  @override
  Future<Uint8List> data(Uri url) async {
    callCount++;
    return _payload;
  }
}
