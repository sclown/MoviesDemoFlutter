//
//  details_cubit.dart
//

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movies_data/movies_data.dart';

import 'details_state.dart';

/// Drives one details screen.
///
/// The cached entry the list or search screen left behind paints immediately;
/// the per-movie request then fills in genres, trailers and credits while the
/// screen is up, and the completed record goes back into the cache so a second
/// visit skips the request entirely.
///
/// An id that was never listed — a deep link opened from cold — has no cached
/// half, so the request becomes the only source and the screen waits on it.
class DetailsCubit extends Cubit<DetailsState> {
  DetailsCubit({
    required this.movieId,
    required MovieServicing service,
    required MovieCache cache,
    DetailsState? state,
  }) : _service = service,
       _cache = cache,
       super(state ?? const DetailsState.empty());

  final int movieId;
  final MovieServicing _service;
  final MovieCache _cache;

  var _hasLoaded = false;
  var _closed = false;

  @override
  Future<void> close() {
    _closed = true;
    return super.close();
  }

  void load() {
    if (_hasLoaded) return;
    _hasLoaded = true;

    final cached = _cache[movieId];

    // Already fetched on an earlier visit — the cache is the whole answer.
    if (cached != null && cached.isComplete) {
      emit(
        DetailsState(movie: cached, isEnriching: false, errorMessage: null),
      );
      return;
    }

    emit(DetailsState(movie: cached, isEnriching: true, errorMessage: null));
    _enrich();
  }

  Future<void> _enrich() async {
    try {
      final response = await _service.fetchMovie(id: movieId);
      if (_closed) return;

      // Prefer the cached half's fields where we have them: it is what the
      // screen is already showing, and swapping the title or poster underneath
      // the viewer mid-scroll would read as a glitch.
      final cached = state.movie;
      final enriched =
          cached?.withExtras(response.extras()) ?? response.details();

      _cache.put(enriched);
      emit(
        DetailsState(movie: enriched, isEnriching: false, errorMessage: null),
      );
    } catch (error) {
      if (_closed) return;

      // A failed enrichment must not take a usable screen down with it. With
      // cached content on screen the extra sections just stay absent; with
      // nothing on screen the error is all we have to show.
      emit(
        DetailsState(
          movie: state.movie,
          isEnriching: false,
          errorMessage: describeError(error),
        ),
      );
    }
  }
}
