//
//  movies_list_state.dart
//

import 'package:flutter/foundation.dart';

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

  final List<MovieCard> movies;
  final bool isLoading;
  final bool isLoadingMore;
  final String? errorMessage;

  /// [errorMessage] is cleared unless a new one is passed — a fresh load or
  /// page always supersedes the previous failure.
  MoviesListState copyWith({
    List<MovieCard>? movies,
    bool? isLoading,
    bool? isLoadingMore,
    String? errorMessage,
  }) => MoviesListState(
    movies: movies ?? this.movies,
    isLoading: isLoading ?? this.isLoading,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    errorMessage: errorMessage,
  );

  @override
  bool operator ==(Object other) =>
      other is MoviesListState &&
      listEquals(other.movies, movies) &&
      other.isLoading == isLoading &&
      other.isLoadingMore == isLoadingMore &&
      other.errorMessage == errorMessage;

  @override
  int get hashCode =>
      Object.hash(Object.hashAll(movies), isLoading, isLoadingMore, errorMessage);
}
