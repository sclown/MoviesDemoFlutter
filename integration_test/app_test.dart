//
//  app_test.dart — end-to-end tests driving the composed app against the real
//  TMDB API. They need a device or simulator and a key:
//
//    flutter test integration_test --dart-define=TMDB_API_KEY=$TMDB_API_KEY
//

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:main_navigation/main_navigation.dart';
import 'package:movies/movies.dart';
import 'package:movies_demo_flutter/main.dart' as app;

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

  /// The first poster in the grid.
  final firstCell = find
      .descendant(
        of: find.byType(GridView),
        matching: find.byType(GestureDetector),
      )
      .first;

  testWidgets('the movies grid appears on launch', (tester) async {
    await tester.pumpWidget(const app.MoviesDemoApp());

    await waitFor(tester, find.text('Popular Movies'));
    await waitFor(tester, find.byType(GridView));
  });

  testWidgets('the search field exists', (tester) async {
    await tester.pumpWidget(const app.MoviesDemoApp());

    await waitFor(tester, find.bySemanticsLabel('Search movies'));
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
    await waitFor(tester, find.text('Popular Movies'));
  });
}
