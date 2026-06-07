
class Reservation {
  final String userId;
  final String movieId;
  final String movieTitle;
  final List<String> seats;
  final int totalPrice;
  final String showtime;
  final DateTime createdAt;

  Reservation({
    required this.userId,
    required this.movieId,
    required this.movieTitle,
    required this.seats,
    required this.totalPrice,
    required this.showtime,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'movieId': movieId,
      'movieTitle': movieTitle,
      'seats': seats,
      'totalPrice': totalPrice,
      'showtime': showtime,
      'createdAt': createdAt,
    };
  }
}