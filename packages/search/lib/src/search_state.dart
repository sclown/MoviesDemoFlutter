//
//  search_state.dart
//

import 'search_card.dart';

final class SearchState {
  const SearchState({
    required this.searchResults,
    required this.isSearching,
    required this.searchQuery,
    required this.showEmptyLabel,
  });

  factory SearchState.empty() => const SearchState(
    searchResults: [],
    isSearching: false,
    searchQuery: '',
    showEmptyLabel: false,
  );

  factory SearchState.searching() => const SearchState(
    searchResults: [],
    isSearching: true,
    searchQuery: 'Batman',
    showEmptyLabel: false,
  );

  factory SearchState.noResults() => const SearchState(
    searchResults: [],
    isSearching: false,
    searchQuery: 'xyzzy',
    showEmptyLabel: true,
  );

  factory SearchState.mockResults(int count) => SearchState(
    searchResults: [
      for (var id = 1; id <= count; id++) SearchCard.mockWith(id: id),
    ],
    isSearching: false,
    searchQuery: 'Movie',
    showEmptyLabel: false,
  );

  final List<SearchCard> searchResults;
  final bool isSearching;
  final String searchQuery;
  final bool showEmptyLabel;
}
