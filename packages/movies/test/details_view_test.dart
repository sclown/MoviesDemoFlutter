import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/src/details/genre_tags.dart';
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

  testWidgets('shows the genres, trailers, cast and crew once enriched', (
    tester,
  ) async {
    await tester.pumpWidget(
      harnessDetailsView(movieDetails(extras: movieExtras())),
    );

    expect(find.text('Drama'), findsOne);
    expect(find.text('Science Fiction'), findsOne);

    expect(find.text('Trailers'), findsOne);
    expect(find.text('Official Trailer'), findsOne);

    expect(find.text('Cast'), findsOne);
    expect(find.text('Ada Lovelace'), findsOne);
    expect(find.text('Engineer'), findsOne);

    expect(find.text('Crew'), findsOne);
    expect(find.text('Grace Hopper'), findsOne);
  });

  testWidgets('merges a person\'s several crew jobs into one entry', (
    tester,
  ) async {
    await tester.pumpWidget(
      harnessDetailsView(movieDetails(extras: movieExtras())),
    );

    expect(find.text('Director, Screenplay'), findsOne);
  });

  testWidgets('leaves unbilled crew jobs off the screen', (tester) async {
    await tester.pumpWidget(
      harnessDetailsView(movieDetails(extras: movieExtras())),
    );

    expect(find.text('Katherine Johnson'), findsNothing);
  });

  testWidgets('shows none of the extra sections before they arrive', (
    tester,
  ) async {
    await tester.pumpWidget(harnessDetailsView(movieDetails()));

    expect(find.text('Trailers'), findsNothing);
    expect(find.text('Cast'), findsNothing);
    expect(find.text('Crew'), findsNothing);
    expect(find.byType(GenreTags), findsNothing);
  });

  testWidgets('the overview stays readable while the rest is in flight', (
    tester,
  ) async {
    final movie = movieDetails();
    await tester.pumpWidget(harnessDetailsView(movie, isEnriching: true));

    expect(find.text(movie.title), findsOne);
    expect(find.text(movie.overview), findsOne);
  });

  testWidgets('spins only once the enrichment has taken a moment', (
    tester,
  ) async {
    await tester.pumpWidget(
      harnessDetailsView(movieDetails(), isEnriching: true),
    );

    expect(find.bySemanticsIdentifier('detailsSpinner'), findsNothing);

    await tester.pump(const Duration(seconds: 1));

    expect(find.bySemanticsIdentifier('detailsSpinner'), findsOne);
  });

  testWidgets('hands a tapped trailer its video url', (tester) async {
    final played = <Uri>[];
    await tester.pumpWidget(
      harnessDetailsView(
        movieDetails(extras: movieExtras()),
        onPlayTrailer: played.add,
      ),
    );

    // The poster fills the first screenful, so the trailer row starts below
    // the fold.
    await tester.ensureVisible(find.text('Official Trailer'));
    await tester.pump(const Duration(seconds: 1));

    await tester.tap(find.text('Official Trailer'));
    await tester.pump();

    expect(played, [Uri.parse('https://www.youtube.com/watch?v=abc123')]);
  });

  testWidgets('labels a trailer for assistive tech', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      harnessDetailsView(movieDetails(extras: movieExtras())),
    );

    expect(
      find.bySemanticsLabel('Play trailer Official Trailer'),
      findsOne,
    );

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
      harnessDetailsView(
        movieDetails(extras: movieExtras()),
        locale: const Locale('de'),
      ),
    );

    expect(find.text('Erscheinungsdatum: 2025-06-15'), findsOne);
    expect(find.text('Besetzung'), findsOne);
    expect(find.text('Stab'), findsOne);
    expect(find.text('Trailer'), findsOne);
  });
}
