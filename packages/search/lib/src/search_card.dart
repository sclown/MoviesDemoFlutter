//
//  search_card.dart
//

import 'package:movies_data/movies_data.dart';

final class SearchCard {
  const SearchCard({
    required this.id,
    required this.title,
    required this.rating,
    required this.releaseDate,
    required this.poster,
  });

  SearchCard.from(Movie movie)
    : id = movie.id,
      title = movie.title,
      rating = movie.ratingText(),
      releaseDate = movie.releaseDate,
      poster = movie.smallPoster();

  final int id;
  final String title;
  final String rating;
  final String? releaseDate;
  final Uri? poster;

  @override
  bool operator ==(Object other) =>
      other is SearchCard &&
      other.id == id &&
      other.title == title &&
      other.rating == rating &&
      other.releaseDate == releaseDate &&
      other.poster == poster;

  @override
  int get hashCode => Object.hash(id, title, rating, releaseDate, poster);
}
