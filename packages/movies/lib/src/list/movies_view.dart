//
//  movies_view.dart
//

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../l10n/generated/movies_localizations.dart';
import 'error_view.dart';
import 'loading_view.dart';
import 'delayed_progress_indicator.dart';
import 'movie_cell.dart';
import 'movies_list_state.dart';
import 'movies_cubit.dart';

class MoviesView extends StatefulWidget {
  const MoviesView({required this.cubit, this.overlay, super.key});

  final MoviesCubit cubit;
  final Widget? overlay;

  @override
  State<MoviesView> createState() => _MoviesViewState();
}

class _MoviesViewState extends State<MoviesView> {
  @override
  void initState() {
    super.initState();
    widget.cubit.load();
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
              bloc: widget.cubit,
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
      return ErrorView(message: errorMessage, onRetry: widget.cubit.load);
    }

    return _movieGrid(state);
  }

  Widget _movieGrid(MoviesListState state) {
    return Semantics(
      identifier: 'moviesGrid',
      explicitChildNodes: true,
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            sliver: SliverGrid.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 2 / 3,
              ),
              itemCount: state.movies.length,
              itemBuilder: (context, index) {
                final movie = state.movies[index];
                if (index == state.movies.length - 1) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      widget.cubit.loadMoreIfNeeded(currentMovieId: movie.id);
                    }
                  });
                }
                return Semantics(
                  button: true,
                  label: movie.title,
                  identifier: 'movieCell-${movie.id}',
                  excludeSemantics: true,
                  child: GestureDetector(
                    onTap: () => widget.cubit.showDetails(movieId: movie.id),
                    child: MovieCell(movie: movie),
                  ),
                );
              },
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 72,
              child: state.isLoadingMore
                  ? const DelayedProgressIndicator()
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
