//
//  app_test.dart — the composed app, end to end over a stubbed network.
//

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:main_navigation/main_navigation.dart';
import 'package:movies/movies.dart';
import 'package:movies_demo_flutter/main.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movies_api/movies_api.dart';
import 'package:movies_api_mocks/movies_api_mocks.dart';

void main() {
  // `pumpAndSettle` is avoided throughout: the poster placeholders spin for as
  // long as the stubbed images never arrive, so frames never stop coming.
  setUp(() {
    // Registered first, so `registerModules` leaves the real service out.
    final api = MoviesApiMock();
    final page = movieResponse(ids: const [1, 2, 3, 4]);
    when(() => api.fetchPopularMovies(page: any(named: 'page')))
        .thenAnswer((_) async => page);
    when(
      () => api.searchMovies(query: any(named: 'query'), page: any(named: 'page')),
    ).thenAnswer((_) async => page);
    GetIt.instance.registerSingleton<MovieServicing>(api);
    registerModules();
  });

  tearDown(GetIt.instance.reset);

  testWidgets('launches on the popular movies grid', (tester) async {
    await tester.pumpWidget(const MoviesDemoApp());
    await tester.pump();

    expect(find.text('Popular Movies'), findsOne);
    expect(find.text('Test Movie 1'), findsWidgets);
  });

  testWidgets('a poster opens the details screen and back returns', (
    tester,
  ) async {
    await tester.pumpWidget(const MoviesDemoApp());
    await tester.pump();

    await tester.tap(find.text('Test Movie 2').first);
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(DetailsView), findsOne);
    expect(find.text('Release date: 2025-01-01'), findsOne);
    expect(find.text('7.5'), findsOne);

    await tester.pageBack();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(DetailsView), findsNothing);
    expect(find.text('Popular Movies'), findsOne);
  });

  testWidgets('the navigator drives the path', (tester) async {
    await tester.pumpWidget(const MoviesDemoApp());
    await tester.pump();

    final mainViewModel = GetIt.instance<MainViewModel>();
    expect(mainViewModel.path, isEmpty);

    await tester.tap(find.text('Test Movie 1').first);
    await tester.pump(const Duration(milliseconds: 400));

    expect(mainViewModel.path, hasLength(1));
    expect(mainViewModel.path.first.title, 'Test Movie 1');
  });

  testWidgets('searching from the grid shows results', (tester) async {
    await tester.pumpWidget(const MoviesDemoApp());
    await tester.pump();

    await tester.enterText(find.byType(TextField), 'Test');
    // Past the debounce, then the stubbed response.
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump();

    expect(find.text('Test Movie 3'), findsWidgets);
  });
}
