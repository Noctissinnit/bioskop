import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/movie.dart';

class MovieService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _moviesCollection = 'movies';

  // Get all movies as stream
  Stream<List<Movie>> getAllMoviesStream() {
    return _firestore.collection(_moviesCollection).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Movie(
          id: doc.id,
          title: doc['title'] ?? '',
          description: doc['description'] ?? '',
          posterUrl: doc['posterUrl'] ?? '',
          rating: doc['rating'] ?? '0',
          genre: doc['genre'] ?? '',
          duration: doc['duration'] ?? '',
          showtimes: List<String>.from(doc['showtimes'] ?? []),
        );
      }).toList();
    });
  }

  // Get single movie by ID
  Future<Movie?> getMovieById(String movieId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(_moviesCollection)
          .doc(movieId)
          .get();

      if (!doc.exists) return null;

      return Movie(
        id: doc.id,
        title: doc['title'] ?? '',
        description: doc['description'] ?? '',
        posterUrl: doc['posterUrl'] ?? '',
        rating: doc['rating'] ?? '0',
        genre: doc['genre'] ?? '',
        duration: doc['duration'] ?? '',
        showtimes: List<String>.from(doc['showtimes'] ?? []),
      );
    } catch (e) {
      rethrow;
    }
  }

  // Create new movie (Admin only)
  Future<String> createMovie({
    required String title,
    required String description,
    required String posterUrl,
    required String rating,
    required String genre,
    required String duration,
    required List<String> showtimes,
  }) async {
    try {
      DocumentReference docRef = await _firestore
          .collection(_moviesCollection)
          .add({
        'title': title,
        'description': description,
        'posterUrl': posterUrl,
        'rating': rating,
        'genre': genre,
        'duration': duration,
        'showtimes': showtimes,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return docRef.id;
    } catch (e) {
      rethrow;
    }
  }

  // Update movie (Admin only)
  Future<void> updateMovie({
    required String movieId,
    required String title,
    required String description,
    required String posterUrl,
    required String rating,
    required String genre,
    required String duration,
    required List<String> showtimes,
  }) async {
    try {
      await _firestore.collection(_moviesCollection).doc(movieId).update({
        'title': title,
        'description': description,
        'posterUrl': posterUrl,
        'rating': rating,
        'genre': genre,
        'duration': duration,
        'showtimes': showtimes,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }

  // Delete movie (Admin only)
  Future<void> deleteMovie(String movieId) async {
    try {
      await _firestore.collection(_moviesCollection).doc(movieId).delete();
    } catch (e) {
      rethrow;
    }
  }

  // Get all movies as future (one-time fetch)
  Future<List<Movie>> getAllMovies() async {
    try {
      QuerySnapshot snapshot =
          await _firestore.collection(_moviesCollection).get();

      return snapshot.docs.map((doc) {
        return Movie(
          id: doc.id,
          title: doc['title'] ?? '',
          description: doc['description'] ?? '',
          posterUrl: doc['posterUrl'] ?? '',
          rating: doc['rating'] ?? '0',
          genre: doc['genre'] ?? '',
          duration: doc['duration'] ?? '',
          showtimes: List<String>.from(doc['showtimes'] ?? []),
        );
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  // Search movies by title
  Future<List<Movie>> searchMovies(String query) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_moviesCollection)
          .where('title', isGreaterThanOrEqualTo: query)
          .where('title', isLessThanOrEqualTo: query + '\uf8ff')
          .get();

      return snapshot.docs.map((doc) {
        return Movie(
          id: doc.id,
          title: doc['title'] ?? '',
          description: doc['description'] ?? '',
          posterUrl: doc['posterUrl'] ?? '',
          rating: doc['rating'] ?? '0',
          genre: doc['genre'] ?? '',
          duration: doc['duration'] ?? '',
          showtimes: List<String>.from(doc['showtimes'] ?? []),
        );
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  // Get movies by genre
  Stream<List<Movie>> getMoviesByGenreStream(String genre) {
    return _firestore
        .collection(_moviesCollection)
        .where('genre', isEqualTo: genre)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Movie(
          id: doc.id,
          title: doc['title'] ?? '',
          description: doc['description'] ?? '',
          posterUrl: doc['posterUrl'] ?? '',
          rating: doc['rating'] ?? '0',
          genre: doc['genre'] ?? '',
          duration: doc['duration'] ?? '',
          showtimes: List<String>.from(doc['showtimes'] ?? []),
        );
      }).toList();
    });
  }
}
