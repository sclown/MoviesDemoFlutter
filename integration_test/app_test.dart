//
//  app_test.dart — end-to-end tests driving the composed app against the real
//  TMDB API. They need a booted device or simulator and a key:
//
//    flutter test integration_test --dart-define-from-file=.env.local
//
//  Everything here is matched by widget type, never by on-screen text: the app
//  is localized, so text assertions would fail on a device that is not set to
//  English. The translations are asserted in the widget tests, which pin the
//  locale themselves.
//

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:integration_test/integration_test.dart';
import 'package:movies/movies.dart';
import 'package:movies_demo_flutter/main.dart' as app;
import 'package:movies_demo_flutter/modules.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  /// Pumps frames until [finder] matches, or gives up after [timeout].
  Future<void> waitFor(
    WidgetTester tester,
    Finder finder, {
    Duration timeout = const Duration(seconds: 10),
  }) async {
    final deadline = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(deadline)) {
      await tester.pump(const Duration(milliseconds: 100));
      if (finder.evaluate().isNotEmpty) return;
    }
    fail('Timed out waiting for $finder');
  }

  setUp(registerModules);
  // Without this the cubits, the cache and the navigator survive into the next
  // test, which then starts on whatever screen the last one left behind.
  tearDown(GetIt.instance.reset);

  /// The first poster in the grid.
  final firstCell = find
      .descendant(
        of: find.byType(GridView),
        matching: find.byType(GestureDetector),
      )
      .first;

  testWidgets('the movies grid appears on launch', (tester) async {
    await tester.pumpWidget(const app.MoviesDemoApp());

    await waitFor(tester, find.byType(MoviesView));
    await waitFor(tester, find.byType(GridView));
  });

  testWidgets('the search field exists', (tester) async {
    await tester.pumpWidget(const app.MoviesDemoApp());

    await waitFor(tester, find.byType(TextField));
  });

  testWidgets('tapping a movie opens its details', (tester) async {
    await tester.pumpWidget(const app.MoviesDemoApp());
    await waitFor(tester, find.byType(GridView));

    await tester.tap(firstCell);
    await waitFor(tester, find.byType(DetailsView));
  });

  testWidgets('search shows results', (tester) async {
    await tester.pumpWidget(const app.MoviesDemoApp());
    await waitFor(tester, find.byType(TextField));

    await tester.enterText(find.byType(TextField), 'Batman');
    await waitFor(tester, find.byType(ListView));
  });

  testWidgets('navigating back returns to the grid', (tester) async {
    await tester.pumpWidget(const app.MoviesDemoApp());
    await waitFor(tester, find.byType(GridView));

    await tester.tap(firstCell);
    await waitFor(tester, find.byType(DetailsView));

    await tester.pageBack();
    await waitFor(tester, find.byType(GridView));
  });
}
