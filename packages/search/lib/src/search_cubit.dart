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
    void Function(MovieDetails movie) navigation = _noNavigation,
    Duration debounce = const Duration(milliseconds: 500),
  }) : _service = service,
       _navigation = navigation,
       _debounce = debounce,
       super(state ?? SearchState.empty());

  final MovieServicing _service;
  final void Function(MovieDetails movie) _navigation;
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

  static void _noNavigation(MovieDetails movie) {}
}

/// Marks a superseded search so it drops its result — see the note in
/// `MoviesCubit`.
final class _Cancellation {
  bool isCancelled = false;

  void cancel() => isCancelled = true;
}
