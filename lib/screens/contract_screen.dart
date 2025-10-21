// screens/contract_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'dart:io';
import '../models/booking.dart';
import '../services/booking_service.dart';

class ContractScreen extends StatefulWidget {
  final Booking booking;

  const ContractScreen({super.key, required this.booking});

  @override
  State<ContractScreen> createState() => _ContractScreenState();
}

class _ContractScreenState extends State<ContractScreen> {
  final BookingService _bookingService = BookingService();
  Contract? _contract;
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    _loadContract();
  }

  void _loadContract() {
    setState(() {
      _contract = _bookingService.getContractByBookingId(widget.booking.id);
    });
  }

  Future<void> _generateAndDownloadPDF() async {
    if (_contract == null) return;

    setState(() {
      _isGenerating = true;
    });

    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) {
            return [
              // Header
              pw.Center(
                child: pw.Text(
                  'KONTRAK SEWA KOST',
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Center(
                child: pw.Text(
                  'No: ${_contract!.contractNumber}',
                  style: const pw.TextStyle(fontSize: 12),
                ),
              ),
              pw.SizedBox(height: 24),

              // Parties
              pw.Text(
                'Pada hari ini, ${DateFormat('EEEE, dd MMMM yyyy', 'id').format(_contract!.signedDate)}, telah dibuat dan ditandatangani Kontrak Sewa Kost antara:',
                style: const pw.TextStyle(fontSize: 11),
                textAlign: pw.TextAlign.justify,
              ),
              pw.SizedBox(height: 16),

              // Pihak Pertama
              pw.Text(
                'PIHAK PERTAMA (PEMILIK)',
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              _buildInfoRow('Nama', _contract!.landlordName),
              _buildInfoRow('Alamat', widget.booking.kost.address),
              _buildInfoRow('Telepon', widget.booking.kost.phoneNumber),
              pw.SizedBox(height: 16),

              // Pihak Kedua
              pw.Text(
                'PIHAK KEDUA (PENYEWA)',
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              _buildInfoRow('Nama', _contract!.tenantName),
              _buildInfoRow('Email', widget.booking.userEmail),
              pw.SizedBox(height: 24),

              // Detail Sewa
              pw.Text(
                'DETAIL SEWA',
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              _buildInfoRow('Nama Kost', widget.booking.kost.name),
              _buildInfoRow(
                'Nomor Kamar',
                widget.booking.roomDetail.roomNumber,
              ),
              _buildInfoRow(
                'Ukuran Kamar',
                '${widget.booking.roomDetail.size}m²',
              ),
              _buildInfoRow('Lantai', widget.booking.roomDetail.floor),
              _buildInfoRow(
                'Tanggal Mulai',
                DateFormat('dd MMMM yyyy').format(_contract!.startDate),
              ),
              _buildInfoRow(
                'Tanggal Selesai',
                DateFormat('dd MMMM yyyy').format(_contract!.endDate),
              ),
              _buildInfoRow('Durasi', '${widget.booking.duration} bulan'),
              pw.SizedBox(height: 16),

              // Biaya
              pw.Text(
                'BIAYA SEWA',
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              _buildInfoRow(
                'Harga per Bulan',
                NumberFormat.currency(
                  locale: 'id',
                  symbol: 'Rp ',
                  decimalDigits: 0,
                ).format(widget.booking.kost.pricePerMonth),
              ),
              _buildInfoRow(
                'Total Sewa',
                NumberFormat.currency(
                  locale: 'id',
                  symbol: 'Rp ',
                  decimalDigits: 0,
                ).format(widget.booking.totalPrice),
              ),
              _buildInfoRow(
                'Deposit',
                NumberFormat.currency(
                  locale: 'id',
                  symbol: 'Rp ',
                  decimalDigits: 0,
                ).format(widget.booking.depositAmount),
              ),
              pw.SizedBox(height: 24),

              // Syarat dan Ketentuan
              pw.Text(
                'SYARAT DAN KETENTUAN',
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                _contract!.terms,
                style: const pw.TextStyle(fontSize: 10),
                textAlign: pw.TextAlign.justify,
              ),
              pw.SizedBox(height: 32),

              // Tanda Tangan
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('PIHAK PERTAMA'),
                      pw.SizedBox(height: 60),
                      pw.Text('(___________________)'),
                      pw.Text(
                        _contract!.landlordName,
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('PIHAK KEDUA'),
                      pw.SizedBox(height: 60),
                      pw.Text('(___________________)'),
                      pw.Text(
                        _contract!.tenantName,
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                ],
              ),
            ];
          },
        ),
      );

      // Save PDF
      final output = await getApplicationDocumentsDirectory();
      final file = File(
        '${output.path}/kontrak_${_contract!.contractNumber.replaceAll('/', '_')}.pdf',
      );
      await file.writeAsBytes(await pdf.save());

      setState(() {
        _isGenerating = false;
      });

      // Show success and open file
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kontrak berhasil diunduh!'),
            backgroundColor: Colors.green,
          ),
        );
        OpenFile.open(file.path);
      }
    } catch (e) {
      setState(() {
        _isGenerating = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal membuat PDF: $e')));
      }
    }
  }

  pw.Widget _buildInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 150,
            child: pw.Text(label, style: const pw.TextStyle(fontSize: 10)),
          ),
          pw.Text(': ', style: const pw.TextStyle(fontSize: 10)),
          pw.Expanded(
            child: pw.Text(
              value,
              style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_contract == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Kontrak Sewa'),
          backgroundColor: widget.booking.kost.getPrimaryColor(),
          foregroundColor: Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kontrak Sewa'),
        backgroundColor: widget.booking.kost.getPrimaryColor(),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _isGenerating ? null : _generateAndDownloadPDF,
            tooltip: 'Download PDF',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSuccessCard(),
          const SizedBox(height: 16),
          _buildContractInfoCard(),
          const SizedBox(height: 16),
          _buildPartiesCard(),
          const SizedBox(height: 16),
          _buildRentalDetailsCard(),
          const SizedBox(height: 16),
          _buildTermsCard(),
          const SizedBox(height: 24),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildSuccessCard() {
    return Card(
      elevation: 4,
      color: Colors.green.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Icon(Icons.check, size: 48, color: Colors.white),
            ),
            const SizedBox(height: 16),
            const Text(
              'Pembayaran Berhasil!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Kontrak sewa Anda telah dibuat',
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContractInfoCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.description,
                  color: widget.booking.kost.getPrimaryColor(),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Informasi Kontrak',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildInfoRow2('Nomor Kontrak', _contract!.contractNumber),
            _buildInfoRow2(
              'Tanggal',
              DateFormat('dd MMMM yyyy').format(_contract!.signedDate),
            ),
            _buildInfoRow2('Status', 'Aktif', valueColor: Colors.green),
          ],
        ),
      ),
    );
  }

  Widget _buildPartiesCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.people,
                  color: widget.booking.kost.getPrimaryColor(),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Pihak yang Terlibat',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 24),
            const Text(
              'PIHAK PERTAMA (Pemilik)',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildInfoRow2('Nama', _contract!.landlordName),
            _buildInfoRow2('Telepon', widget.booking.kost.phoneNumber),
            const SizedBox(height: 16),
            const Text(
              'PIHAK KEDUA (Penyewa)',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildInfoRow2('Nama', _contract!.tenantName),
            _buildInfoRow2('Email', widget.booking.userEmail),
          ],
        ),
      ),
    );
  }

  Widget _buildRentalDetailsCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.home, color: widget.booking.kost.getPrimaryColor()),
                const SizedBox(width: 8),
                const Text(
                  'Detail Sewa',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildInfoRow2('Kost', widget.booking.kost.name),
            _buildInfoRow2('Kamar', widget.booking.roomDetail.roomNumber),
            _buildInfoRow2('Ukuran', '${widget.booking.roomDetail.size}m²'),
            _buildInfoRow2('Lantai', widget.booking.roomDetail.floor),
            _buildInfoRow2(
              'Periode',
              '${DateFormat('dd MMM yyyy').format(_contract!.startDate)} - ${DateFormat('dd MMM yyyy').format(_contract!.endDate)}',
            ),
            _buildInfoRow2('Durasi', '${widget.booking.duration} bulan'),
            const Divider(height: 24),
            _buildInfoRow2(
              'Biaya Sewa',
              NumberFormat.currency(
                locale: 'id',
                symbol: 'Rp ',
                decimalDigits: 0,
              ).format(widget.booking.totalPrice),
              valueColor: widget.booking.kost.getPrimaryColor(),
            ),
            _buildInfoRow2(
              'Deposit',
              NumberFormat.currency(
                locale: 'id',
                symbol: 'Rp ',
                decimalDigits: 0,
              ).format(widget.booking.depositAmount),
              valueColor: widget.booking.kost.getPrimaryColor(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTermsCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.gavel, color: widget.booking.kost.getPrimaryColor()),
                const SizedBox(width: 8),
                const Text(
                  'Syarat dan Ketentuan',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 24),
            Text(
              _contract!.terms,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow2(String label, String value, {Color? valueColor}) {
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
              style: TextStyle(fontWeight: FontWeight.w600, color: valueColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _isGenerating ? null : _generateAndDownloadPDF,
                icon: _isGenerating
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.download),
                label: Text(_isGenerating ? 'Mengunduh...' : 'Download PDF'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: widget.booking.kost.getPrimaryColor(),
                  side: BorderSide(
                    color: widget.booking.kost.getPrimaryColor(),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                icon: const Icon(Icons.home, color: Colors.white),
                label: const Text(
                  'Kembali ke Home',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.booking.kost.getPrimaryColor(),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
