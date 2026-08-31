//
//  app_test.dart — the composed app, end to end over a stubbed network.
//

import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:movies_demo_flutter/main.dart';
import 'package:movies_demo_flutter/modules.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movies_data/movies_data.dart';
import 'package:movies_data_mocks/movies_data_mocks.dart';

void main() {
  setUp(() {
    // Registered first, so `registerModules` leaves the real service out.
    final api = MoviesApiMock();
    final page = movieResponse(ids: const [1, 2, 3, 4]);
    when(
      () => api.fetchPopularMovies(page: any(named: 'page')),
    ).thenAnswer((_) async => page);
    when(
      () => api.searchMovies(
        query: any(named: 'query'),
        page: any(named: 'page'),
      ),
    ).thenAnswer((_) async => page);
    GetIt.instance.registerSingleton<MovieServicing>(api);
    registerModules();
  });

  tearDown(GetIt.instance.reset);

  testWidgets('launches on the popular movies grid', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(const MoviesDemoApp());
    await tester.pump();

    expect(find.bySemanticsIdentifier('moviesGrid'), findsOne);
    expect(find.text('Test Movie 1'), findsWidgets);
    handle.dispose();
  });

  testWidgets('a poster opens the details screen and back returns', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(const MoviesDemoApp());
    await tester.pump();

    await tester.tap(find.bySemanticsIdentifier('movieCell-2'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.bySemanticsIdentifier('detailsScreen'), findsOne);
    expect(find.text('Release date: 2025-01-01'), findsOne);
    expect(find.text('7.5'), findsOne);

    await tester.pageBack();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.bySemanticsIdentifier('detailsScreen'), findsNothing);
    expect(find.bySemanticsIdentifier('moviesGrid'), findsOne);
    handle.dispose();
  });

  testWidgets('the navigator opens the tapped movie from the cache', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(const MoviesDemoApp());
    await tester.pump();

    expect(find.bySemanticsIdentifier('detailsScreen'), findsNothing);

    await tester.tap(find.bySemanticsIdentifier('movieCell-1'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.bySemanticsIdentifier('detailsScreen'), findsOne);
    expect(GetIt.instance<MovieCache>()[1]?.title, 'Test Movie 1');
    expect(find.text('Test Movie 1'), findsWidgets);
    handle.dispose();
  });

  testWidgets('searching from the grid shows results', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(const MoviesDemoApp());
    await tester.pump();

    await tester.enterText(find.bySemanticsIdentifier('searchField'), 'Test');
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump();

    expect(find.bySemanticsIdentifier('searchResults'), findsOne);
    expect(find.text('Test Movie 3'), findsWidgets);
    handle.dispose();
  });
}
