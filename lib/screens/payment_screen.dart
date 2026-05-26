import 'package:flutter/material.dart';
import '../models/movie.dart';

class PaymentScreen extends StatefulWidget {
  final Movie movie;
  final String showtime;
  final List<String> selectedSeats;
  final int totalPrice;

  const PaymentScreen({
    super.key,
    required this.movie,
    required this.showtime,
    required this.selectedSeats,
    required this.totalPrice,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _isLoading = false;
  bool _isPaid = false;
  String _selectedPaymentMethod = 'QRIS';

  // Daftar simulasi metode pembayaran
  final List<Map<String, dynamic>> _paymentMethods = [
    {'name': 'QRIS', 'icon': Icons.qr_code_2},
    {'name': 'GoPay', 'icon': Icons.wallet},
    {'name': 'OVO', 'icon': Icons.account_balance_wallet},
    {'name': 'Transfer Bank', 'icon': Icons.account_balance},
  ];

  // Proses simulasi pembayaran
  void _processPayment(bool simulateSuccess) async {
    setState(() {
      _isLoading = true;
    });

    // Simulasi loading validasi pembayaran selama 1.5 detik
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (simulateSuccess) {
      // Skenario: Sistem Validasi Pembayaran BERHASIL
      setState(() {
        _isPaid = true;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pembayaran Berhasil! E-Tiket Anda telah terbit.'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      // Skenario: Sistem Validasi Pembayaran GAGAL
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.error, color: Colors.red),
              SizedBox(width: 8),
              Text('Pembayaran Gagal'),
            ],
          ),
          content: const Text(
            'Saldo Anda tidak mencukupi atau transaksi ditolak oleh sistem bank. Silakan coba metode pembayaran lain.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }
  }

  // Simulasi scan QR Code tiket di loket bioskop (Alur terakhir pada Flowchart)
  void _simulateTicketScan() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Simulasi Scan QR Tiket di Loket',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Anda berada di loket masuk studio bioskop. Simulasikan keputusan pemeriksaan tiket oleh admin loket.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  // Skenario QR Validasi GAGAL
                  Expanded(
                    child: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                    ).build(
                      context,
                      onPressed: () {
                        Navigator.pop(context);
                        _showScanResultDialog(false);
                      },
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          'Scan GAGAL\n(Tiket Palsu/Kedaluwarsa)',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Skenario QR Validasi BERHASIL
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(backgroundColor: Colors.green),
                      onPressed: () {
                        Navigator.pop(context);
                        _showScanResultDialog(true);
                      },
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          'Scan BERHASIL\n(Tiket Valid)',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  // Tampilkan dialog hasil scan QR Loket
  void _showScanResultDialog(bool isSuccess) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: Icon(
          isSuccess ? Icons.check_circle : Icons.cancel,
          color: isSuccess ? Colors.green : Colors.red,
          size: 64,
        ),
        title: Text(
          isSuccess ? 'Validasi QR Berhasil!' : 'Validasi QR Gagal!',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          isSuccess
              ? 'Tiket terverifikasi sah. Silakan masuk ke dalam Studio Bioskop! Selamat menonton film ${widget.movie.title}. 🎉'
              : 'Pemberitahuan Sistem: QR Code tiket tidak dikenali, sudah dipindai sebelumnya, atau salah jam tayang! Akses masuk ditolak.',
          textAlign: TextAlign.center,
        ),
        actions: [
          Center(
            child: FilledButton(
              onPressed: () {
                Navigator.pop(context); // Tutup dialog
                if (isSuccess) {
                  // Jika berhasil, kembalikan user ke halaman dashboard utama
                  Navigator.of(context).popUntil((route) => route.isFirst);
                }
              },
              child: Text(isSuccess ? 'Kembali ke Dashboard (Selesai)' : 'Coba Tunjukkan QR Lagi'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isPaid ? 'E-Tiket Bioskop Anda' : 'Pembayaran Tiket',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Memvalidasi pembayaran Anda...'),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: _isPaid ? _buildETicketScreen() : _buildPaymentSummaryScreen(),
            ),
    );
  }

  // TAMPILAN 1: Ringkasan Pembayaran sebelum Bayar
  Widget _buildPaymentSummaryScreen() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Kartu Ringkasan Detail Pesanan
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Ringkasan Pesanan',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Menunggu Pembayaran',
                        style: TextStyle(fontSize: 11, color: Colors.orange.shade800, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                
                // Info Film
                Row(
                  children: [
                    const Icon(Icons.movie, size: 40, color: Colors.blue),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.movie.title,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            widget.movie.genre,
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Detail Jam & Kursi
                _buildInfoRow(Icons.schedule, 'Jadwal Tayang', widget.showtime),
                const SizedBox(height: 8),
                _buildInfoRow(Icons.event_seat, 'Kursi Dipilih', widget.selectedSeats.join(', ')),
                const SizedBox(height: 8),
                _buildInfoRow(
                  Icons.local_play, 
                  'Jumlah Tiket', 
                  '${widget.selectedSeats.length} Kursi (Rp 45.000 / Kursi)'
                ),

                const Divider(height: 24),
                // Total Tagihan
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Pembayaran',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Rp ${widget.totalPrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                      style: TextStyle(
                        fontSize: 20, 
                        fontWeight: FontWeight.bold, 
                        color: Theme.of(context).colorScheme.primary
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),
        const Text(
          'Pilih Metode Pembayaran',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        // Daftar Metode Pembayaran
        Column(
          children: _paymentMethods.map((method) {
            bool isSelected = _selectedPaymentMethod == method['name'];
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                border: Border.all(
                  color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey.shade300,
                  width: isSelected ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: Icon(
                  method['icon'],
                  color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey,
                ),
                title: Text(
                  method['name'],
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                trailing: isSelected
                    ? Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary)
                    : null,
                onTap: () {
                  setState(() {
                    _selectedPaymentMethod = method['name'];
                  });
                },
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 32),

        // Tombol Aksi Simulasi (Pilihan Sukses / Gagal untuk Flowchart)
        const Text(
          'Simulasi Sistem Validasi Pembayaran:',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            // Simulasi Gagal
            Expanded(
              child: OutlinedButton(
                onPressed: () => _processPayment(false),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Bayar (Simulasi Gagal)'),
              ),
            ),
            const SizedBox(width: 12),
            // Simulasi Sukses
            Expanded(
              child: FilledButton(
                onPressed: () => _processPayment(true),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Bayar (Simulasi Sukses)'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  // TAMPILAN 2: Tiket Elektronik & Bukti QR setelah Bayar
  Widget _buildETicketScreen() {
    return Column(
      children: [
        const SizedBox(height: 8),
        const Icon(Icons.check_circle, color: Colors.green, size: 64),
        const SizedBox(height: 12),
        const Text(
          'Pemesanan Berhasil!',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const Text(
          'Silakan tunjukkan e-tiket di bawah ini ke loket masuk bioskop.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 24),

        // Visual Tiket Bioskop Mewah (Ticket Card)
        Card(
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Column(
            children: [
              // Bagian Atas Tiket
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.4),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.confirmation_num, color: Colors.white, size: 32),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.movie.title,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Genre: ${widget.movie.genre}',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Bagian Detail Tengah Tiket
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildTicketInfoColumn('Jadwal Jam', widget.showtime),
                        _buildTicketInfoColumn('Nomor Kursi', widget.selectedSeats.join(', ')),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildTicketInfoColumn('Status', 'LUNAS (PAID)', valueColor: Colors.green),
                        _buildTicketInfoColumn(
                          'Total Bayar', 
                          'Rp ${widget.totalPrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}'
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Garis Sobek Tiket (Ticket Dotted Divider)
              Row(
                children: List.generate(
                  30,
                  (index) => Expanded(
                    child: Container(
                      color: index % 2 == 0 ? Colors.transparent : Colors.grey.shade400,
                      height: 2.5,
                    ),
                  ),
                ),
              ),

              // Bagian Bawah Tiket: Mock QR Code (Mempersentasikan Generate & Tampilkan QR Code)
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const Text(
                      'PINDAI LOKET MASUK (STUDIO ENTRY)',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    
                    // Widget QR Code buatan sendiri (tanpa dependensi rumit luar)
                    _buildMockQRCode(),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),

        // Tombol Aksi Akhir Flowchart: Simulasi Scan QR di Loket
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _simulateTicketScan,
            icon: const Icon(Icons.center_focus_weak),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            label: const Text(
              'Tunjukkan QR ke Loket Bioskop',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  // Membuat QR Code prosedural menggunakan murni Flutter widgets
  Widget _buildMockQRCode() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            spreadRadius: 2,
          )
        ],
        border: Border.all(color: Colors.grey.shade200, width: 2),
      ),
      child: Column(
        children: [
          // Grid QR Code (14 baris x 14 kolom)
          Container(
            width: 140,
            height: 140,
            color: Colors.white,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(14, (rIndex) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(14, (cIndex) {
                    // Penentuan warna pixel hitam/putih untuk membentuk pola QR
                    bool isBlack = false;
                    
                    // Penanda Sudut QR (Anchor Markers)
                    bool isTopLeftAnchor = (rIndex < 4 && cIndex < 4);
                    bool isTopRightAnchor = (rIndex < 4 && cIndex >= 10);
                    bool isBottomLeftAnchor = (rIndex >= 10 && cIndex < 4);
                    
                    if (isTopLeftAnchor) {
                      isBlack = (rIndex == 0 || rIndex == 3 || cIndex == 0 || cIndex == 3) || (rIndex == 1 && cIndex == 1);
                    } else if (isTopRightAnchor) {
                      int adjustedCol = cIndex - 10;
                      isBlack = (rIndex == 0 || rIndex == 3 || adjustedCol == 0 || adjustedCol == 3) || (rIndex == 1 && adjustedCol == 1);
                    } else if (isBottomLeftAnchor) {
                      int adjustedRow = rIndex - 10;
                      isBlack = (adjustedRow == 0 || adjustedRow == 3 || cIndex == 0 || cIndex == 3) || (adjustedRow == 1 && cIndex == 1);
                    } else {
                      // Pola statis buatan sendiri untuk bagian tengah agar terlihat real
                      isBlack = (rIndex * 7 + cIndex * 3) % 2 == 0 || (rIndex + cIndex) % 3 == 0;
                    }
                    
                    return Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isBlack ? Colors.black : Colors.white,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    );
                  }),
                );
              }),
            ),
          ),
          const SizedBox(height: 12),
          // Booking ID unik
          Text(
            'BOOKING-ID: NTN-${widget.movie.id}${widget.selectedSeats.length}${widget.showtime.replaceAll(':', '')}',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  // Widget pembentuk baris info
  Widget _buildInfoRow(IconData icon, String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Text(
          '$title: ',
          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  // Widget pembentuk kolom info tiket
  Widget _buildTicketInfoColumn(String title, String value, {Color? valueColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14, 
            fontWeight: FontWeight.bold,
            color: valueColor ?? Colors.black87,
          ),
        ),
      ],
    );
  }
}