//
//  movie_cell.dart
//

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'movie_card.dart';

class MovieCell extends StatelessWidget {
  const MovieCell({required this.movie, super.key});

  final MovieCard movie;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: AspectRatio(
        aspectRatio: 2 / 3,
        child: ColoredBox(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: movie.poster == null
              ? _title(context)
              : CachedNetworkImage(
                  imageUrl: movie.poster!.toString(),
                  fit: BoxFit.cover,
                  imageBuilder: (context, imageProvider) => Semantics(
                    label: movie.title,
                    image: true,
                    child: Image(image: imageProvider, fit: BoxFit.cover),
                  ),
                  placeholder: (context, _) => _title(context),
                  errorWidget: (context, _, _) => _title(context),
                ),
        ),
      ),
    );
  }

  Widget _title(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Text(
          movie.title,
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
