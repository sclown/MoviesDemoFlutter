//
//  movies_cubit.dart
//

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movies_api/movies_api.dart';
import 'package:movies_core/movies_core.dart';

import 'movie_card.dart';
import 'movies_list_state.dart';

class MoviesCubit extends Cubit<MoviesListState> {
  MoviesCubit({
    MoviesListState? state,
    required MovieServicing service,
    required MovieCache cache,
    void Function(int movieId) navigation = _noNavigation,
  }) : _service = service,
       _cache = cache,
       _navigation = navigation,
       super(state ?? MoviesListState.empty());

  final MovieServicing _service;
  final MovieCache _cache;
  final void Function(int movieId) _navigation;

  List<Movie> _movies = [];
  bool _hasLoaded = false;
  int _currentPage = 1;
  int _totalPages = 1;

  _Cancellation? _loadToken;
  _Cancellation? _loadMoreToken;

  @override
  Future<void> close() {
    _loadToken?.cancel();
    _loadMoreToken?.cancel();
    return super.close();
  }

  void load() {
    if (_hasLoaded) return;
    _loadToken?.cancel();
    final token = _Cancellation();
    _loadToken = token;
    _performLoad(token);
  }

  void loadMoreIfNeeded({required int currentMovieId}) {
    if (_currentPage >= _totalPages) return;
    if (_movies.isEmpty || currentMovieId != _movies.last.id) return;
    _loadMoreToken?.cancel();
    final token = _Cancellation();
    _loadMoreToken = token;
    _performLoadMore(token);
  }

  void showDetails({required int movieId}) {
    if (_cache.contains(movieId)) _navigation(movieId);
  }

  /// The details screen reads from the cache, so every movie shown in the grid
  /// has to be in it before a tap can open one.
  void _cacheMovies() =>
      _cache.putAll([for (final movie in _movies) movie.details()]);

  Future<void> _performLoad(_Cancellation token) async {
    emit(state.copyWith(isLoading: true));
    String? errorMessage;
    _currentPage = 1;

    try {
      final response = await _service.fetchPopularMovies(page: _currentPage);
      if (token.isCancelled) return;
      _movies = response.results;
      _totalPages = response.totalPages;
      _hasLoaded = true;
      _cacheMovies();
    } catch (error) {
      if (token.isCancelled) return;
      _hasLoaded = false;
      errorMessage = describeError(error);
    }

    emit(
      state.copyWith(
        movies: [for (final movie in _movies) MovieCard.from(movie)],
        isLoading: false,
        errorMessage: errorMessage,
      ),
    );
  }

  Future<void> _performLoadMore(_Cancellation token) async {
    emit(state.copyWith(isLoadingMore: true));

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
      _cacheMovies();
    } catch (_) {
      if (token.isCancelled) return;
    }

    emit(
      state.copyWith(
        movies: [for (final movie in _movies) MovieCard.from(movie)],
        isLoadingMore: false,
      ),
    );
  }

  static void _noNavigation(int movieId) {}
}

/// Dart futures cannot be cancelled, so a superseded load is handed a token
/// and told to drop its result instead.
final class _Cancellation {
  bool isCancelled = false;

  void cancel() => isCancelled = true;
}
