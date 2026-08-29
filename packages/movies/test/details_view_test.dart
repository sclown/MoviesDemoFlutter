import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/movies.dart';
import 'package:movies_core/movies_core.dart';
import 'package:movies_core_mocks/movies_core_mocks.dart';

import 'test_harness.dart';

void main() {
  testWidgets('shows the title, rating, release date and overview', (
    tester,
  ) async {
    final movie = movieDetails();
    await tester.pumpWidget(harnessApp(DetailsView(movie: movie)));

    expect(find.text(movie.title), findsOne);
    expect(find.text('8.5'), findsOne);
    expect(find.text('Release date: 2025-06-15'), findsOne);
    expect(find.text(movie.overview), findsOne);
  });

  testWidgets('hides the release date when there is none', (tester) async {
    const movie = MovieDetails(
      id: 7,
      title: 'Undated',
      poster: null,
      rating: '5.0',
      releaseDate: null,
      overview: 'No release date on record.',
    );
    await tester.pumpWidget(harnessApp(const DetailsView(movie: movie)));

    expect(find.textContaining('Release date'), findsNothing);
  });

  testWidgets('hides an empty release date too', (tester) async {
    const movie = MovieDetails(
      id: 7,
      title: 'Undated',
      poster: null,
      rating: '5.0',
      releaseDate: '',
      overview: 'No release date on record.',
    );
    await tester.pumpWidget(harnessApp(const DetailsView(movie: movie)));

    expect(find.textContaining('Release date'), findsNothing);
  });

  testWidgets('labels the poster and the rating for assistive tech', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(harnessApp(DetailsView(movie: movieDetails())));

    expect(find.bySemanticsLabel("Movie's poster"), findsOne);
    expect(find.bySemanticsLabel('Rating'), findsOne);

    handle.dispose();
  });

  testWidgets('translates into German', (tester) async {
    await tester.pumpWidget(
      harnessApp(
        DetailsView(movie: movieDetails()),
        locale: const Locale('de'),
      ),
    );

    expect(find.text('Erscheinungsdatum: 2025-06-15'), findsOne);
  });
}
