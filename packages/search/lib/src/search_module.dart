//
//  search_module.dart
//

import 'package:get_it/get_it.dart';
import 'package:movies_data/movies_data.dart';

import 'search_cubit.dart';

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
