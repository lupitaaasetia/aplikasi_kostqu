// screens/kost_detail_screen.dart
import 'package:flutter/material.dart';
import '../models/kost.dart';

class KostDetailScreen extends StatefulWidget {
  final BaseKost kost;

  const KostDetailScreen({super.key, required this.kost});

  @override
  State<KostDetailScreen> createState() => _KostDetailScreenState();
}

class _KostDetailScreenState extends State<KostDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isBookmarked = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = widget.kost.getPrimaryColor();
    final IconData kostIcon = widget.kost.getKostIcon();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with image and gradient
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: primaryColor,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      primaryColor.withOpacity(0.8),
                      primaryColor.withOpacity(0.6),
                    ],
                  ),
                ),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Icon(kostIcon, size: 60, color: primaryColor),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            widget.kost.getKostType(),
                            style: TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Content sections
          SliverToBoxAdapter(
            child: Container(
              color: Colors.grey[50],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderSection(),
                  const SizedBox(height: 8),
                  _buildDescriptionSection(),
                  const SizedBox(height: 8),
                  _buildTypeSpecificSection(),
                  const SizedBox(height: 8),
                  _buildFacilitiesSection(),
                  const SizedBox(height: 8),
                  _buildContactSection(),
                  const SizedBox(height: 8),
                  _buildStatisticsSection(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.kost.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.location_on, color: Colors.red[400], size: 18),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  widget.kost.address,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: widget.kost.getPrimaryColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          widget.kost.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: widget.kost.status == KostStatus.available
                          ? Colors.green
                          : Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      widget.kost.status.displayName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    widget.kost.getFormattedPrice(),
                    style: TextStyle(
                      color: widget.kost.getPrimaryColor(),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Updated: ${_formatDate(widget.kost.updatedAt)}',
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection() {
    return Container(
      color: Colors.white,
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.description,
                color: widget.kost.getPrimaryColor(),
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Deskripsi',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            widget.kost.description,
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeSpecificSection() {
    // Using Polymorphism - different behavior based on kost type
    if (widget.kost is FemaleKost) {
      FemaleKost femaleKost = widget.kost as FemaleKost;
      return _buildInfoSection('Informasi Kost Perempuan', Icons.woman, [
        InfoItem('Jam Malam', femaleKost.curfewTime),
        InfoItem(
          'Security Guard',
          femaleKost.hasSecurityGuard ? 'Ada' : 'Tidak ada',
        ),
      ], Colors.pink);
    } else if (widget.kost is MaleKost) {
      MaleKost maleKost = widget.kost as MaleKost;
      return _buildInfoSection('Informasi Kost Laki-laki', Icons.man, [
        InfoItem(
          'Workspace',
          maleKost.hasWorkspace ? 'Tersedia' : 'Tidak tersedia',
        ),
        InfoItem(
          'Smoking Policy',
          maleKost.allowsSmoking ? 'Diperbolehkan' : 'Dilarang',
        ),
      ], Colors.blue);
    } else if (widget.kost is MixedKost) {
      MixedKost mixedKost = widget.kost as MixedKost;
      return _buildInfoSection('Informasi Kost Campur', Icons.people, [
        InfoItem('Kamar Pria', '${mixedKost.maleRooms} kamar'),
        InfoItem('Kamar Wanita', '${mixedKost.femaleRooms} kamar'),
        InfoItem('Total Kamar', '${mixedKost.totalRooms} kamar'),
        InfoItem(
          'Pintu Masuk',
          mixedKost.hasSeparateEntrance ? 'Terpisah' : 'Bersama',
        ),
      ], Colors.green);
    }
    return const SizedBox.shrink();
  }

  Widget _buildInfoSection(
    String title,
    IconData icon,
    List<InfoItem> items,
    Color color,
  ) {
    return Container(
      color: Colors.white,
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item.label,
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  Text(
                    item.value,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
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

  Widget _buildFacilitiesSection() {
    return Container(
      color: Colors.white,
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.home_repair_service,
                color: widget.kost.getPrimaryColor(),
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Fasilitas',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 4,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: widget.kost.facilities.length,
            itemBuilder: (context, index) {
              final facility = widget.kost.facilities[index];
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: facility.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: facility.color.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(facility.icon, size: 16, color: facility.color),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        facility.name,
                        style: TextStyle(
                          color: facility.color,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection() {
    return Container(
      color: Colors.white,
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.contact_phone,
                color: widget.kost.getPrimaryColor(),
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Kontak & Lokasi',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Menghubungi ${widget.kost.phoneNumber}'),
                    backgroundColor: const Color(0xFF25D366),
                  ),
                );
              },
              icon: const Icon(Icons.chat, color: Colors.white),
              label: Text(
                'Hubungi Pemilik: ${widget.kost.phoneNumber}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF25D366),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsSection() {
    return Container(
      color: Colors.white,
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.analytics,
                color: widget.kost.getPrimaryColor(),
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Informasi Detail',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Dibuat',
                  _formatDate(widget.kost.createdAt),
                  Icons.calendar_today,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Update',
                  _formatDate(widget.kost.updatedAt),
                  Icons.update,
                  Colors.purple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
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
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  _isBookmarked = !_isBookmarked;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      _isBookmarked
                          ? 'Kost disimpan dalam bookmark!'
                          : 'Kost dihapus dari bookmark!',
                    ),
                    backgroundColor: widget.kost.getPrimaryColor(),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              icon: Icon(
                _isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
              ),
              label: Text(_isBookmarked ? 'Tersimpan' : 'Simpan'),
              style: OutlinedButton.styleFrom(
                foregroundColor: widget.kost.getPrimaryColor(),
                side: BorderSide(color: widget.kost.getPrimaryColor()),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: widget.kost.status == KostStatus.available
                  ? () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Menghubungi ${widget.kost.phoneNumber}',
                          ),
                          backgroundColor: widget.kost.getPrimaryColor(),
                        ),
                      );
                    }
                  : null,
              icon: const Icon(Icons.chat, color: Colors.white),
              label: Text(
                widget.kost.status == KostStatus.available
                    ? 'Chat Pemilik'
                    : widget.kost.status.displayName,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.kost.status == KostStatus.available
                    ? widget.kost.getPrimaryColor()
                    : Colors.grey,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

// Helper classes
class InfoItem {
  final String label;
  final String value;

  InfoItem(this.label, this.value);
}
