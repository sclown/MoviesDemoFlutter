import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies_data/movies_data.dart';
import 'package:movies_data_mocks/movies_data_mocks.dart';

import 'test_harness.dart';

void main() {
  testWidgets('shows the title, rating, release date and overview', (
    tester,
  ) async {
    final movie = movieDetails();
    await tester.pumpWidget(harnessDetailsView(movie));

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
    await tester.pumpWidget(harnessDetailsView(movie));

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
    await tester.pumpWidget(harnessDetailsView(movie));

    expect(find.textContaining('Release date'), findsNothing);
  });

  testWidgets('labels the poster and the rating for assistive tech', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(harnessDetailsView(movieDetails()));

    expect(find.bySemanticsLabel("Movie's poster"), findsOne);
    expect(find.bySemanticsLabel('Rating'), findsOne);

    handle.dispose();
  });

  testWidgets('shows the unavailable state for an id the cache never saw', (
    tester,
  ) async {
    await tester.pumpWidget(harnessMissingDetailsView());

    expect(find.text('This movie is no longer available.'), findsOne);
  });

  testWidgets('translates into German', (tester) async {
    await tester.pumpWidget(
      harnessDetailsView(movieDetails(), locale: const Locale('de')),
    );

    expect(find.text('Erscheinungsdatum: 2025-06-15'), findsOne);
  });
}
