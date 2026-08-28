//
//  movies_module.dart
//

import 'package:get_it/get_it.dart';
import 'package:movies_api/movies_api.dart';
import 'package:movies_core/movies_core.dart';

import 'list/movies_view_model.dart';

/// Wires the module's view model. Registration is skipped when something has
/// already registered a [MoviesViewModeling] — that is how tests and the
/// golden-test harness substitute a stub.
void registerMovies({GetIt? container}) {
  final getIt = container ?? GetIt.instance;
  if (getIt.isRegistered<MoviesViewModeling>()) return;

  getIt.registerLazySingleton<MoviesViewModeling>(
    () => MoviesViewModel(
      service: getIt<MovieServicing>(),
      navigation: (movie) => getIt<MovieNavigator>().navigate(movie),
    ),
  );
}
