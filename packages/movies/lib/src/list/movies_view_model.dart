//
//  movies_view_model.dart
//

import 'package:flutter/foundation.dart';
import 'package:movies_api/movies_api.dart';
import 'package:movies_core/movies_core.dart';

import 'movie_card.dart';
import 'movies_list_state.dart';

abstract interface class MoviesViewModeling {
  ValueNotifier<MoviesListState> get state;

  void load();

  void loadMoreIfNeeded({required int currentMovieId});

  void showDetails({required int movieId});
}

final class MoviesViewModel implements MoviesViewModeling {
  MoviesViewModel({
    MoviesListState? state,
    required MovieServicing service,
    void Function(MovieDetails movie) navigation = _noNavigation,
    StateLogger<MoviesListState> logger = _noLogging,
  }) : state = ValueNotifier(state ?? MoviesListState.empty()),
       _service = service,
       _navigation = navigation,
       _logger = logger;

  @override
  final ValueNotifier<MoviesListState> state;

  final MovieServicing _service;
  final void Function(MovieDetails movie) _navigation;
  final StateLogger<MoviesListState> _logger;

  List<Movie> _movies = [];
  bool _hasLoaded = false;
  int _currentPage = 1;
  int _totalPages = 1;

  _Cancellation? _loadToken;
  _Cancellation? _loadMoreToken;

  void dispose() {
    _loadToken?.cancel();
    _loadMoreToken?.cancel();
    state.dispose();
  }

  @override
  void load() {
    if (_hasLoaded) return;
    _loadToken?.cancel();
    final token = _Cancellation();
    _loadToken = token;
    _performLoad(token);
  }

  @override
  void loadMoreIfNeeded({required int currentMovieId}) {
    if (_currentPage >= _totalPages) return;
    if (_movies.isEmpty || currentMovieId != _movies.last.id) return;
    _loadMoreToken?.cancel();
    final token = _Cancellation();
    _loadMoreToken = token;
    _performLoadMore(token);
  }

  @override
  void showDetails({required int movieId}) {
    for (final movie in _movies) {
      if (movie.id == movieId) {
        _navigation(movie.details());
        return;
      }
    }
  }

  Future<void> _performLoad(_Cancellation token) async {
    _updateState(isLoading: true);
    String? errorMessage;
    _currentPage = 1;

    try {
      final response = await _service.fetchPopularMovies(page: _currentPage);
      if (token.isCancelled) return;
      _movies = response.results;
      _totalPages = response.totalPages;
      _hasLoaded = true;
    } catch (error) {
      if (token.isCancelled) return;
      _hasLoaded = false;
      errorMessage = _describe(error);
    }

    _updateState(
      movies: [for (final movie in _movies) MovieCard.from(movie)],
      isLoading: false,
      errorMessage: errorMessage,
    );
  }

  Future<void> _performLoadMore(_Cancellation token) async {
    _updateState(isLoadingMore: true);

    try {
      final nextPage = _currentPage + 1;
      final response = await _service.fetchPopularMovies(page: nextPage);
      if (token.isCancelled) return;

      // TMDB pages overlap often enough that de-duplicating matters.
      final existingIds = {for (final movie in _movies) movie.id};
      final merged = [..._movies];
      for (final movie in response.results) {
        if (existingIds.add(movie.id)) merged.add(movie);
      }
      _movies = merged;
      _totalPages = response.totalPages;
      _currentPage = nextPage;
    } catch (_) {
      if (token.isCancelled) return;
    }

    _updateState(
      movies: [for (final movie in _movies) MovieCard.from(movie)],
      isLoadingMore: false,
    );
  }

  /// Every update clears [MoviesListState.errorMessage] unless one is passed —
  /// a new load or page always supersedes the previous failure.
  void _updateState({
    List<MovieCard>? movies,
    bool? isLoading,
    bool? isLoadingMore,
    String? errorMessage,
  }) {
    final current = state.value;
    final next = MoviesListState(
      movies: movies ?? current.movies,
      isLoading: isLoading ?? current.isLoading,
      isLoadingMore: isLoadingMore ?? current.isLoadingMore,
      errorMessage: errorMessage,
    );
    state.value = next;
    _logger(next);
  }

  String _describe(Object error) => switch (error) {
    Exception() => error.toString().replaceFirst('Exception: ', ''),
    _ => error.toString(),
  };

  static void _noNavigation(MovieDetails movie) {}

  static void _noLogging(MoviesListState state) {}
}

/// Dart futures cannot be cancelled, so a superseded load is handed a token
/// and told to drop its result instead.
final class _Cancellation {
  bool isCancelled = false;

  void cancel() => isCancelled = true;
}
