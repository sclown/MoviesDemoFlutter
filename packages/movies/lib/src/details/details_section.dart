//
//  details_section.dart
//

import 'package:flutter/material.dart';

/// A titled block on the details screen. The title sits inside the horizontal
/// padding while [child] is free to bleed to both edges, which is what a
/// horizontally scrolling row needs.
class DetailsSection extends StatelessWidget {
  const DetailsSection({
    required this.title,
    required this.child,
    super.key,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        child,
        const SizedBox(height: 24),
      ],
    );
  }
}
