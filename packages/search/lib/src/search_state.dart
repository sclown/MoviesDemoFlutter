//
//  search_state.dart
//

import 'package:flutter/foundation.dart';

import 'search_card.dart';

final class SearchState {
  const SearchState({
    required this.searchResults,
    required this.isSearching,
    required this.searchQuery,
    required this.showEmptyLabel,
    this.errorMessage,
  });

  factory SearchState.empty() => const SearchState(
    searchResults: [],
    isSearching: false,
    searchQuery: '',
    showEmptyLabel: false,
  );

  final List<SearchCard> searchResults;
  final bool isSearching;
  final String searchQuery;
  final bool showEmptyLabel;

  final String? errorMessage;

  SearchState copyWith({
    List<SearchCard>? searchResults,
    bool? isSearching,
    String? searchQuery,
    bool? showEmptyLabel,
    String? errorMessage,
  }) => SearchState(
    searchResults: searchResults ?? this.searchResults,
    isSearching: isSearching ?? this.isSearching,
    searchQuery: searchQuery ?? this.searchQuery,
    showEmptyLabel: showEmptyLabel ?? this.showEmptyLabel,
    errorMessage: errorMessage,
  );

  @override
  bool operator ==(Object other) =>
      other is SearchState &&
      listEquals(other.searchResults, searchResults) &&
      other.isSearching == isSearching &&
      other.searchQuery == searchQuery &&
      other.showEmptyLabel == showEmptyLabel &&
      other.errorMessage == errorMessage;

  @override
  int get hashCode => Object.hash(
    Object.hashAll(searchResults),
    isSearching,
    searchQuery,
    showEmptyLabel,
    errorMessage,
  );
}
