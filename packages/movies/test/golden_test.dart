//
//  golden_test.dart
//
//  Every state of the movies screens is rendered at iPhone size and compared
//  to a checked-in image. Run `flutter test --update-goldens` in this package
//  to re-record.
//

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:movies/movies.dart';
import 'package:movies/src/list/movies_list_state.dart';
import 'package:movies_core/movies_core.dart';

import 'test_harness.dart';

const _iPhoneSize = Size(390, 844);

void main() {
  tearDown(GetIt.instance.reset);

  setUp(() {
    // Off-screen images would otherwise resolve over the network.
    imageCache.clear();
  });

  Future<void> pumpSized(WidgetTester tester, Widget widget) async {
    tester.view
      ..physicalSize = _iPhoneSize
      ..devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(widget);
    // A fixed pump, not pumpAndSettle: the progress spinners never settle.
    await tester.pump(const Duration(milliseconds: 100));
  }

  testWidgets('movies-loading', (tester) async {
    await pumpSized(
      tester,
      harnessMoviesView(MoviesViewModelMock(MoviesListState.empty())),
    );

    await expectLater(
      find.byType(MoviesView),
      matchesGoldenFile('goldens/movies_loading.png'),
    );
  });

  testWidgets('movies-error', (tester) async {
    await pumpSized(
      tester,
      harnessMoviesView(MoviesViewModelMock(MoviesListState.error())),
    );

    await expectLater(
      find.byType(MoviesView),
      matchesGoldenFile('goldens/movies_error.png'),
    );
  });

  testWidgets('movies-3', (tester) async {
    await pumpSized(
      tester,
      harnessMoviesView(MoviesViewModelMock(MoviesListState.mockMovies(3))),
    );

    await expectLater(
      find.byType(MoviesView),
      matchesGoldenFile('goldens/movies_3.png'),
    );
  });

  testWidgets('movies-8', (tester) async {
    await pumpSized(
      tester,
      harnessMoviesView(MoviesViewModelMock(MoviesListState.mockMovies(8))),
    );

    await expectLater(
      find.byType(MoviesView),
      matchesGoldenFile('goldens/movies_8.png'),
    );
  });

  testWidgets('details', (tester) async {
    await pumpSized(tester, harnessApp(DetailsView(movie: MovieDetails.mock())));

    await expectLater(
      find.byType(DetailsView),
      matchesGoldenFile('goldens/details.png'),
    );
  });
}
