//
//  app_test.dart — end-to-end tests driving the composed app against the real
//  TMDB API. They need a booted device or simulator and a key:
//
//    flutter test integration_test --dart-define-from-file=.env.local
//
//  Everything here is matched by accessibility identifier, never by on-screen
//  text or widget type. Text would fail on a device that is not set to English;
//  types couple the test to the widget tree, which has already broken once when
//  the grid changed from `GridView` to `CustomScrollView`. The translations are
//  asserted in the widget tests, which pin the locale themselves.
//

import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter/semantics.dart';
import 'package:integration_test/integration_test.dart';
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

  late SemanticsHandle semantics;
  setUp(() => semantics = SemanticsBinding.instance.ensureSemantics());
  tearDown(() => semantics.dispose());
  tearDown(GetIt.instance.reset);

  /// The first poster in the grid, by the identifier the cell carries.
  final firstCell = find.bySemanticsIdentifier(RegExp(r'^movieCell-')).first;

  testWidgets('the movies grid appears on launch', (tester) async {
    await tester.pumpWidget(const app.MoviesDemoApp());

    await waitFor(tester, find.bySemanticsIdentifier('moviesGrid'));
    await waitFor(tester, firstCell);
  });

  testWidgets('the search field exists', (tester) async {
    await tester.pumpWidget(const app.MoviesDemoApp());

    await waitFor(tester, find.bySemanticsIdentifier('searchField'));
  });

  testWidgets('tapping a movie opens its details', (tester) async {
    await tester.pumpWidget(const app.MoviesDemoApp());
    await waitFor(tester, find.bySemanticsIdentifier('moviesGrid'));

    await tester.tap(firstCell);
    await waitFor(tester, find.bySemanticsIdentifier('detailsScreen'));
  });

  testWidgets('search shows results', (tester) async {
    await tester.pumpWidget(const app.MoviesDemoApp());
    await waitFor(tester, find.bySemanticsIdentifier('searchField'));

    await tester.enterText(find.bySemanticsIdentifier('searchField'), 'Batman');
    await waitFor(tester, find.bySemanticsIdentifier('searchResults'));
  });

  testWidgets('navigating back returns to the grid', (tester) async {
    await tester.pumpWidget(const app.MoviesDemoApp());
    await waitFor(tester, find.bySemanticsIdentifier('moviesGrid'));

    await tester.tap(firstCell);
    await waitFor(tester, find.bySemanticsIdentifier('detailsScreen'));

    await tester.pageBack();
    await waitFor(tester, find.bySemanticsIdentifier('moviesGrid'));
  });
}
