import 'package:flutter/material.dart';
import '../models/movie.dart';
import 'payment_screen.dart';

class SeatSelection extends StatefulWidget {
  final Movie movie;
  final String showtime;

  const SeatSelection({super.key, required this.movie, required this.showtime});

  @override
  State<SeatSelection> createState() => _SeatSelectionState();
}

class _SeatSelectionState extends State<SeatSelection> {
  // Menyimpan daftar kursi yang dipilih oleh user
  final List<String> _selectedSeats = [];

  // Daftar kursi yang sudah terisi / terbooking secara statis
  final List<String> _occupiedSeats = [
    'A3',
    'A4',
    'B5',
    'B6',
    'C2',
    'D7',
    'D8',
    'E1',
    'E4',
  ];

  final int _ticketPrice = 45000;

  final List<String> _rows = ['A', 'B', 'C', 'D', 'E', 'F'];

  final int _columns = 8;

  // Fungsi pembantu untuk mendapatkan warna kursi berdasarkan statusnya
  Color _getSeatColor(String seatCode) {
    if (_occupiedSeats.contains(seatCode)) {
      return Colors.red.shade300;
    } else if (_selectedSeats.contains(seatCode)) {
      return Theme.of(context).colorScheme.primary;
    } else {
      return Colors.white;
    }
  }

  // Fungsi pembantu untuk mendapatkan warna border kursi
  Border? _getSeatBorder(String seatCode) {
    if (_occupiedSeats.contains(seatCode)) {
      return Border.all(color: Colors.red.shade400);
    } else if (_selectedSeats.contains(seatCode)) {
      return Border.all(color: Theme.of(context).colorScheme.primary);
    } else {
      return Border.all(color: Colors.grey.shade400, width: 1.5);
    }
  }

  // Aksi ketika kursi ditekan
  void _onSeatTap(String seatCode) {
    if (_occupiedSeats.contains(seatCode)) {
      // Jika kursi sudah terisi, tidak dapat ditekan
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kursi ini sudah dipesan orang lain!'),
          duration: Duration(milliseconds: 800),
        ),
      );
      return;
    }

    setState(() {
      if (_selectedSeats.contains(seatCode)) {
        // Jika sudah dipilih, batalkan pilihan
        _selectedSeats.remove(seatCode);
      } else {
        // Jika belum dipilih, tambahkan ke pilihan
        _selectedSeats.add(seatCode);
      }
    });
  }

  void _navigateToPayment() {
    int total = _selectedSeats.length * _ticketPrice;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentScreen(
          movie: widget.movie,
          showtime: widget.showtime,
          selectedSeats: _selectedSeats,
          totalPrice: total,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int totalPrice = _selectedSeats.length * _ticketPrice;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Pilih Kursi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 1. Informasi Film Ringkas di Bagian Atas
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            color: Theme.of(
              context,
            ).colorScheme.primaryContainer.withOpacity(0.3),
            child: Row(
              children: [
                // Icon Tiket Kecil
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.movie, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.movie.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${widget.movie.genre}  •  ${widget.movie.duration}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                // Jam Tayang
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    widget.showtime,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 2. Baris Legenda Kursi
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Keterangan Kursi:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 8),
                _buildLegendItem(
                  Colors.white,
                  Colors.grey.shade400,
                  'Tersedia',
                ),
                const SizedBox(height: 6),
                _buildLegendItem(
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primary,
                  'Pilihan Anda',
                ),
                const SizedBox(height: 6),
                _buildLegendItem(
                  Colors.red.shade300,
                  Colors.red.shade400,
                  'Sudah Terisi',
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 3. Layar Bioskop Visual (Screen Cinema)
          Column(
            children: [
              // Efek Cahaya Layar
              const SizedBox(height: 4),
              // Teks Layar
              Text(
                'LAYAR BIOSKOP (SCREEN)',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  // Perulangan untuk setiap baris kursi (A - F)
                  for (var row in _rows)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Label Baris Kiri (A, B, C...)
                          SizedBox(
                            width: 20,
                            child: Text(
                              row,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Perulangan untuk setiap kolom (1 - 8)
                          for (int col = 1; col <= _columns; col++) ...[
                            // Lorong jalan di tengah (antara kolom 4 dan 5)
                            if (col == 5) const SizedBox(width: 24),

                            // Widget Kursi Interaktif
                            _buildInteractiveSeat(row, col),
                          ],

                          const SizedBox(width: 8),
                          // Label Baris Kanan (A, B, C...)
                          SizedBox(
                            width: 20,
                            child: Text(
                              row,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),

          // 5. Panel Ringkasan Pemesanan dan Tombol Lanjut ke Pembayaran di Bawah
          Card(
            margin: EdgeInsets.zero,
            elevation: 10,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Detail Ringkasan Kursi Terpilih
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Kursi Terpilih:',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _selectedSeats.isEmpty
                                  ? 'Belum ada kursi dipilih'
                                  : _selectedSeats.join(', '),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        // Total Harga
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'Total Harga:',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Rp ${totalPrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Tombol Lanjut ke Pembayaran
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _selectedSeats.isEmpty ? null : _navigateToPayment,
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Lanjut ke Pembayaran',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget pembentuk item legenda kursi
  Widget _buildLegendItem(Color fillColor, Color borderColor, String text) {
    return Row(
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: fillColor,
            border: Border.all(color: borderColor, width: 1.5),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  // Widget Kursi Utama Interaktif
  Widget _buildInteractiveSeat(String row, int col) {
    String seatCode = '$row$col';

    return GestureDetector(
      onTap: () => _onSeatTap(seatCode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.symmetric(horizontal: 4.0),
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: _getSeatColor(seatCode),
          border: _getSeatBorder(seatCode),
          borderRadius: BorderRadius.circular(6),
          boxShadow: _selectedSeats.contains(seatCode)
              ? [
                  BoxShadow(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.3),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            '$col',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: _occupiedSeats.contains(seatCode)
                  ? Colors.white
                  : _selectedSeats.contains(seatCode)
                  ? Colors.white
                  : Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
