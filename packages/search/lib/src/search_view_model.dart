//
//  search_view_model.dart
//

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:movies_api/movies_api.dart';
import 'package:movies_core/movies_core.dart';

import 'search_card.dart';
import 'search_state.dart';

abstract interface class SearchViewModeling {
  ValueNotifier<SearchState> get state;

  void updateSearchQuery(String query);

  void showDetails({required int movieId});
}

final class SearchViewModel implements SearchViewModeling {
  SearchViewModel({
    SearchState? state,
    required MovieServicing service,
    void Function(MovieDetails movie) navigation = _noNavigation,
    StateLogger<SearchState> logger = _noLogging,
    Duration debounce = const Duration(milliseconds: 500),
  }) : state = ValueNotifier(state ?? SearchState.empty()),
       _service = service,
       _navigation = navigation,
       _logger = logger,
       _debounce = debounce;

  @override
  final ValueNotifier<SearchState> state;

  final MovieServicing _service;
  final void Function(MovieDetails movie) _navigation;
  final StateLogger<SearchState> _logger;
  final Duration _debounce;

  List<Movie> _searchResults = [];
  _Cancellation? _searchToken;

  void dispose() {
    _searchToken?.cancel();
    state.dispose();
  }

  @override
  void updateSearchQuery(String query) {
    if (query == state.value.searchQuery) return;
    _debounceSearch(query);
  }

  @override
  void showDetails({required int movieId}) {
    for (final movie in _searchResults) {
      if (movie.id == movieId) {
        _navigation(movie.details());
        return;
      }
    }
  }

  void _debounceSearch(String query) {
    _searchToken?.cancel();

    if (query.isEmpty) {
      _searchResults = [];
      _updateState(
        searchResults: [],
        isSearching: false,
        searchQuery: '',
        showEmptyLabel: false,
      );
      return;
    }

    _updateState(isSearching: true, searchQuery: query, showEmptyLabel: false);

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
    } catch (_) {
      if (token.isCancelled) return;
      _searchResults = [];
    }

    _updateState(
      searchResults: [for (final movie in _searchResults) SearchCard.from(movie)],
      isSearching: false,
      searchQuery: query,
      showEmptyLabel: _searchResults.isEmpty && query.isNotEmpty,
    );
  }

  void _updateState({
    List<SearchCard>? searchResults,
    bool? isSearching,
    String? searchQuery,
    bool? showEmptyLabel,
  }) {
    final current = state.value;
    final next = SearchState(
      searchResults: searchResults ?? current.searchResults,
      isSearching: isSearching ?? current.isSearching,
      searchQuery: searchQuery ?? current.searchQuery,
      showEmptyLabel: showEmptyLabel ?? current.showEmptyLabel,
    );
    state.value = next;
    _logger(next);
  }

  static void _noNavigation(MovieDetails movie) {}

  static void _noLogging(SearchState state) {}
}

/// Marks a superseded search so it drops its result — see the note in
/// `MoviesViewModel`.
final class _Cancellation {
  bool isCancelled = false;

  void cancel() => isCancelled = true;
}
