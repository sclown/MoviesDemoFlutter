//
//  fixtures.dart — canned states for the widget and golden tests
//

import 'package:search/src/search_card.dart';
import 'package:search/src/search_state.dart';

SearchCard searchCard({required int id}) => SearchCard(
  id: id,
  title: 'Test movie $id',
  rating: '7.5',
  releaseDate: '2025-06-15',
  poster: null,
);

SearchState searchingState() => const SearchState(
  searchResults: [],
  isSearching: true,
  searchQuery: 'Batman',
  showEmptyLabel: false,
);

SearchState noResultsState() => const SearchState(
  searchResults: [],
  isSearching: false,
  searchQuery: 'xyzzy',
  showEmptyLabel: true,
);

SearchState resultsState(int count) => SearchState(
  searchResults: [for (var id = 1; id <= count; id++) searchCard(id: id)],
  isSearching: false,
  searchQuery: 'Movie',
  showEmptyLabel: false,
);

SearchState failedState() => const SearchState(
  searchResults: [],
  isSearching: false,
  searchQuery: 'Batman',
  showEmptyLabel: false,
  errorMessage: 'No internet connection. Please check your network settings.',
);
