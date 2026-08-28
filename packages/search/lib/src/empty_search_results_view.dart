//
//  empty_search_results_view.dart
//

import 'package:flutter/material.dart';

import 'l10n/generated/search_localizations.dart';

class EmptySearchResultsView extends StatelessWidget {
  const EmptySearchResultsView({required this.query, super.key});

  final String query;

  @override
  Widget build(BuildContext context) {
    final l10n = SearchLocalizations.of(context);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search,
            size: 34,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 8),
          Text(l10n.noResultsFor(query), style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          Text(
            l10n.tryDifferentTerm,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
