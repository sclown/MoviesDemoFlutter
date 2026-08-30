//
//  navigation.dart
//

import 'package:flutter/material.dart';
import 'package:movies/movies.dart';
import 'package:movies_data/movies_data.dart';

/// Lets [AppNavigator] push without a `BuildContext` of its own, so features
/// can navigate from a cubit rather than from a widget.
final navigatorKey = GlobalKey<NavigatorState>();

/// The app's implementation of the abstraction the features depend on. Only
/// this file knows that opening a movie means pushing [DetailsView] — the
/// feature modules stay unaware of each other and of the destinations.
final class AppNavigator implements MovieNavigator {
  const AppNavigator(this._cache);

  final MovieCache _cache;

  @override
  void navigate(int movieId) => navigatorKey.currentState?.push(
    MaterialPageRoute<void>(
      builder: (_) => DetailsView(movieId: movieId, cache: _cache),
    ),
  );
}
