//
//  details_state.dart
//

import 'package:movies_data/movies_data.dart';

/// What the details screen is showing.
///
/// [movie] is non-null as soon as there is anything to paint, whether that is
/// the cached half or the whole record. [isEnriching] rides alongside it, so
/// the screen shows real content and a spinner for the parts still in flight
/// at the same time.
class DetailsState {
  const DetailsState({
    required this.movie,
    required this.isEnriching,
    required this.errorMessage,
  });

  const DetailsState.empty()
    : movie = null,
      isEnriching = false,
      errorMessage = null;

  final MovieDetails? movie;
  final bool isEnriching;
  final String? errorMessage;

  /// Nothing to paint and nothing on the way — the id was never listed and
  /// the fetch could not find it either.
  bool get isUnavailable =>
      movie == null && !isEnriching && errorMessage != null;

  DetailsState copyWith({
    MovieDetails? movie,
    bool? isEnriching,
    String? errorMessage,
  }) => DetailsState(
    movie: movie ?? this.movie,
    isEnriching: isEnriching ?? this.isEnriching,
    errorMessage: errorMessage,
  );

  @override
  bool operator ==(Object other) =>
      other is DetailsState &&
      other.movie == movie &&
      other.isEnriching == isEnriching &&
      other.errorMessage == errorMessage;

  @override
  int get hashCode => Object.hash(movie, isEnriching, errorMessage);
}
