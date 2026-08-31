//
//  loading_view.dart
//

import 'package:flutter/material.dart';

import '../l10n/generated/movies_localizations.dart';

class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      identifier: 'loadingView',
      child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 12),
            Text(MoviesLocalizations.of(context).loadingMovies),
          ],
        ),
      ),
    );
  }
}
