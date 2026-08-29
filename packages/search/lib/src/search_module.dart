//
//  search_module.dart
//

import 'package:get_it/get_it.dart';
import 'package:movies_api/movies_api.dart';
import 'package:movies_core/movies_core.dart';

import 'search_cubit.dart';

/// Wires the module's cubit, leaving an existing registration alone so tests
/// and goldens can substitute a stub.
void registerSearch({GetIt? container}) {
  final getIt = container ?? GetIt.instance;
  if (getIt.isRegistered<SearchCubit>()) return;

  getIt.registerLazySingleton<SearchCubit>(
    () => SearchCubit(
      service: getIt<MovieServicing>(),
      cache: getIt<MovieCache>(),
      navigation: (id) => getIt<MovieNavigator>().navigate(id),
    ),
  );
}
