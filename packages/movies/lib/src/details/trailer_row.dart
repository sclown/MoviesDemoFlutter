//
//  trailer_row.dart
//

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:movies_data/movies_data.dart';

import '../l10n/generated/movies_localizations.dart';

/// A horizontally scrolling strip of trailer stills. Tapping one hands the
/// video's URL to [onPlay], which the app wires to the platform's browser or
/// YouTube app — the module itself stays free of a launcher dependency.
class TrailerRow extends StatelessWidget {
  const TrailerRow({required this.trailers, required this.onPlay, super.key});

  final List<MovieTrailer> trailers;
  final void Function(Uri url) onPlay;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 148,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: trailers.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) =>
            _Trailer(trailer: trailers[index], onPlay: onPlay),
      ),
    );
  }
}

class _Trailer extends StatelessWidget {
  const _Trailer({required this.trailer, required this.onPlay});

  final MovieTrailer trailer;
  final void Function(Uri url) onPlay;

  @override
  Widget build(BuildContext context) {
    final l10n = MoviesLocalizations.of(context);
    final theme = Theme.of(context);

    return Semantics(
      identifier: 'trailer-${trailer.name}',
      label: l10n.playTrailer(trailer.name),
      button: true,
      child: ExcludeSemantics(
        child: SizedBox(
          width: 220,
          child: InkWell(
            onTap: () => onPlay(trailer.url),
            borderRadius: BorderRadius.circular(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      AspectRatio(
                        aspectRatio: 16 / 9,
                        child: ColoredBox(
                          color: theme.colorScheme.surfaceContainerHighest,
                          child: CachedNetworkImage(
                            imageUrl: trailer.thumbnail.toString(),
                            fit: BoxFit.cover,
                            errorWidget: (context, _, _) =>
                                const SizedBox.shrink(),
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.play_circle_fill,
                        size: 44,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  trailer.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
