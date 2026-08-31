//
//  movies_cubit.dart
//

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movies_data/movies_data.dart';

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

  var _loadTicket = 0;
  var _loadMoreTicket = 0;
  var _closed = false;

  @override
  Future<void> close() {
    _closed = true;
    return super.close();
  }

  void load() {
    if (_hasLoaded) return;
    _performLoad(++_loadTicket);
  }

  void loadMoreIfNeeded({required int currentMovieId}) {
    if (_currentPage >= _totalPages) return;
    if (_movies.isEmpty || currentMovieId != _movies.last.id) return;
    _performLoadMore(++_loadMoreTicket);
  }

  void showDetails({required int movieId}) {
    if (_cache.contains(movieId)) _navigation(movieId);
  }

  void _cacheMovies() =>
      _cache.putAll([for (final movie in _movies) movie.details()]);

  Future<void> _performLoad(int ticket) async {
    emit(state.copyWith(isLoading: true));
    String? errorMessage;
    _currentPage = 1;

    try {
      final response = await _service.fetchPopularMovies(page: _currentPage);
      if (_superseded(ticket, _loadTicket)) return;
      _movies = response.results;
      _totalPages = response.totalPages;
      _hasLoaded = true;
      _cacheMovies();
    } catch (error) {
      if (_superseded(ticket, _loadTicket)) return;
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

  Future<void> _performLoadMore(int ticket) async {
    emit(state.copyWith(isLoadingMore: true));

    try {
      final nextPage = _currentPage + 1;
      final response = await _service.fetchPopularMovies(page: nextPage);
      if (_superseded(ticket, _loadMoreTicket)) return;

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
      if (_superseded(ticket, _loadMoreTicket)) return;
    }

    emit(
      state.copyWith(
        movies: [for (final movie in _movies) MovieCard.from(movie)],
        isLoadingMore: false,
      ),
    );
  }

  /// True when a newer request has been issued, or the cubit is closed and
  /// emitting would throw.
  bool _superseded(int ticket, int latest) => _closed || ticket != latest;

  static void _noNavigation(int movieId) {}
}
