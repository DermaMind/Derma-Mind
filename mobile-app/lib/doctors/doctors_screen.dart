import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:dermamind_app/models/map_place_model.dart';
import 'package:dermamind_app/services/api_service.dart';
import 'package:dermamind_app/utils/app_color.dart';

class DoctorsScreen extends StatefulWidget {
  static const String routeName = 'doctorsScreen';
  const DoctorsScreen({super.key});

  @override
  State<DoctorsScreen> createState() => _DoctorsScreenState();
}

class _DoctorsScreenState extends State<DoctorsScreen> {
  int _selectedTab = 0;
  final _mapController = MapController();
  bool _isLoadingPlaces = true;

  // ── Data ───────────────────────────────────────────────────────────────────

  List<Map<String, dynamic>> _dermatologists = [
    {
      'name': 'Dr. Ahmed Hassan',
      'specialty': 'Dermatology & Skin Specialist',
      'rating': '4.7',
      'reviews': '(198 reviews)',
      'distance': '1.2 km away',
      'isOpen': true,
      'avatarColor': const Color(0xFF0EA5E9),
      'initials': 'AH',
      'coords': const LatLng(30.0500, 31.2300),
      'phone': null,
    },
    {
      'name': 'Dr. Sarah Ahmed',
      'specialty': 'Dermatology & Skin Specialist',
      'rating': '4.9',
      'reviews': '(124 reviews)',
      'distance': '0.8 km away',
      'isOpen': true,
      'avatarColor': const Color(0xFFEC4899),
      'initials': 'SA',
      'coords': const LatLng(30.0470, 31.2380),
      'phone': null,
    },
    {
      'name': 'Dr. Layla Mostafa',
      'specialty': 'Skin & Hair Specialist',
      'rating': '4.8',
      'reviews': '(87 reviews)',
      'distance': '3.4 km away',
      'isOpen': true,
      'avatarColor': const Color(0xFFF97316),
      'initials': 'LM',
      'coords': const LatLng(30.0420, 31.2420),
      'phone': null,
    },
    {
      'name': 'Dr. Nour El-Din',
      'specialty': 'Pediatric Dermatology',
      'rating': '4.5',
      'reviews': '(67 reviews)',
      'distance': '2.1 km away',
      'isOpen': false,
      'avatarColor': const Color(0xFF8B5CF6),
      'initials': 'NE',
      'coords': const LatLng(30.0390, 31.2280),
      'phone': null,
    },
  ];

  List<Map<String, dynamic>> _pharmacies = [
    {
      'name': 'El-Ezaby Pharmacy',
      'specialty': '24/7 Pharmacy',
      'rating': '4.6',
      'reviews': '(310 reviews)',
      'distance': '0.3 km away',
      'isOpen': true,
      'avatarColor': const Color(0xFF10B981),
      'initials': 'EZ',
      'coords': const LatLng(30.0460, 31.2350),
      'phone': null,
    },
    {
      'name': 'Seif Pharmacy',
      'specialty': 'Full-service pharmacy',
      'rating': '4.4',
      'reviews': '(198 reviews)',
      'distance': '1.5 km away',
      'isOpen': true,
      'avatarColor': const Color(0xFF0EA5E9),
      'initials': 'SF',
      'coords': const LatLng(30.0510, 31.2410),
      'phone': null,
    },
    {
      'name': 'El-Dawaa Pharmacy',
      'specialty': 'Dermatology products available',
      'rating': '4.2',
      'reviews': '(145 reviews)',
      'distance': '2.8 km away',
      'isOpen': false,
      'avatarColor': const Color(0xFFF97316),
      'initials': 'ED',
      'coords': const LatLng(30.0350, 31.2450),
      'phone': null,
    },
  ];

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _loadNearbyPlaces();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  // ── Location + API ─────────────────────────────────────────────────────────

