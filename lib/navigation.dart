//
//  navigation.dart
//

import 'package:flutter/material.dart';
import 'package:movies/movies.dart';
import 'package:movies_data/movies_data.dart';

final navigatorKey = GlobalKey<NavigatorState>();

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
