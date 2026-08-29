//
//  movies_module.dart
//

import 'package:get_it/get_it.dart';
import 'package:movies_api/movies_api.dart';
import 'package:movies_core/movies_core.dart';

import 'list/movies_cubit.dart';

/// Wires the module's cubit. Registration is skipped when something has
/// already registered a [MoviesCubit] — that is how tests and the golden-test
/// harness substitute a stub.
void registerMovies({GetIt? container}) {
  final getIt = container ?? GetIt.instance;
  if (getIt.isRegistered<MoviesCubit>()) return;

  getIt.registerLazySingleton<MoviesCubit>(
    () => MoviesCubit(
      service: getIt<MovieServicing>(),
      cache: getIt<MovieCache>(),
      navigation: (id) => getIt<MovieNavigator>().navigate(id),
    ),
  );
}
