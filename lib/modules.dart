//
//  modules.dart
//

import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:movies/movies.dart';
import 'package:movies_api/movies_api.dart';
import 'package:movies_core/movies_core.dart';
import 'package:network_service/network_service.dart';
import 'package:search/search.dart';

import 'navigation.dart';

/// Composes the whole graph, bottom up. The app is the only place that knows
/// every module exists — the features only know the abstractions in
/// `movies_core`.
void registerModules({GetIt? container}) {
  final getIt = container ?? GetIt.instance;

  registerNetworkService(container: getIt);
  registerMoviesApi(container: getIt, language: currentLanguageTag);

  if (!getIt.isRegistered<MovieCache>()) {
    getIt.registerLazySingleton<MovieCache>(MovieCache.new);
  }
  if (!getIt.isRegistered<MovieNavigator>()) {
    getIt.registerLazySingleton<MovieNavigator>(AppNavigator.new);
  }

  registerMovies(container: getIt);
  registerSearch(container: getIt);
}

/// The language TMDB should answer in: the same locale `MaterialApp` resolves
/// the UI to, so titles and overviews match the chrome around them.
String currentLanguageTag() {
  final resolved = basicLocaleListResolution(
    WidgetsBinding.instance.platformDispatcher.locales,
    MoviesLocalizations.supportedLocales,
  );
  return resolved.toLanguageTag();
}
