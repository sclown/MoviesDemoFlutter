//
//  key_crew.dart
//

import 'package:movies_data/movies_data.dart';

/// The jobs worth a row on a details screen, most billable first. TMDB returns
/// the entire crew — hundreds of people on a large production — so the screen
/// shows this slice of it rather than all of them.
const _billedJobs = <String>[
  'Director',
  'Screenplay',
  'Writer',
  'Story',
  'Novel',
  'Producer',
  'Executive Producer',
  'Original Music Composer',
  'Director of Photography',
  'Editor',
];

/// Picks the billed jobs out of [crew], most billable first.
///
/// One person often holds several — writing and directing the same film — and
/// TMDB lists each as its own credit, so those are merged back into a single
/// entry reading `Director, Screenplay`.
List<MoviePerson> keyCrew(List<MoviePerson> crew) {
  final ranks = <int, int>{};
  final jobs = <int, List<String>>{};
  final people = <int, MoviePerson>{};

  for (final member in crew) {
    final rank = _billedJobs.indexOf(member.role);
    if (rank < 0) continue;

    final seen = ranks[member.id];
    if (seen == null || rank < seen) ranks[member.id] = rank;
    (jobs[member.id] ??= []).add(member.role);
    people[member.id] ??= member;
  }

  final ids = ranks.keys.toList()
    ..sort((a, b) => ranks[a]!.compareTo(ranks[b]!));

  return [
    for (final id in ids)
      MoviePerson(
        id: id,
        name: people[id]!.name,
        role: _ordered(jobs[id]!).join(', '),
        photo: people[id]!.photo,
      ),
  ];
}

List<String> _ordered(List<String> roles) =>
    roles.toSet().toList()
      ..sort((a, b) => _billedJobs.indexOf(a).compareTo(_billedJobs.indexOf(b)));
