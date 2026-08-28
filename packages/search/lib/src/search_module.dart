//
//  search_module.dart
//

import 'package:get_it/get_it.dart';
import 'package:movies_api/movies_api.dart';
import 'package:movies_core/movies_core.dart';

import 'search_view_model.dart';

/// Wires the module's view model, leaving an existing registration alone so
/// tests and goldens can substitute a stub.
void registerSearch({GetIt? container}) {
  final getIt = container ?? GetIt.instance;
  if (getIt.isRegistered<SearchViewModeling>()) return;

  getIt.registerLazySingleton<SearchViewModeling>(
    () => SearchViewModel(
      service: getIt<MovieServicing>(),
      navigation: (movie) => getIt<MovieNavigator>().navigate(movie),
    ),
  );
}