  Future<void> _loadNearbyPlaces() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        _loadWithDefaultLocation();
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );

      final lat = position.latitude;
      final lng = position.longitude;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _mapController.move(LatLng(lat, lng), 13.0);
      });

      final clinicsRes =
          await ApiService.getClinics(latitude: lat, longitude: lng);
      final pharmaciesRes =
          await ApiService.getPharmacies(latitude: lat, longitude: lng);

      if (!mounted) return;
      setState(() {
        if (clinicsRes.success &&
            clinicsRes.data != null &&
            clinicsRes.data!.isNotEmpty) {
          _dermatologists =
              clinicsRes.data!.map(_convertPlace).toList();
        }
        if (pharmaciesRes.success &&
            pharmaciesRes.data != null &&
            pharmaciesRes.data!.isNotEmpty) {
          _pharmacies =
              pharmaciesRes.data!.map(_convertPlace).toList();
        }
        _isLoadingPlaces = false;
      });
    } catch (_) {
      _loadWithDefaultLocation();
    }
  }

  void _loadWithDefaultLocation() {
    if (!mounted) return;
    setState(() => _isLoadingPlaces = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Could not get location — showing nearby places'),
        duration: Duration(seconds: 3),
      ),
    );
  }

  Map<String, dynamic> _convertPlace(MapPlaceModel place) {
    final colors = [
      const Color(0xFF0EA5E9),
      const Color(0xFFEC4899),
      const Color(0xFFF97316),
      const Color(0xFF8B5CF6),
      const Color(0xFF10B981),
    ];
    final colorIndex = place.name.codeUnitAt(0) % colors.length;
    return {
      'name': place.name,
      'specialty': place.specialty,
      'rating': place.rating.toStringAsFixed(1),
      'reviews': place.reviewLabel,
      'distance': place.distanceLabel,
      'isOpen': place.isOpen,
      'avatarColor': colors[colorIndex],
      'initials': place.initials,
      'coords': LatLng(place.latitude, place.longitude),
      'phone': place.phone,
    };
  }

  // ── Map helpers ────────────────────────────────────────────────────────────

  List<Marker> _buildMarkers(BuildContext context) {
    final items = _selectedTab == 0 ? _dermatologists : _pharmacies;
    final color = _selectedTab == 0
        ? const Color(0xFF7C3AED)
        : const Color(0xFF10B981);

    return items.map((item) {
      final coords = item['coords'] as LatLng;
      final name = item['name'] as String;
      return Marker(
        point: coords,
        width: 40,
        height: 40,
        child: GestureDetector(
          onTap: () {
            _mapController.move(coords, 14.0);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(name),
                duration: const Duration(seconds: 2),
              ),
            );
          },
          child: Icon(Icons.location_on, color: color, size: 40),
        ),
      );
    }).toList();
  }

  // ── UI helpers ─────────────────────────────────────────────────────────────

  Widget _buildDragHandle() => Center(
        child: Container(
          margin: const EdgeInsets.only(top: 10, bottom: 6),
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(99),
          ),
        ),
      );

  Widget _buildTabBar() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(
          children: [
            _TabItem(
              label: 'Dermatologists',
              selected: _selectedTab == 0,
              onTap: () => setState(() => _selectedTab = 0),
            ),
            const SizedBox(width: 24),
            _TabItem(
              label: 'Pharmacies',
              selected: _selectedTab == 1,
              onTap: () => setState(() => _selectedTab = 1),
            ),
          ],
        ),
      );

  Widget _buildList(ScrollController controller) => ListView.builder(
        controller: controller,
        padding: const EdgeInsets.only(top: 8, bottom: 24),
        itemCount:
            _selectedTab == 0 ? _dermatologists.length : _pharmacies.length,
        itemBuilder: (context, index) {
          final item =
              _selectedTab == 0 ? _dermatologists[index] : _pharmacies[index];
          return _DoctorCard(
            data: item,
            onCallTap: () {
              final phone = item['phone'] as String?;
              final msg = (phone != null && phone.isNotEmpty)
                  ? 'Call: $phone'
                  : 'No phone number available';
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(msg),
                  duration: const Duration(seconds: 3),
                ),
              );
            },
            onDirectionsTap: () {
              final coords = item['coords'] as LatLng;
              final name = item['name'] as String;
              _mapController.move(coords, 15.0);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Showing directions to $name'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          );
        },
      );

  @override
  Widget build(BuildContext context) {
    final mapHeight = MediaQuery.of(context).size.height * 0.55;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColor.blueColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Nearby Dermatologists',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // ── Map ────────────────────────────────────────────────────────────
          SizedBox(
            height: mapHeight,
            child: FlutterMap(
              mapController: _mapController,
              options: const MapOptions(
                initialCenter: LatLng(30.0444, 31.2357),
                initialZoom: 13.0,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.dermamind_app',
                ),
                MarkerLayer(markers: _buildMarkers(context)),
              ],
            ),
          ),

          // ── Loading overlay on map ─────────────────────────────────────────
          if (_isLoadingPlaces)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: mapHeight,
              child: Container(
                color: Colors.black.withValues(alpha: 0.25),
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
            ),

          // ── Draggable sheet ────────────────────────────────────────────────
          DraggableScrollableSheet(
            initialChildSize: 0.42,
            minChildSize: 0.18,
            maxChildSize: 0.88,
            builder: (context, scrollController) => Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.10),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildDragHandle(),
                  _buildTabBar(),
                  const Divider(height: 1),
                  Expanded(child: _buildList(scrollController)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Tab item ───────────────────────────────────────────────────────────────────

class _TabItem extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TabItem({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: selected ? AppColor.blueColor : Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 2.5,
              width: selected ? label.length * 8.5 : 0,
              decoration: BoxDecoration(
                color: AppColor.blueColor,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ],
        ),
      );
}

