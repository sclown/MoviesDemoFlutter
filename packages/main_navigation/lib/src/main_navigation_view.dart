//
//  main_navigation_view.dart
//

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:movies/movies.dart';
import 'package:search/search.dart';

import 'main_view_model.dart';

/// The declarative stack: the pages are derived from [MainViewModel.path], the
/// way `NavigationStack(path:)` derives its own.
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  late final MainViewModel _viewModel = GetIt.instance<MainViewModel>();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) => Navigator(
        pages: [
          const MaterialPage(
            key: ValueKey('movies'),
            child: MoviesView(overlay: SearchOverlay()),
          ),
          for (final movie in _viewModel.path)
            MaterialPage(
              key: ValueKey('details-${movie.id}'),
              child: DetailsView(movie: movie),
            ),
        ],
        onDidRemovePage: (page) {
          final path = _viewModel.path;
          _viewModel.reset(path.sublist(0, path.length - 1));
        },
      ),
    );
  }
}
