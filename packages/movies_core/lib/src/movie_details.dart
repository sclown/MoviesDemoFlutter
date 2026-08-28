//
//  movie_details.dart
//

/// The presentation model handed to the details screen — and the value pushed
/// onto the navigation stack.
final class MovieDetails {
  const MovieDetails({
    required this.id,
    required this.title,
    required this.poster,
    required this.rating,
    required this.releaseDate,
    required this.overview,
  });

  factory MovieDetails.mock() => MovieDetails.mockWith(id: 1);

  factory MovieDetails.mockWith({required int id}) => MovieDetails(
    id: id,
    title: 'Test Movie $id',
    poster: null,
    rating: '8.5',
    releaseDate: '2025-06-15',
    overview: 'A great movie about testing software and building apps.',
  );

  final int id;
  final String title;
  final Uri? poster;
  final String rating;
  final String? releaseDate;
  final String overview;

  @override
  bool operator ==(Object other) =>
      other is MovieDetails &&
      other.id == id &&
      other.title == title &&
      other.poster == poster &&
      other.rating == rating &&
      other.releaseDate == releaseDate &&
      other.overview == overview;

  @override
  int get hashCode =>
      Object.hash(id, title, poster, rating, releaseDate, overview);
}
