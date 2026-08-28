//
//  search_card.dart
//

import 'package:movies_api/movies_api.dart';
import 'package:movies_core/movies_core.dart';

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

  factory SearchCard.mock() => SearchCard.mockWith(id: 1);

  factory SearchCard.mockWith({required int id}) => SearchCard(
    id: id,
    title: 'Test movie $id',
    rating: '7.5',
    releaseDate: '2025-06-15',
    poster: null,
  );

  final int id;
  final String title;
  final String rating;
  final String? releaseDate;
  final Uri? poster;
}
