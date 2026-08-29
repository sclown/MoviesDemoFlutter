//
//  movies_view.dart
//

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../l10n/generated/movies_localizations.dart';
import 'error_view.dart';
import 'loading_view.dart';
import 'movie_cell.dart';
import 'movies_list_state.dart';
import 'movies_cubit.dart';

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
  late final MoviesCubit _cubit = GetIt.instance<MoviesCubit>();

  @override
  void initState() {
    super.initState();
    _cubit.load();
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
            child: BlocBuilder<MoviesCubit, MoviesListState>(
              bloc: _cubit,
              builder: (context, state) => _content(state),
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
      return ErrorView(message: errorMessage, onRetry: _cubit.load);
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
            if (mounted) _cubit.loadMoreIfNeeded(currentMovieId: movie.id);
          });
        }
        return GestureDetector(
          onTap: () => _cubit.showDetails(movieId: movie.id),
          child: MovieCell(movie: movie),
        );
      },
    );
  }
}
