class Movie {
  final String id;
  final String title;
  final String description;
  final String posterUrl;
  final String rating;
  final String genre;
  final String duration;
  final List<String> showtimes;

  Movie({
    required this.id,
    required this.title,
    required this.description,
    required this.posterUrl,
    required this.rating,
    required this.genre,
    required this.duration,
    required this.showtimes,
  });
}
