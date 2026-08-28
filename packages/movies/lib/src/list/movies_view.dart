//
//  movies_view.dart
//

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../l10n/generated/movies_localizations.dart';
import 'error_view.dart';
import 'loading_view.dart';
import 'movie_cell.dart';
import 'movies_list_state.dart';
import 'movies_view_model.dart';

/// The popular-movies screen: a two-column poster grid that pages as it is
/// scrolled. [overlay] lets the composing module stack the search UI on top
/// without this module knowing about it.
class MoviesView extends StatefulWidget {
  const MoviesView({this.overlay, super.key});

  final Widget? overlay;

  @override
  State<MoviesView> createState() => _MoviesViewState();
}

class _MoviesViewState extends State<MoviesView> {
  late final MoviesViewModeling _viewModel = GetIt.instance<MoviesViewModeling>();

  @override
  void initState() {
    super.initState();
    _viewModel.load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(MoviesLocalizations.of(context).popularMovies),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: ListenableBuilder(
              listenable: _viewModel.state,
              builder: (context, _) => _content(_viewModel.state.value),
            ),
          ),
          if (widget.overlay != null) Positioned.fill(child: widget.overlay!),
        ],
      ),
    );
  }

  Widget _content(MoviesListState state) {
    if (state.isLoading) return const LoadingView();

    final errorMessage = state.errorMessage;
    if (errorMessage != null) {
      return ErrorView(message: errorMessage, onRetry: _viewModel.load);
    }

    return _movieGrid(state);
  }

  Widget _movieGrid(MoviesListState state) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 72),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 2 / 3,
      ),
      itemCount: state.movies.length,
      itemBuilder: (context, index) {
        final movie = state.movies[index];
        // Building the last cell is the "user reached the bottom" signal.
        // The request waits for the frame to end: publishing new state from
        // inside a build is not allowed.
        if (index == state.movies.length - 1) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _viewModel.loadMoreIfNeeded(currentMovieId: movie.id);
          });
        }
        return GestureDetector(
          onTap: () => _viewModel.showDetails(movieId: movie.id),
          child: MovieCell(movie: movie),
        );
      },
    );
  }
}
