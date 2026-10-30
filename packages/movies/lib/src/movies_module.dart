//
//  movies_module.dart
//

import 'package:get_it/get_it.dart';
import 'package:movies_data/movies_data.dart';

import 'details/details_cubit.dart';
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

  // One per movie, and one per visit — the details route owns and closes it,
  // so this is a factory rather than a singleton.
  getIt.registerFactoryParam<DetailsCubit, int, void>(
    (movieId, _) => DetailsCubit(
      movieId: movieId,
      service: getIt<MovieServicing>(),
      cache: getIt<MovieCache>(),
    ),
  );
}
