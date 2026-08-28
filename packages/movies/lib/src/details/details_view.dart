//
//  details_view.dart
//

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:movies_core/movies_core.dart';

import '../l10n/generated/movies_localizations.dart';

class DetailsView extends StatelessWidget {
  const DetailsView({required this.movie, super.key});

  final MovieDetails movie;

  @override
  Widget build(BuildContext context) {
    final l10n = MoviesLocalizations.of(context);
    final theme = Theme.of(context);
    final releaseDate = movie.releaseDate;

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
                  Text(movie.overview, style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
