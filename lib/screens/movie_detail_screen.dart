import 'package:flutter/material.dart';
import '../models/movie.dart';
import 'seat_selection.dart';

class MovieDetailScreen extends StatefulWidget {
  final Movie movie;

  const MovieDetailScreen({super.key, required this.movie});

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  String? _selectedShowtime;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar dengan poster
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: Theme.of(context).colorScheme.inversePrimary,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.movie.posterUrl,
                        style: const TextStyle(fontSize: 80),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.movie.title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Rating & Genre & Duration
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.amber[100],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star, size: 16, color: Colors.amber),
                            const SizedBox(width: 4),
                            Text(
                              widget.movie.rating,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.purple[100],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          widget.movie.genre,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.blue[100],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.schedule, size: 14),
                            const SizedBox(width: 4),
                            Text(widget.movie.duration),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Deskripsi
                  Text(
                    'Sinopsis',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.movie.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[700],
                          height: 1.5,
                        ),
                  ),
                  const SizedBox(height: 24),

                  // Pilih Jadwal Tayang
                  Text(
                    'Pilih Jadwal Tayang',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),

                  // Jadwal dalam bentuk chip
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: widget.movie.showtimes.map((time) {
                      bool isSelected = _selectedShowtime == time;
                      return FilterChip(
                        label: Text(
                          time,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                        ),
                        selected: isSelected,
                        onSelected: (value) {
                          setState(() {
                            _selectedShowtime = isSelected ? null : time;
                          });
                        },
                        backgroundColor: Colors.grey[200],
                        selectedColor: Theme.of(context).colorScheme.primary,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 32),

                  // Tombol Pesan Tiket
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _selectedShowtime == null
                          ? null
                          : () {
                              // Navigasi ke halaman pemilihan kursi
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SeatSelection(
                                    movie: widget.movie,
                                    showtime: _selectedShowtime!,
                                  ),
                                ),
                              );
                            },
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Lanjut ke Pemesanan Kursi',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Tombol Kembali
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Kembali'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
