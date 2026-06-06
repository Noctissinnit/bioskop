import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/movie_service.dart';
import '../models/movie.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final _authService = AuthService();
  final _movieService = MovieService();
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        backgroundColor: const Color(0xFF78909C),
        elevation: 0,
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                child: const Text('Keluar'),
                onTap: () async {
                  await _authService.signOut();
                },
              ),
            ],
          ),
        ],
      ),
      body: _selectedIndex == 0
          ? const _MovieListTab()
          : const _ManageUsersTab(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        backgroundColor: const Color(0xFF78909C),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.movie),
            label: 'Film',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Pengguna',
          ),
        ],
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}

// Tab untuk mengelola film
class _MovieListTab extends StatefulWidget {
  const _MovieListTab();

  @override
  State<_MovieListTab> createState() => _MovieListTabState();
}

class _MovieListTabState extends State<_MovieListTab> {
  final _movieService = MovieService();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: FilledButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const _AddEditMovieScreen(),
                ),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Tambah Film'),
          ),
        ),
        Expanded(
          child: StreamBuilder<List<Movie>>(
            stream: _movieService.getAllMoviesStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final movies = snapshot.data ?? [];

              if (movies.isEmpty) {
                return const Center(
                  child: Text('Belum ada film'),
                );
              }

              return ListView.builder(
                itemCount: movies.length,
                itemBuilder: (context, index) {
                  final movie = movies[index];
                  return Card(
                    margin: const EdgeInsets.all(8),
                    child: ListTile(
                      leading: Text(
                        movie.posterUrl,
                        style: const TextStyle(fontSize: 24),
                      ),
                      title: Text(movie.title),
                      subtitle: Text('${movie.genre} • ${movie.rating}★'),
                      trailing: PopupMenuButton(
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            child: const Text('Edit'),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      _AddEditMovieScreen(movie: movie),
                                ),
                              );
                            },
                          ),
                          PopupMenuItem(
                            child: const Text('Hapus'),
                            onTap: () {
                              _showDeleteConfirmation(context, movie.id);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmation(BuildContext context, String movieId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: const Text('Yakin ingin menghapus film ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () async {
              try {
                await _movieService.deleteMovie(movieId);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Film berhasil dihapus')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}

// Screen untuk menambah atau edit film
class _AddEditMovieScreen extends StatefulWidget {
  final Movie? movie;

  const _AddEditMovieScreen({this.movie});

  @override
  State<_AddEditMovieScreen> createState() => _AddEditMovieScreenState();
}

class _AddEditMovieScreenState extends State<_AddEditMovieScreen> {
  final _movieService = MovieService();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _posterUrlController;
  late TextEditingController _ratingController;
  late TextEditingController _genreController;
  late TextEditingController _durationController;
  late TextEditingController _showtimesController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.movie?.title ?? '');
    _descriptionController =
        TextEditingController(text: widget.movie?.description ?? '');
    _posterUrlController =
        TextEditingController(text: widget.movie?.posterUrl ?? '');
    _ratingController = TextEditingController(text: widget.movie?.rating ?? '');
    _genreController = TextEditingController(text: widget.movie?.genre ?? '');
    _durationController =
        TextEditingController(text: widget.movie?.duration ?? '');
    _showtimesController = TextEditingController(
      text: widget.movie?.showtimes.join(', ') ?? '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _posterUrlController.dispose();
    _ratingController.dispose();
    _genreController.dispose();
    _durationController.dispose();
    _showtimesController.dispose();
    super.dispose();
  }

  void _saveMovie() async {
    if (_titleController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _genreController.text.isEmpty ||
        _ratingController.text.isEmpty ||
        _durationController.text.isEmpty ||
        _showtimesController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua field harus diisi')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final showtimes = _showtimesController.text
          .split(',')
          .map((e) => e.trim())
          .toList();

      if (widget.movie == null) {
        // Create new movie
        await _movieService.createMovie(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          posterUrl: _posterUrlController.text.trim(),
          rating: _ratingController.text.trim(),
          genre: _genreController.text.trim(),
          duration: _durationController.text.trim(),
          showtimes: showtimes,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Film berhasil ditambahkan')),
          );
          Navigator.pop(context);
        }
      } else {
        // Update existing movie
        await _movieService.updateMovie(
          movieId: widget.movie!.id,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          posterUrl: _posterUrlController.text.trim(),
          rating: _ratingController.text.trim(),
          genre: _genreController.text.trim(),
          duration: _durationController.text.trim(),
          showtimes: showtimes,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Film berhasil diperbarui')),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.movie == null ? 'Tambah Film' : 'Edit Film'),
        backgroundColor: const Color(0xFF78909C),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField('Judul Film', _titleController),
            _buildTextField('Deskripsi', _descriptionController, maxLines: 3),
            _buildTextField('URL Poster', _posterUrlController),
            _buildTextField('Rating', _ratingController),
            _buildTextField('Genre', _genreController),
            _buildTextField('Durasi (contoh: 120 min)', _durationController),
            _buildTextField(
              'Jam Tayang (pisahkan dengan koma, contoh: 10:00, 13:30, 16:45)',
              _showtimesController,
              maxLines: 2,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _isLoading ? null : _saveMovie,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(widget.movie == null ? 'Tambah Film' : 'Perbarui Film'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            maxLines: maxLines,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
        ],
      ),
    );
  }
}

// Tab untuk mengelola pengguna
class _ManageUsersTab extends StatefulWidget {
  const _ManageUsersTab();

  @override
  State<_ManageUsersTab> createState() => _ManageUsersTabState();
}

class _ManageUsersTabState extends State<_ManageUsersTab> {
  final _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _authService.getAllUsersStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final users = snapshot.data ?? [];

        if (users.isEmpty) {
          return const Center(child: Text('Belum ada pengguna'));
        }

        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            final isAdmin = user['role'] == 'admin';

            return Card(
              margin: const EdgeInsets.all(8),
              child: ListTile(
                title: Text(user['name'] ?? 'Unknown'),
                subtitle: Text(user['email'] ?? ''),
                trailing: Chip(
                  label: Text(user['role'] ?? 'user'),
                  backgroundColor: isAdmin ? Colors.green : Colors.grey,
                  labelStyle: const TextStyle(color: Colors.white),
                ),
                onLongPress: () {
                  _showRoleOptions(context, user);
                },
              ),
            );
          },
        );
      },
    );
  }

  void _showRoleOptions(
      BuildContext context, Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ubah Role'),
        content: Text('Ubah role untuk ${user['name']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () async {
              final newRole = user['role'] == 'admin' ? 'user' : 'admin';
              try {
                await _authService.setUserRole(user['uid'], newRole);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Role berhasil diubah menjadi $newRole'),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            child: Text('Ubah ke ${user['role'] == 'admin' ? 'User' : 'Admin'}'),
          ),
        ],
      ),
    );
  }
}
