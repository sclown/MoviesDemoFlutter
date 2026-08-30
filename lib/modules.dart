//
//  modules.dart
//

import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:movies/movies.dart';
import 'package:movies_data/movies_data.dart';
import 'package:network_service/network_service.dart';
import 'package:search/search.dart';

import 'navigation.dart';

void registerModules({GetIt? container}) {
  final getIt = container ?? GetIt.instance;

  registerNetworkService(container: getIt);
  registerMoviesApi(container: getIt, language: currentLanguageTag);

  if (!getIt.isRegistered<MovieCache>()) {
    getIt.registerLazySingleton<MovieCache>(MovieCache.new);
  }
  if (!getIt.isRegistered<MovieNavigator>()) {
    getIt.registerLazySingleton<MovieNavigator>(
      () => AppNavigator(getIt<MovieCache>()),
    );
  }

  registerMovies(container: getIt);
  registerSearch(container: getIt);
}

String currentLanguageTag() {
  final resolved = basicLocaleListResolution(
    WidgetsBinding.instance.platformDispatcher.locales,
    MoviesLocalizations.supportedLocales,
  );
  return resolved.toLanguageTag();
}
