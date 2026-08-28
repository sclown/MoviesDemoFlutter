//
//  search_result_row.dart
//

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'search_card.dart';

class SearchResultRow extends StatelessWidget {
  const SearchResultRow({required this.movie, super.key});

  final SearchCard movie;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtitleColor = Colors.white.withValues(alpha: 0.75);
    final releaseDate = movie.releaseDate;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(width: 36, height: 54, child: _poster(context)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movie.title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 12),
                    const SizedBox(width: 4),
                    Text(
                      movie.rating,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: subtitleColor,
                      ),
                    ),
                    if (releaseDate != null) ...[
                      const SizedBox(width: 12),
                      Text(
                        releaseDate,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: subtitleColor,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _poster(BuildContext context) {
    final poster = movie.poster;
    if (poster == null) return _placeholder(context);

    return CachedNetworkImage(
      imageUrl: poster.toString(),
      fit: BoxFit.cover,
      placeholder: (context, _) => _placeholder(context),
      errorWidget: (context, _, _) => _placeholder(context),
    );
  }

  Widget _placeholder(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Center(
        child: Icon(
          Icons.movie,
          size: 14,
          color: Colors.white.withValues(alpha: 0.75),
        ),
      ),
    );
  }
}
