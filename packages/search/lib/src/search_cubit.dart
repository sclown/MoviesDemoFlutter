//
//  search_cubit.dart
//

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movies_api/movies_api.dart';
import 'package:movies_core/movies_core.dart';

import 'search_card.dart';
import 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  SearchCubit({
    SearchState? state,
    required MovieServicing service,
    required MovieCache cache,
    void Function(int movieId) navigation = _noNavigation,
    Duration debounce = const Duration(milliseconds: 500),
  }) : _service = service,
       _cache = cache,
       _navigation = navigation,
       _debounce = debounce,
       super(state ?? SearchState.empty());

  final MovieServicing _service;
  final MovieCache _cache;
  final void Function(int movieId) _navigation;
  final Duration _debounce;

  List<Movie> _searchResults = [];
  _Cancellation? _searchToken;

  @override
  Future<void> close() {
    _searchToken?.cancel();
    return super.close();
  }

  void updateSearchQuery(String query) {
    if (query == state.searchQuery) return;
    _debounceSearch(query);
  }

  void showDetails({required int movieId}) {
    if (_cache.contains(movieId)) _navigation(movieId);
  }

  void _debounceSearch(String query) {
    _searchToken?.cancel();

    if (query.isEmpty) {
      _searchResults = [];
      emit(
        state.copyWith(
          searchResults: [],
          isSearching: false,
          searchQuery: '',
          showEmptyLabel: false,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        isSearching: true,
        searchQuery: query,
        showEmptyLabel: false,
      ),
    );

    final token = _Cancellation();
    _searchToken = token;
    _performSearch(query: query, token: token);
  }

  Future<void> _performSearch({
    required String query,
    required _Cancellation token,
  }) async {
    try {
      // Keystrokes land faster than requests should: wait out the typing
      // before spending a request, and drop the result if a newer query won.
      await Future<void>.delayed(_debounce);
      if (token.isCancelled) return;
      final response = await _service.searchMovies(query: query);
      if (token.isCancelled) return;
      _searchResults = response.results;
      // The details screen reads from the cache, so results have to land there
      // before a tap can open one.
      _cache.putAll([for (final movie in _searchResults) movie.details()]);
    } catch (_) {
      if (token.isCancelled) return;
      _searchResults = [];
    }

    emit(
      state.copyWith(
        searchResults: [
          for (final movie in _searchResults) SearchCard.from(movie),
        ],
        isSearching: false,
        searchQuery: query,
        showEmptyLabel: _searchResults.isEmpty && query.isNotEmpty,
      ),
    );
  }

  static void _noNavigation(int movieId) {}
}

/// Marks a superseded search so it drops its result — see the note in
/// `MoviesCubit`.
final class _Cancellation {
  bool isCancelled = false;

  void cancel() => isCancelled = true;
}
