// screens/owner_booking_requests_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/booking.dart';
import '../services/booking_service.dart';

class OwnerBookingRequestsScreen extends StatefulWidget {
  final String userEmail;

  const OwnerBookingRequestsScreen({super.key, required this.userEmail});

  @override
  State<OwnerBookingRequestsScreen> createState() =>
      _OwnerBookingRequestsScreenState();
}

class _OwnerBookingRequestsScreenState
    extends State<OwnerBookingRequestsScreen> {
  final BookingService _bookingService = BookingService();
  List<Booking> _bookings = [];
  String _selectedFilter = 'pending';

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  void _loadBookings() {
    setState(() {
      _bookings = _bookingService.getAllBookings();
    });
  }

  List<Booking> get _filteredBookings {
    switch (_selectedFilter) {
      case 'pending':
        return _bookings
            .where((b) => b.status == BookingStatus.pending)
            .toList();
      case 'confirmed':
        return _bookings
            .where((b) => b.status == BookingStatus.confirmed)
            .toList();
      case 'paid':
        return _bookings
            .where(
              (b) =>
                  b.status == BookingStatus.paid ||
                  b.status == BookingStatus.active,
            )
            .toList();
      case 'cancelled':
        return _bookings
            .where((b) => b.status == BookingStatus.cancelled)
            .toList();
      default:
        return _bookings;
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  void _approveBooking(Booking booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Setujui Booking'),
        content: Text(
          'Setujui booking dari ${booking.userEmail.split('@')[0]} untuk ${booking.kost.name}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              _bookingService.confirmBooking(booking.id);
              Navigator.pop(context);
              _loadBookings();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Booking berhasil disetujui!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Setujui'),
          ),
        ],
      ),
    );
  }

  void _rejectBooking(Booking booking) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tolak Booking'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Tolak booking dari ${booking.userEmail.split('@')[0]} untuk ${booking.kost.name}?',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Alasan (Opsional)',
                border: OutlineInputBorder(),
                hintText: 'Masukkan alasan penolakan...',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              _bookingService.cancelBooking(booking.id);
              Navigator.pop(context);
              _loadBookings();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Booking ditolak'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Tolak'),
          ),
        ],
      ),
    );
  }

  void _viewBookingDetail(Booking booking) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        expand: false,
        builder: (context, scrollController) =>
            _buildBookingDetailContent(booking, scrollController),
      ),
    );
  }

  Widget _buildBookingDetailContent(
    Booking booking,
    ScrollController scrollController,
  ) {
    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Detail Booking',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildDetailSection('Informasi Penyewa', [
          _buildDetailRow('Email', booking.userEmail),
          _buildDetailRow('ID Booking', booking.id),
          _buildDetailRow('Tanggal Booking', _formatDate(booking.bookingDate)),
        ]),
        const SizedBox(height: 12),
        _buildDetailSection('Informasi Kost', [
          _buildDetailRow('Nama Kost', booking.kost.name),
          _buildDetailRow('Alamat', booking.kost.address),
          _buildDetailRow('Nomor Kamar', booking.roomDetail.roomNumber),
        ]),
        const SizedBox(height: 12),
        _buildDetailSection('Status', [
          Text(
            booking.getStatusText(),
            style: TextStyle(
              color: _getStatusColor(booking.status),
              fontWeight: FontWeight.bold,
            ),
          ),
        ]),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredBookings = _filteredBookings;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Permintaan Booking'),
        backgroundColor: const Color(0xFF6B46C1),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Filter Tabs
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildFilterChip('Semua', 'all', _bookings.length),
                  _buildFilterChip(
                    'Menunggu',
                    'pending',
                    _bookings
                        .where((b) => b.status == BookingStatus.pending)
                        .length,
                  ),
                  _buildFilterChip(
                    'Disetujui',
                    'confirmed',
                    _bookings
                        .where((b) => b.status == BookingStatus.confirmed)
                        .length,
                  ),
                  _buildFilterChip(
                    'Dibayar',
                    'paid',
                    _bookings
                        .where((b) => b.status == BookingStatus.paid)
                        .length,
                  ),
                  _buildFilterChip(
                    'Ditolak',
                    'cancelled',
                    _bookings
                        .where((b) => b.status == BookingStatus.cancelled)
                        .length,
                  ),
                ],
              ),
            ),
          ),

          // Booking List
          Expanded(
            child: filteredBookings.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
                    onRefresh: () async => _loadBookings(),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredBookings.length,
                      itemBuilder: (context, index) {
                        return _buildBookingCard(filteredBookings[index]);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, int count) {
    final isSelected = _selectedFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        label: Text('$label (${count.toString()})'),
        onSelected: (_) => setState(() => _selectedFilter = value),
        selectedColor: const Color(0xFF6B46C1),
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
          fontWeight: FontWeight.bold,
        ),
        backgroundColor: Colors.grey[200],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            'Tidak ada permintaan',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Permintaan booking akan muncul di sini',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingCard(Booking booking) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _viewBookingDetail(booking),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: booking.kost.getPrimaryColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      booking.kost.getKostIcon(),
                      color: booking.kost.getPrimaryColor(),
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking.userEmail.split('@')[0],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          booking.kost.name,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(booking.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      booking.getStatusText(),
                      style: TextStyle(
                        color: _getStatusColor(booking.status),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Kamar ${booking.roomDetail.roomNumber}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          '${_formatDate(booking.checkInDate)} - ${_formatDate(booking.checkOutDate)}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    NumberFormat.currency(
                      locale: 'id',
                      symbol: 'Rp ',
                      decimalDigits: 0,
                    ).format(booking.totalPrice + booking.depositAmount),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: booking.kost.getPrimaryColor(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const Divider(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    bool isHighlighted = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: TextStyle(color: Colors.grey[600])),
          ),
          const Text(': '),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
                color: isHighlighted ? const Color(0xFF6B46C1) : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return Colors.orange;
      case BookingStatus.confirmed:
        return Colors.blue;
      case BookingStatus.paid:
      case BookingStatus.active:
        return Colors.green;
      case BookingStatus.cancelled:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
