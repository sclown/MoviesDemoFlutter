//
//  details_view.dart
//

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movies_data/movies_data.dart';

import '../delayed_progress_indicator.dart';
import '../l10n/generated/movies_localizations.dart';
import 'details_cubit.dart';
import 'details_section.dart';
import 'details_state.dart';
import 'genre_tags.dart';
import 'key_crew.dart';
import 'person_row.dart';
import 'trailer_row.dart';

/// The details screen for one movie.
///
/// Paints whatever the cache already holds, then fills in genres, trailers and
/// credits as the per-movie request lands. [onPlayTrailer] receives a video's
/// URL when the viewer taps it; leaving it out makes the trailers inert, which
/// is what the widget tests want.
///
/// The cubit is per-route and per-movie, so this view owns it and closes it.
class DetailsView extends StatefulWidget {
  const DetailsView({
    required this.cubit,
    this.onPlayTrailer,
    super.key,
  });

  final DetailsCubit cubit;
  final void Function(Uri url)? onPlayTrailer;

  @override
  State<DetailsView> createState() => _DetailsViewState();
}

class _DetailsViewState extends State<DetailsView> {
  @override
  void initState() {
    super.initState();
    widget.cubit.load();
  }

  @override
  void dispose() {
    widget.cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      identifier: 'detailsScreen',
      explicitChildNodes: true,
      child: BlocBuilder<DetailsCubit, DetailsState>(
        bloc: widget.cubit,
        builder: (context, state) {
          final movie = state.movie;
          if (movie == null) {
            return state.isEnriching
                ? const _LoadingView()
                : const _UnavailableView();
          }
          return _DetailsContent(
            movie: movie,
            isEnriching: state.isEnriching,
            onPlayTrailer: widget.onPlayTrailer,
          );
        },
      ),
    );
  }
}

/// Nothing cached and the request still in flight — a link opened from cold.
class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true),
      body: const Center(
        child: DelayedProgressIndicator(identifier: 'detailsSpinner'),
      ),
    );
  }
}

class _UnavailableView extends StatelessWidget {
  const _UnavailableView();

  @override
  Widget build(BuildContext context) {
    final l10n = MoviesLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(centerTitle: true),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.movie_outlined,
                size: 52,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.movieUnavailable,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailsContent extends StatelessWidget {
  const _DetailsContent({
    required this.movie,
    required this.isEnriching,
    required this.onPlayTrailer,
  });

  final MovieDetails movie;
  final bool isEnriching;
  final void Function(Uri url)? onPlayTrailer;

  @override
  Widget build(BuildContext context) {
    final l10n = MoviesLocalizations.of(context);
    final theme = Theme.of(context);
    final releaseDate = movie.releaseDate;
    final extras = movie.extras;

    return Scaffold(
      appBar: AppBar(title: Text(movie.title), centerTitle: true),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              label: l10n.moviePoster,
              image: true,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _poster(context),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Semantics(
                    label: l10n.rating,
                    value: movie.rating,
                    child: ExcludeSemantics(
                      child: Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 22),
                          const SizedBox(width: 4),
                          Text(
                            movie.rating,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (releaseDate != null && releaseDate.isNotEmpty) ...[
                    Text(
                      l10n.releaseDate(releaseDate),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.75),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  if (extras != null && extras.genres.isNotEmpty) ...[
                    GenreTags(genres: extras.genres),
                    const SizedBox(height: 12),
                  ],
                  Text(movie.overview, style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 24),
                ],
              ),
            ),
            if (isEnriching)
              const SizedBox(
                height: 72,
                child: DelayedProgressIndicator(identifier: 'detailsSpinner'),
              ),
            if (extras != null) ..._sections(context, extras),
          ],
        ),
      ),
    );
  }

  List<Widget> _sections(BuildContext context, MovieExtras extras) {
    final l10n = MoviesLocalizations.of(context);
    final crew = keyCrew(extras.crew);

    return [
      if (extras.trailers.isNotEmpty)
        DetailsSection(
          title: l10n.trailers,
          child: TrailerRow(
            trailers: extras.trailers,
            onPlay: onPlayTrailer ?? (_) {},
          ),
        ),
      if (extras.cast.isNotEmpty)
        DetailsSection(
          title: l10n.cast,
          child: PersonRow(people: extras.cast, identifier: 'castRow'),
        ),
      if (crew.isNotEmpty)
        DetailsSection(
          title: l10n.crew,
          child: PersonRow(people: crew, identifier: 'crewRow'),
        ),
    ];
  }

  Widget _poster(BuildContext context) {
    final poster = movie.poster;
    if (poster == null) return _placeholder(context);

    return CachedNetworkImage(
      imageUrl: poster.toString(),
      fit: BoxFit.fitWidth,
      width: double.infinity,
      placeholder: (context, _) => _placeholder(context),
      errorWidget: (context, _, _) => _placeholder(context),
    );
  }

  Widget _placeholder(BuildContext context) {
    return AspectRatio(
      aspectRatio: 2 / 3,
      child: ColoredBox(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
