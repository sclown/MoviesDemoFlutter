//
//  movies_module.dart
//

import 'package:get_it/get_it.dart';
import 'package:movies_data/movies_data.dart';

import 'list/movies_cubit.dart';

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