// ── Doctor / pharmacy card ─────────────────────────────────────────────────────

class _DoctorCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onCallTap;
  final VoidCallback onDirectionsTap;

  const _DoctorCard({
    required this.data,
    required this.onCallTap,
    required this.onDirectionsTap,
  });

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar
            CircleAvatar(
              radius: 30,
              backgroundColor: data['avatarColor'] as Color,
              child: Text(
                data['initials'] as String,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name + status
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          data['name'] as String,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      _StatusBadge(isOpen: data['isOpen'] as bool),
                    ],
                  ),
                  const SizedBox(height: 2),

                  // Specialty
                  Text(
                    data['specialty'] as String,
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 5),

                  // Rating + distance
                  Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          color: Colors.amber, size: 14),
                      const SizedBox(width: 2),
                      Text(
                        data['rating'] as String,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Text(
                        data['reviews'] as String,
                        style: const TextStyle(
                            fontSize: 11, color: Colors.grey),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.location_on_outlined,
                          size: 13, color: Colors.grey.shade400),
                      const SizedBox(width: 2),
                      Text(
                        data['distance'] as String,
                        style: const TextStyle(
                            fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onCallTap,
                          icon: const Icon(Icons.phone_outlined, size: 14),
                          label: const Text('Call',
                              style: TextStyle(fontSize: 12)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColor.blueColor,
                            side: const BorderSide(
                                color: AppColor.blueColor),
                            padding:
                                const EdgeInsets.symmetric(vertical: 6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: onDirectionsTap,
                          icon: const Icon(Icons.directions_outlined,
                              size: 14, color: Colors.white),
                          label: const Text(
                            'Directions',
                            style: TextStyle(
                                fontSize: 12, color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColor.blueColor,
                            padding:
                                const EdgeInsets.symmetric(vertical: 6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}

// ── Status badge ───────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final bool isOpen;

  const _StatusBadge({required this.isOpen});

  @override
  Widget build(BuildContext context) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: isOpen
              ? const Color(0xFFD1FAE5)
              : const Color(0xFFFFE4E4),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          isOpen ? 'Open Now' : 'Closed',
          style: TextStyle(
            color: isOpen
                ? const Color(0xFF10B981)
                : const Color(0xFFEF4444),
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
}
