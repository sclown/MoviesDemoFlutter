//
//  person_row.dart
//

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:movies_data/movies_data.dart';

/// A horizontally scrolling strip of people — the cast with the characters
/// they play, or the crew with the jobs they did.
class PersonRow extends StatelessWidget {
  const PersonRow({
    required this.people,
    required this.identifier,
    super.key,
  });

  final List<MoviePerson> people;

  /// Distinguishes the cast strip from the crew strip for assistive tech and
  /// for the integration tests.
  final String identifier;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 176,
      child: Semantics(
        identifier: identifier,
        container: true,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: people.length,
          separatorBuilder: (_, _) => const SizedBox(width: 12),
          itemBuilder: (context, index) => _Person(person: people[index]),
        ),
      ),
    );
  }
}

class _Person extends StatelessWidget {
  const _Person({required this.person});

  final MoviePerson person;

  static const _photoSize = 96.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: _photoSize,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipOval(child: _photo(context)),
          const SizedBox(height: 8),
          Text(
            person.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          if (person.role.isNotEmpty)
            Text(
              person.role,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
        ],
      ),
    );
  }

  Widget _photo(BuildContext context) {
    final theme = Theme.of(context);
    final photo = person.photo;

    final fallback = SizedBox(
      width: _photoSize,
      height: _photoSize,
      child: ColoredBox(
        color: theme.colorScheme.surfaceContainerHighest,
        child: Center(
          child: Icon(
            Icons.person,
            color: theme.colorScheme.onSurfaceVariant,
            size: 36,
          ),
        ),
      ),
    );

    if (photo == null) return fallback;

    return CachedNetworkImage(
      imageUrl: photo.toString(),
      width: _photoSize,
      height: _photoSize,
      fit: BoxFit.cover,
      placeholder: (context, _) => fallback,
      errorWidget: (context, _, _) => fallback,
    );
  }
}
