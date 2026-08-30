//
//  search_cubit.dart
//

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movies_data/movies_data.dart';

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

  /// Cancelled and restarted on every keystroke, so only the pause at the end
  /// of typing ever spends a request.
  Timer? _debounceTimer;

  // Dart futures cannot be cancelled, so each request takes a ticket on the
  // way out and drops its result if a newer one has been issued since.
  var _searchTicket = 0;
  var _closed = false;

  @override
  Future<void> close() {
    _closed = true;
    _debounceTimer?.cancel();
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
    _debounceTimer?.cancel();
    _searchTicket++;

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

    final ticket = _searchTicket;
    _debounceTimer = Timer(_debounce, () => _performSearch(query, ticket));
  }

  Future<void> _performSearch(String query, int ticket) async {
    String? errorMessage;
    try {
      final response = await _service.searchMovies(query: query);
      if (_superseded(ticket)) return;
      _searchResults = response.results;
      // The details screen reads from the cache, so results have to land there
      // before a tap can open one.
      _cache.putAll([for (final movie in _searchResults) movie.details()]);
    } catch (error) {
      if (_superseded(ticket)) return;
      _searchResults = [];
      errorMessage = describeError(error);
    }

    emit(
      state.copyWith(
        searchResults: [
          for (final movie in _searchResults) SearchCard.from(movie),
        ],
        isSearching: false,
        searchQuery: query,
        // "found nothing" only when the search actually succeeded.
        showEmptyLabel:
            errorMessage == null && _searchResults.isEmpty && query.isNotEmpty,
        errorMessage: errorMessage,
      ),
    );
  }

  /// True when a newer query has been issued, or the cubit is closed and
  /// emitting would throw.
  bool _superseded(int ticket) => _closed || ticket != _searchTicket;

  static void _noNavigation(int movieId) {}
}

