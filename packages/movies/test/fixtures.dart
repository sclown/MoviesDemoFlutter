//
//  fixtures.dart — canned states for the widget and golden tests
//

import 'package:movies/src/list/movie_card.dart';
import 'package:movies/src/list/movies_list_state.dart';

MovieCard movieCard({required int id}) =>
    MovieCard(id: id, title: 'Movie title $id', poster: null);

MoviesListState loadedState(int count) => MoviesListState(
  movies: [for (var id = 1; id <= count; id++) movieCard(id: id)],
  isLoading: false,
  isLoadingMore: false,
  errorMessage: null,
);

MoviesListState loadingMoreState(int count) => MoviesListState(
  movies: [for (var id = 1; id <= count; id++) movieCard(id: id)],
  isLoading: false,
  isLoadingMore: true,
  errorMessage: null,
);

MoviesListState errorState() => const MoviesListState(
  movies: [],
  isLoading: false,
  isLoadingMore: false,
  errorMessage: 'Some error message',
);
