//
//  movie_navigator.dart
//

import 'package:get_it/get_it.dart';

import 'movie_details.dart';

/// Feature modules depend on this, never on the navigation module itself, so
/// `movies` and `search` stay independent of how the app is composed.
abstract interface class MovieNavigator {
  void navigate(MovieDetails movie);
}

final class NoopNavigator implements MovieNavigator {
  const NoopNavigator();

  @override
  void navigate(MovieDetails movie) {}
}

/// Registers the no-op navigator as the default. The navigation module
/// replaces the registration when the app starts.
void registerMoviesCore({GetIt? container}) {
  final getIt = container ?? GetIt.instance;
  if (!getIt.isRegistered<MovieNavigator>()) {
    getIt.registerLazySingleton<MovieNavigator>(NoopNavigator.new);
  }
}
