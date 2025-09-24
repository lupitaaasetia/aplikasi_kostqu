// services/kost_service.dart
import '../models/facility.dart';
import '../models/kost.dart';

enum SortCriteria { name, price, rating, type, distance, createdDate }

// Statistics model
class KostStatistics {
  final int totalKost;
  final double averagePrice;
  final double averageRating;
  final String priceRange;
  final Map<String, int> kostTypeDistribution;
  final List<String> topFacilities;

  KostStatistics({
    required this.totalKost,
    required this.averagePrice,
    required this.averageRating,
    required this.priceRange,
    required this.kostTypeDistribution,
    required this.topFacilities,
  });
}

// Main service class with business logic
class KostService {
  List<BaseKost> _allKost = [];

  // Singleton pattern
  static final KostService _instance = KostService._internal();
  factory KostService() => _instance;
  KostService._internal();

  // Getter for all kost data
  List<BaseKost> get allKost => List.unmodifiable(_allKost);

  // Initialize with dummy data
  void initializeData() {
    if (_allKost.isNotEmpty) return; // Already initialized

    _allKost = [
      // Female Kosts
      FemaleKost(
        id: '1',
        name: 'Kost Putri Melati',
        address: 'Jl. Mawar No. 15, Magetan',
        description: 'Kost nyaman khusus putri dengan keamanan 24 jam',
        pricePerMonth: 800000,
        rating: 4.5,
        facilities: [
          Facility.fromString('Kamar Mandi Dalam'),
          Facility.fromString('AC'),
          Facility.fromString('WiFi'),
          Facility.fromString('Include Listrik'),
        ],
        phoneNumber: '08123456789',
        latitude: -7.6298,
        longitude: 111.3467,
        hasSecurityGuard: true,
        curfewTime: '22:00',
      ),

      FemaleKost(
        id: '2',
        name: 'Kost Permata Putri',
        address: 'Jl. Seroja No. 8, Magetan',
        description: 'Kost eksklusif untuk mahasiswi dengan fasilitas lengkap',
        pricePerMonth: 1200000,
        rating: 4.8,
        facilities: [
          Facility.fromString('Kamar Mandi Dalam'),
          Facility.fromString('AC'),
          Facility.fromString('WiFi'),
          Facility.fromString('Include Listrik'),
          Facility.fromString('Parkir Motor'),
        ],
        phoneNumber: '08123456788',
        latitude: -7.6301,
        longitude: 111.3470,
        hasSecurityGuard: true,
        curfewTime: '23:00',
      ),

      // Male Kosts
      MaleKost(
        id: '3',
        name: 'Kost Putra Mandiri',
        address: 'Jl. Diponegoro No. 25, Magetan',
        description: 'Kost strategis untuk mahasiswa dengan suasana kondusif',
        pricePerMonth: 400000,
        rating: 4.2,
        facilities: [
          Facility.fromString('Kamar Mandi Luar'),
          Facility.fromString('Kipas Angin'),
          Facility.fromString('WiFi'),
          Facility.fromString('Parkir Motor'),
        ],
        phoneNumber: '08123456787',
        latitude: -7.6295,
        longitude: 111.3465,
        allowsSmoking: false,
        hasWorkspace: true,
      ),

      MaleKost(
        id: '4',
        name: 'Kost Bahagia Putra',
        address: 'Jl. Sudirman No. 12, Magetan',
        description: 'Kost modern dengan fasilitas workspace untuk mahasiswa',
        pricePerMonth: 800000,
        rating: 4.6,
        facilities: [
          Facility.fromString('Kamar Mandi Dalam'),
          Facility.fromString('AC'),
          Facility.fromString('WiFi'),
          Facility.fromString('Include Listrik'),
          Facility.fromString('Workspace'),
        ],
        phoneNumber: '08123456786',
        latitude: -7.6292,
        longitude: 111.3462,
        allowsSmoking: false,
        hasWorkspace: true,
      ),

      // Mixed Kosts
      MixedKost(
        id: '5',
        name: 'Kost Harmoni Campur',
        address: 'Jl. Ahmad Yani No. 30, Magetan',
        description: 'Kost campur dengan pintu masuk terpisah',
        pricePerMonth: 700000,
        rating: 4.3,
        facilities: [
          Facility.fromString('Kamar Mandi Dalam'),
          Facility.fromString('Kipas Angin '),
          Facility.fromString('AC'),
          Facility.fromString('WiFi'),
          Facility.fromString('Parkir Motor'),
        ],
        phoneNumber: '08123456785',
        latitude: -7.6305,
        longitude: 111.3475,
        hasSeparateEntrance: true,
        maleRooms: 6,
        femaleRooms: 4,
      ),

      // More sample data...
      FemaleKost(
        id: '7',
        name: 'Kost Sari Putri',
        address: 'Jl. Kartini No. 22, Magetan',
        description: 'Kost bersih dan aman untuk putri',
        pricePerMonth: 650000,
        rating: 4.1,
        facilities: [
          Facility.fromString('Kamar Mandi Luar'),
          Facility.fromString('Kipas Angin'),
          Facility.fromString('WiFi'),
          Facility.fromString('Dapur Bersama'),
          Facility.fromString('Include listrik'),
        ],
        phoneNumber: '08123456783',
        latitude: -7.6308,
        longitude: 111.3478,
        hasSecurityGuard: false,
        curfewTime: '21:30',
      ),

      MaleKost(
        id: '8',
        name: 'Kost Bintang Putra',
        address: 'Jl. Gatot Subroto No. 5, Magetan',
        description: 'Kost strategis dekat kampus',
        pricePerMonth: 650000,
        rating: 4.0,
        facilities: [
          Facility.fromString('Kamar Mandi Luar'),
          Facility.fromString('Kipas Angin'),
          Facility.fromString('WiFi'),
          Facility.fromString('Laundry'),
          Facility.fromString('Include Listrik'),
        ],
        phoneNumber: '08123456782',
        latitude: -7.6285,
        longitude: 111.3455,
        allowsSmoking: true,
        hasWorkspace: false,
      ),
    ];
  }

