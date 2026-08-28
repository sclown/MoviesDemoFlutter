//
//  search_bar.dart
//

import 'dart:ui';

import 'package:flutter/material.dart';

import 'l10n/generated/search_localizations.dart';

/// The floating capsule search field pinned to the bottom of the screen.
class MovieSearchBar extends StatelessWidget {
  const MovieSearchBar({
    required this.controller,
    required this.focusNode,
    required this.onClear,
    super.key,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final l10n = SearchLocalizations.of(context);
    final theme = Theme.of(context);
    final hintColor = Colors.white.withValues(alpha: 0.65);

    return Semantics(
      textField: true,
      label: l10n.searchMovies,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: Colors.white, width: 0.5),
            ),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: ExcludeSemantics(
                    child: Icon(Icons.search, size: 16, color: hintColor),
                  ),
                ),
                Expanded(
                  child: Semantics(
                    identifier: 'searchField',
                    child: TextField(
                      controller: controller,
                      focusNode: focusNode,
                      textInputAction: TextInputAction.search,
                      style: theme.textTheme.bodyMedium,
                      cursorColor: Colors.white,
                      decoration: InputDecoration(
                        isDense: true,
                        border: InputBorder.none,
                        hintText: l10n.search,
                        hintStyle: theme.textTheme.bodyMedium?.copyWith(
                          color: hintColor,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ),
                ),
                ValueListenableBuilder(
                  valueListenable: controller,
                  builder: (context, value, _) => value.text.isEmpty
                      ? const SizedBox(width: 12)
                      : Semantics(
                          identifier: 'clearSearchButton',
                          child: IconButton(
                            onPressed: onClear,
                            iconSize: 18,
                            color: Colors.white,
                            visualDensity: VisualDensity.compact,
                            icon: Icon(
                              Icons.cancel,
                              semanticLabel: l10n.clearSearch,
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
