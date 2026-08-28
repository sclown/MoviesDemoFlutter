//
//  module.dart
//

import 'package:get_it/get_it.dart';
import 'package:movies/movies.dart';
import 'package:movies_api/movies_api.dart';
import 'package:movies_core/movies_core.dart';
import 'package:network_service/network_service.dart';
import 'package:search/search.dart';

import 'main_view_model.dart';

/// Composes the whole graph, bottom up. The navigation module is the only
/// place that knows every module exists — the features only know the
/// abstractions in `movies_core`.
void registerModules({GetIt? container}) {
  final getIt = container ?? GetIt.instance;

  registerNetworkService(container: getIt);
  registerMoviesApi(container: getIt);

  if (!getIt.isRegistered<MainViewModel>()) {
    getIt.registerLazySingleton<MainViewModel>(MainViewModel.new);
  }
  // The real navigator replaces `movies_core`'s no-op default.
  if (!getIt.isRegistered<MovieNavigator>()) {
    getIt.registerLazySingleton<MovieNavigator>(() => getIt<MainViewModel>());
  }

  registerMovies(container: getIt);
  registerSearch(container: getIt);
}
