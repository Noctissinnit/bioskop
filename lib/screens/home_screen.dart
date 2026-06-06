import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../models/movie.dart';
import 'movie_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _authService = AuthService();
  bool _isLoading = false;
  String _selectedGenre = 'Semua';
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  void _showEditProfileDialog(BuildContext context, User? user) {
    _usernameController.text = user?.displayName ?? '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profil'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Username:'),
            const SizedBox(height: 8),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                hintText: 'Masukkan username baru',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () async {
              if (_usernameController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Username tidak boleh kosong')),
                );
                return;
              }

              try {
                await _authService.updateDisplayName(_usernameController.text.trim());

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Username berhasil diupdate')),
                  );
                  Navigator.pop(context);
                  setState(() {});
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Gagal mengupdate username')),
                  );
                }
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }



  // Dummy data filmnya disini sam 
  final List<Movie> _allMovies = [
    Movie(
      id: '1',
      title: 'Dune: Part Two',
      description: 'Paul Atreides bermakna untuk membalas dendam kepada para pengkhianat keluarganya.',
      posterUrl: '🎬',
      rating: '8.5',
      genre: 'Sci-Fi',
      duration: '166 min',
      showtimes: ['10:00', '13:30', '16:45', '19:30', '22:00'],
    ),
    Movie(
      id: '2',
      title: 'Oppenheimer',
      description: 'Kisah nyata tentang pembuatan bom atom oleh J. Robert Oppenheimer.',
      posterUrl: '🎬',
      rating: '8.8',
      genre: 'Drama',
      duration: '180 min',
      showtimes: ['11:00', '14:30', '17:45', '20:30'],
    ),
    Movie(
      id: '3',
      title: 'Barbie',
      description: 'Barbie dan Ken memulai petualangan baru di dunia nyata.',
      posterUrl: '🎬',
      rating: '7.9',
      genre: 'Komedi',
      duration: '114 min',
      showtimes: ['10:30', '12:45', '15:00', '17:30', '19:45', '21:45'],
    ),
    Movie(
      id: '4',
      title: 'Spider-Man: Beyond the Spider-Verse',
      description: 'Miles Morales kembali untuk petualangan Spider-Man berikutnya.',
      posterUrl: '🎬',
      rating: '8.3',
      genre: 'Action',
      duration: '140 min',
      showtimes: ['10:15', '12:45', '15:15', '17:45', '20:15', '22:30'],
    ),
    Movie(
      id: '5',
      title: 'Killers of the Flower Moon',
      description: 'Kisah kriminal nyata di Oklahoma pada tahun 1920an.',
      posterUrl: '🎬',
      rating: '8.2',
      genre: 'Drama',
      duration: '206 min',
      showtimes: ['14:00', '18:00', '21:00'],
    ),
    Movie(
      id: '6',
      title: 'The Nun II',
      description: 'Kembalinya entitas supernatural yang menakutkan.',
      posterUrl: '🎬',
      rating: '6.5',
      genre: 'Horror',
      duration: '110 min',
      showtimes: ['19:00', '21:30', '23:00'],
    ),
  ];

  List<Movie> get _filteredMovies {
    List<Movie> filtered = _allMovies;

    // Filter genra
    if (_selectedGenre != 'Semua') {
      filtered = filtered.where((movie) => movie.genre == _selectedGenre).toList();
    }

    // Filter by search
    if (_searchController.text.isNotEmpty) {
      filtered = filtered
          .where((movie) => movie.title.toLowerCase().contains(_searchController.text.toLowerCase()))
          .toList();
    }

    return filtered;
  }

  List<String> get _genres {
    return ['Semua', ...{..._allMovies.map((m) => m.genre)}];
  }

  void _logout() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _authService.signOut();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Logout berhasil')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Terjadi kesalahan saat logout')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    User? user = _authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Aplikasi Bioskop'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          PopupMenuButton<String>(
            itemBuilder: (context) => [
              PopupMenuItem<String>(
                enabled: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.displayName ?? 'Pengguna',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      user?.email ?? '',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              const PopupMenuDivider(height: 1),
              PopupMenuItem<String>(
                value: 'edit',
                child: const Text('Edit Profil'),
              ),
              PopupMenuItem<String>(
                value: 'logout',
                child: const Text('Logout'),
              ),
            ],
            onSelected: (value) {
              if (value == 'edit') {
                _showEditProfileDialog(context, user);
              } else if (value == 'logout') {
                _logout();
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header dengan greeting
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hi ${user?.displayName ?? 'Pengguna'}! 👋',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Pesan tiket bioskop favorit Anda',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {});
                },
                decoration: InputDecoration(
                  hintText: 'Cari film...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Genre Filter
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _genres.map((genre) {
                    bool isSelected = _selectedGenre == genre;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: FilterChip(
                        label: Text(genre),
                        selected: isSelected,
                        onSelected: (value) {
                          setState(() {
                            _selectedGenre = genre;
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Movie Grid
            if (_filteredMovies.isEmpty)
              Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    const Icon(
                      Icons.movie_filter,
                      size: 64,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Film tidak ditemukan',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: _filteredMovies.length,
                  itemBuilder: (context, index) {
                    final movie = _filteredMovies[index];
                    return _buildMovieCard(context, movie);
                  },
                ),
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildMovieCard(BuildContext context, Movie movie) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MovieDetailScreen(movie: movie),
          ),
        );
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Poster
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.inversePrimary,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Center(
                  child: Text(
                    movie.posterUrl,
                    style: const TextStyle(fontSize: 48),
                  ),
                ),
              ),
            ),

            // Movie Info
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    movie.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),

                  // Genre & Rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        movie.genre,
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 14, color: Colors.amber),
                          const SizedBox(width: 2),
                          Text(
                            movie.rating,
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Pesan Tiket Button
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MovieDetailScreen(movie: movie),
                          ),
                        );
                      },
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      child: const Text(
                        'Pesan',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
