//
//  movie_detail.dart
//
//  The `/movie/{id}` payload. TMDB splices each name passed in
//  `append_to_response` into this same object under a key matching the
//  sub-path, so `credits` and `videos` arrive here rather than on calls of
//  their own. Those envelopes carry nothing but their collection, so they are
//  flattened away as they are parsed.
//

import 'json_field.dart';

final class MovieDetailResponse {
  const MovieDetailResponse({
    required this.id,
    required this.title,
    required this.overview,
    required this.posterPath,
    required this.releaseDate,
    required this.voteAverage,
    required this.genres,
    required this.videos,
    required this.cast,
    required this.crew,
  });

  factory MovieDetailResponse.fromJson(Map<String, dynamic> json) {
    final credits = json['credits'];
    final creditsJson = credits is Map<String, dynamic>
        ? credits
        : const <String, dynamic>{};
    final videos = json['videos'];
    final videosJson = videos is Map<String, dynamic>
        ? videos
        : const <String, dynamic>{};

    return MovieDetailResponse(
      id: requireField<int>(json, 'id'),
      title: requireField<String>(json, 'title'),
      overview: requireField<String>(json, 'overview'),
      posterPath: json['poster_path'] as String?,
      releaseDate: json['release_date'] as String?,
      voteAverage: requireField<num>(json, 'vote_average').toDouble(),
      genres: [
        for (final item in optionalObjects(json, 'genres'))
          Genre.fromJson(item),
      ],
      videos: [
        for (final item in optionalObjects(videosJson, 'results'))
          Video.fromJson(item),
      ],
      cast: [
        for (final item in optionalObjects(creditsJson, 'cast'))
          CastCredit.fromJson(item),
      ],
      crew: [
        for (final item in optionalObjects(creditsJson, 'crew'))
          CrewCredit.fromJson(item),
      ],
    );
  }

  final int id;
  final String title;
  final String overview;
  final String? posterPath;
  final String? releaseDate;
  final double voteAverage;

  /// From the movie object itself — no append needed.
  final List<Genre> genres;

  /// From `append_to_response=videos`.
  final List<Video> videos;

  /// From `append_to_response=credits`.
  final List<CastCredit> cast;
  final List<CrewCredit> crew;
}

final class Genre {
  const Genre({required this.id, required this.name});

  factory Genre.fromJson(Map<String, dynamic> json) => Genre(
    id: requireField<int>(json, 'id'),
    name: requireField<String>(json, 'name'),
  );

  final int id;
  final String name;
}

final class Video {
  const Video({
    required this.key,
    required this.name,
    required this.site,
    required this.type,
    required this.official,
  });

  factory Video.fromJson(Map<String, dynamic> json) => Video(
    key: requireField<String>(json, 'key'),
    name: requireField<String>(json, 'name'),
    site: requireField<String>(json, 'site'),
    type: requireField<String>(json, 'type'),
    official: json['official'] as bool? ?? false,
  );

  final String key;
  final String name;

  /// `YouTube` or `Vimeo`. Only the former gets a playable link here.
  final String site;

  /// `Trailer`, `Teaser`, `Clip`, `Featurette`, `Behind the Scenes`…
  final String type;
  final bool official;
}

final class CastCredit {
  const CastCredit({
    required this.id,
    required this.name,
    required this.character,
    required this.profilePath,
    required this.order,
  });

  factory CastCredit.fromJson(Map<String, dynamic> json) => CastCredit(
    id: requireField<int>(json, 'id'),
    name: requireField<String>(json, 'name'),
    character: json['character'] as String? ?? '',
    profilePath: json['profile_path'] as String?,
    order: json['order'] as int? ?? 1 << 30,
  );

  final int id;
  final String name;
  final String character;
  final String? profilePath;

  /// Billing order. TMDB returns cast already sorted by it.
  final int order;
}

final class CrewCredit {
  const CrewCredit({
    required this.id,
    required this.name,
    required this.job,
    required this.department,
    required this.profilePath,
  });

  factory CrewCredit.fromJson(Map<String, dynamic> json) => CrewCredit(
    id: requireField<int>(json, 'id'),
    name: requireField<String>(json, 'name'),
    job: json['job'] as String? ?? '',
    department: json['department'] as String? ?? '',
    profilePath: json['profile_path'] as String?,
  );

  final int id;
  final String name;

  /// `Director`, `Screenplay`, `Original Music Composer`…
  final String job;
  final String department;
  final String? profilePath;
}
