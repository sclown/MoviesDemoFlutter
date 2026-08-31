//
//  search_error_view.dart
//

import 'package:flutter/material.dart';

import 'l10n/generated/search_localizations.dart';

class SearchErrorView extends StatelessWidget {
  const SearchErrorView({required this.message, super.key});

  final String message;

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
            Icons.wifi_off_rounded,
            size: 34,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 8),
          Text(l10n.searchFailed, style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
