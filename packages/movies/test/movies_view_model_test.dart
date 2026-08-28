import 'package:flutter_test/flutter_test.dart';
import 'package:movies/src/list/movies_list_state.dart';
import 'package:movies/src/list/movies_view_model.dart';
import 'package:movies_api/mocks.dart';
import 'package:movies_api/movies_api.dart';
import 'package:movies_core/movies_core.dart';
import 'package:network_service/mocks.dart';
import 'package:network_service/network_service.dart';

import 'test_state_logger.dart';

MoviesViewModel makeViewModel({
  required Result data,
  required TestStateLogger<MoviesListState> logger,
  void Function(MovieDetails movie) navigation = _ignore,
}) {
  final client = MockNetworkClient(result: data);
  final service = MovieService(networkClient: client, apiKey: 'test-key');
  final viewModel = MoviesViewModel(service: service, navigation: navigation);
  viewModel.state.addListener(() => logger.log(viewModel.state.value));
  return viewModel;
}

void _ignore(MovieDetails movie) {}

void main() {
  late TestStateLogger<MoviesListState> logger;

  setUp(() => logger = TestStateLogger<MoviesListState>());
  tearDown(() => logger.dispose());

  test('load sets the movies', () async {
    final vm = makeViewModel(
      data: Result.success(Json.validList()),
      logger: logger,
    );

    vm.load();
    final loading = await logger.next();
    final loaded = await logger.next();

    expect(loading.isLoading, isTrue);
    expect(loaded.isLoading, isFalse);
    expect(loaded.movies, hasLength(2));
    expect(loaded.errorMessage, isNull);
  });

  test('load sets an error on failure', () async {
    final vm = makeViewModel(
      data: Result.failure(const NetworkError.noConnection()),
      logger: logger,
    );

    vm.load();
    final loading = await logger.next();
    final loaded = await logger.next();

    expect(loading.isLoading, isTrue);
    expect(loaded.isLoading, isFalse);
    expect(loaded.movies, isEmpty);
    expect(
      loaded.errorMessage,
      'No internet connection. Please check your network settings.',
    );
  });

  test('load runs only once', () async {
    final vm = makeViewModel(
      data: Result.success(Json.validList()),
      logger: logger,
    );

    vm.load();
    await logger.collect(count: 2);
    vm.load();

    await expectLater(
      logger.collect(count: 1, timeout: const Duration(milliseconds: 100)),
      throwsA(isA<TestLoggerTimeout>()),
    );
  });

  test('load more appends the next page', () async {
    final client = MockNetworkClient.success(Json.validList(from: 1, to: 3));
    final service = MovieService(networkClient: client, apiKey: 'test-key');
    final vm = MoviesViewModel(service: service);
    vm.state.addListener(() => logger.log(vm.state.value));

    vm.load();
    await logger.collect(count: 2);
    client.result = Result.success(Json.validList(from: 3, to: 5));

    final lastMovie = vm.state.value.movies.last;
    vm.loadMoreIfNeeded(currentMovieId: lastMovie.id);
    final loading = await logger.next();
    final loaded = await logger.next();

    expect(loading.isLoadingMore, isTrue);
    expect(loaded.isLoadingMore, isFalse);
    expect(loaded.movies, hasLength(4));
  });

  test('load more de-duplicates overlapping pages', () async {
    final client = MockNetworkClient.success(Json.validList(from: 1, to: 3));
    final service = MovieService(networkClient: client, apiKey: 'test-key');
    final vm = MoviesViewModel(service: service);
    vm.state.addListener(() => logger.log(vm.state.value));

    vm.load();
    await logger.collect(count: 2);
    // The second page repeats movie 2 and adds movie 3.
    client.result = Result.success(Json.validList(from: 2, to: 4));

    vm.loadMoreIfNeeded(currentMovieId: vm.state.value.movies.last.id);
    await logger.collect(count: 1);
    final loaded = await logger.next();

    expect(loaded.movies.map((movie) => movie.id), [1, 2, 3]);
  });

  test('load more ignores a cell that is not the last one', () async {
    final vm = makeViewModel(
      data: Result.success(Json.validList(total: 3)),
      logger: logger,
    );

    vm.load();
    await logger.collect(count: 2);

    final firstMovie = vm.state.value.movies.first;
    vm.loadMoreIfNeeded(currentMovieId: firstMovie.id);

    await expectLater(
      logger.collect(count: 1, timeout: const Duration(milliseconds: 100)),
      throwsA(isA<TestLoggerTimeout>()),
    );
    expect(vm.state.value.movies, hasLength(2));
  });

  test('load more stops at the last page', () async {
    final vm = makeViewModel(
      data: Result.success(Json.validList(total: 1)),
      logger: logger,
    );

    vm.load();
    await logger.collect(count: 2);

    vm.loadMoreIfNeeded(currentMovieId: vm.state.value.movies.last.id);

    await expectLater(
      logger.collect(count: 1, timeout: const Duration(milliseconds: 100)),
      throwsA(isA<TestLoggerTimeout>()),
    );
  });

  test('show details triggers navigation', () async {
    MovieDetails? navigated;
    final vm = makeViewModel(
      data: Result.success(Json.validList(to: 2)),
      logger: logger,
      navigation: (movie) => navigated = movie,
    );

    vm.load();
    await logger.collect(count: 2);

    vm.showDetails(movieId: 1);

    expect(navigated, isNotNull);
    expect(navigated!.id, 1);
    expect(navigated!.title, 'Test Movie 1');
  });

  test('show details ignores an unknown id', () async {
    MovieDetails? navigated;
    final vm = makeViewModel(
      data: Result.success(Json.validList()),
      logger: logger,
      navigation: (movie) => navigated = movie,
    );

    vm.load();
    await logger.collect(count: 2);

    vm.showDetails(movieId: 999);

    expect(navigated, isNull);
  });
}