  // Search functionality
  List<BaseKost> searchKost(String query) {
    if (query.isEmpty) return List.from(_allKost);

    return _allKost.where((kost) => kost.matchesQuery(query)).toList();
  }

  // Sorting functionality
  List<BaseKost> sortKost(
    List<BaseKost> kostList,
    SortCriteria criteria, {
    bool ascending = true,
  }) {
    List<BaseKost> sorted = List.from(kostList);

    switch (criteria) {
      case SortCriteria.name:
        sorted.sort(
          (a, b) =>
              ascending ? a.name.compareTo(b.name) : b.name.compareTo(a.name),
        );
        break;
      case SortCriteria.price:
        sorted.sort(
          (a, b) => ascending
              ? a.compareByPrice(b)
              : a.compareByPrice(b, ascending: false),
        );
        break;
      case SortCriteria.rating:
        sorted.sort(
          (a, b) => ascending
              ? a.compareByRating(b, ascending: true)
              : a.compareByRating(b),
        );
        break;
      case SortCriteria.type:
        sorted.sort(
          (a, b) => ascending
              ? a.getKostType().compareTo(b.getKostType())
              : b.getKostType().compareTo(a.getKostType()),
        );
        break;
      case SortCriteria.createdDate:
        sorted.sort(
          (a, b) => ascending
              ? a.createdAt.compareTo(b.createdAt)
              : b.createdAt.compareTo(a.createdAt),
        );
        break;
      case SortCriteria.distance:
        // Default reference point (center of Magetan)
        double refLat = -7.6298;
        double refLng = 111.3467;
        sorted.sort(
          (a, b) =>
              a.compareByDistance(b, refLat, refLng, ascending: ascending),
        );
        break;
    }

    return sorted;
  }

  // Filter by facilities
  List<BaseKost> filterByFacilities(List<String> requiredFacilities) {
    return _allKost.where((kost) {
      return requiredFacilities.every((facility) => kost.hasFacility(facility));
    }).toList();
  }

  // Filter by price range
  List<BaseKost> filterByPriceRange(int minPrice, int maxPrice) {
    return _allKost.where((kost) {
      return kost.pricePerMonth >= minPrice && kost.pricePerMonth <= maxPrice;
    }).toList();
  }

  // Filter by rating
  List<BaseKost> filterByRating(double minRating) {
    return _allKost.where((kost) => kost.rating >= minRating).toList();
  }

