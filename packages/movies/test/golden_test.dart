//
//  golden_test.dart
//
//  Every state of the movies screens is rendered at iPhone size and compared
//  to a checked-in image. Run `flutter test --update-goldens` in this package
//  to re-record.
//

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/movies.dart';
import 'package:movies_data_mocks/movies_data_mocks.dart';

import 'fixtures.dart';
import 'test_harness.dart';

const _iPhoneSize = Size(390, 844);

void main() {
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
      harnessMoviesView(moviesCubitMock(MoviesListState.empty())),
    );

    await expectLater(
      find.byType(MoviesView),
      matchesGoldenFile('goldens/movies_loading.png'),
    );
  });

  testWidgets('movies-error', (tester) async {
    await pumpSized(
      tester,
      harnessMoviesView(moviesCubitMock(errorState())),
    );

    await expectLater(
      find.byType(MoviesView),
      matchesGoldenFile('goldens/movies_error.png'),
    );
  });

  testWidgets('movies-3', (tester) async {
    await pumpSized(
      tester,
      harnessMoviesView(moviesCubitMock(loadedState(3))),
    );

    await expectLater(
      find.byType(MoviesView),
      matchesGoldenFile('goldens/movies_3.png'),
    );
  });

  testWidgets('movies-8', (tester) async {
    await pumpSized(
      tester,
      harnessMoviesView(moviesCubitMock(loadedState(8))),
    );

    await expectLater(
      find.byType(MoviesView),
      matchesGoldenFile('goldens/movies_8.png'),
    );
  });

  testWidgets('details', (tester) async {
    await pumpSized(tester, harnessDetailsView(movieDetails()));

    await expectLater(
      find.byType(DetailsView),
      matchesGoldenFile('goldens/details.png'),
    );
  });
}
