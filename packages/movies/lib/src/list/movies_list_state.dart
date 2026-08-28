//
//  movies_list_state.dart
//

import 'movie_card.dart';

final class MoviesListState {
  const MoviesListState({
    required this.movies,
    required this.isLoading,
    required this.isLoadingMore,
    required this.errorMessage,
  });

  /// The initial state: loading, with nothing to show yet.
  factory MoviesListState.empty() => const MoviesListState(
    movies: [],
    isLoading: true,
    isLoadingMore: false,
    errorMessage: null,
  );

  factory MoviesListState.error() => const MoviesListState(
    movies: [],
    isLoading: false,
    isLoadingMore: false,
    errorMessage: 'Some error message',
  );

  /// A grid of [count] placeholder movies, for the widget and golden tests.
  factory MoviesListState.mockMovies(int count) => MoviesListState(
    movies: [
      for (var id = 1; id <= count; id++) MovieCard.mockWith(id: id),
    ],
    isLoading: false,
    isLoadingMore: false,
    errorMessage: null,
  );

  final List<MovieCard> movies;
  final bool isLoading;
  final bool isLoadingMore;
  final String? errorMessage;
}