  // Filter by kost type
  List<BaseKost> filterByType(String kostType) {
    return _allKost.where((kost) => kost.getKostType() == kostType).toList();
  }

  // Get statistics
  KostStatistics getStatistics() {
    if (_allKost.isEmpty) {
      return KostStatistics(
        totalKost: 0,
        averagePrice: 0,
        averageRating: 0,
        priceRange: '0 - 0',
        kostTypeDistribution: {},
        topFacilities: [],
      );
    }

    // Calculate statistics
    int totalKost = _allKost.length;
    double averagePrice =
        _allKost.map((k) => k.pricePerMonth).reduce((a, b) => a + b) /
        totalKost;
    double averageRating =
        _allKost.map((k) => k.rating).reduce((a, b) => a + b) / totalKost;

    int minPrice = _allKost
        .map((k) => k.pricePerMonth)
        .reduce((a, b) => a < b ? a : b);
    int maxPrice = _allKost
        .map((k) => k.pricePerMonth)
        .reduce((a, b) => a > b ? a : b);
    String priceRange =
        'Rp ${_formatPrice(minPrice)} - Rp ${_formatPrice(maxPrice)}';

    // Type distribution
    Map<String, int> typeDistribution = {};
    for (var kost in _allKost) {
      String type = kost.getKostType();
      typeDistribution[type] = (typeDistribution[type] ?? 0) + 1;
    }

    // Top facilities
    Map<String, int> facilityCount = {};
    for (var kost in _allKost) {
      for (var facility in kost.facilities) {
        facilityCount[facility.name] = (facilityCount[facility.name] ?? 0) + 1;
      }
    }

    List<String> topFacilities =
        (facilityCount.entries.toList()
              ..sort((a, b) => b.value.compareTo(a.value))
              ..take(10).map((e) => e.key).toList())
            .cast<String>();

    return KostStatistics(
      totalKost: totalKost,
      averagePrice: averagePrice,
      averageRating: averageRating,
      priceRange: priceRange,
      kostTypeDistribution: typeDistribution,
      topFacilities: topFacilities,
    );
  }

  // Get kost by ID
  BaseKost? getKostById(String id) {
    try {
      return _allKost.firstWhere((kost) => kost.id == id);
    } catch (e) {
      return null;
    }
  }

  // Add new kost
  void addKost(BaseKost kost) {
    _allKost.add(kost);
  }

  // Update kost
  bool updateKost(BaseKost updatedKost) {
    int index = _allKost.indexWhere((kost) => kost.id == updatedKost.id);
    if (index != -1) {
      _allKost[index] = updatedKost;
      return true;
    }
    return false;
  }

  // Delete kost
  bool deleteKost(String id) {
    int initialLength = _allKost.length;
    _allKost.removeWhere((kost) => kost.id == id);
    return _allKost.length < initialLength;
  }

  // Private helper method
  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  // Advanced search with multiple criteria
  List<BaseKost> advancedSearch({
    String? query,
    String? kostType,
    int? minPrice,
    int? maxPrice,
    double? minRating,
    List<String>? requiredFacilities,
    SortCriteria sortBy = SortCriteria.name,
    bool ascending = true,
  }) {
    List<BaseKost> results = List.from(_allKost);

    // Apply search query
    if (query != null && query.isNotEmpty) {
      results = results.where((kost) => kost.matchesQuery(query)).toList();
    }

    // Apply type filter
    if (kostType != null && kostType.isNotEmpty && kostType != 'Semua') {
      results = results
          .where((kost) => kost.getKostType() == kostType)
          .toList();
    }

    // Apply price range filter
    if (minPrice != null) {
      results = results
          .where((kost) => kost.pricePerMonth >= minPrice)
          .toList();
    }
    if (maxPrice != null) {
      results = results
          .where((kost) => kost.pricePerMonth <= maxPrice)
          .toList();
    }

    // Apply rating filter
    if (minRating != null) {
      results = results.where((kost) => kost.rating >= minRating).toList();
    }

    // Apply facilities filter
    if (requiredFacilities != null && requiredFacilities.isNotEmpty) {
      results = results.where((kost) {
        return requiredFacilities.every(
          (facility) => kost.hasFacility(facility),
        );
      }).toList();
    }

    // Apply sorting
    return sortKost(results, sortBy, ascending: ascending);
  }
}
