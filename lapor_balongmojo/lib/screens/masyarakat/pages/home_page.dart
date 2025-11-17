import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

// --- TAMBAHKAN IMPORT API SERVICE ---
import 'package:lapor_balongmojo/services/api_service.dart'; 

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Informasi Umum Desa Balongmojo",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            const InfoDesaGrid(), // Widget ini sekarang dinamis
            const SizedBox(height: 24),
            Text(
              "Peta Wilayah Balongmojo",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            const PetaBalongmojoCard(),
          ],
        ),
      ),
    );
  }
}

// --- PERBAIKAN: UBAH InfoDesaGrid MENJADI STATEFULWIDGET ---
class InfoDesaGrid extends StatefulWidget {
  const InfoDesaGrid({super.key});

  @override
  State<InfoDesaGrid> createState() => _InfoDesaGridState();
}

class _InfoDesaGridState extends State<InfoDesaGrid> {
  // Buat instance ApiService
  final ApiService _apiService = ApiService();
  // Buat variabel Future untuk menampung data
  late Future<int> _totalLaporanFuture;

  @override
  void initState() {
    super.initState();
    // Panggil API saat widget pertama kali dimuat
    _totalLaporanFuture = _apiService.getTotalLaporan();
  }

  @override
  Widget build(BuildContext context) {
    // Gunakan FutureBuilder untuk menunggu data dari API
    return FutureBuilder<int>(
      future: _totalLaporanFuture,
      builder: (context, snapshot) {
        
        // Ambil data total laporan. 
        // Jika masih loading, tampilkan '...'
        // Jika error, tampilkan '0'
        String totalLaporanValue = '...';
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            totalLaporanValue = snapshot.data.toString();
          } else {
            totalLaporanValue = '0'; // Tampilkan 0 jika error
          }
        }

        // Buat daftar info di dalam builder
        final List<Map<String, dynamic>> infoItems = [
          {'title': 'Jumlah Dusun', 'value': '8', 'icon': Icons.home_work, 'color': Colors.blueAccent,},
          {'title': 'Total Penduduk', 'value': '3.000 Jiwa', 'icon': Icons.people_alt, 'color': Colors.green,},
          {'title': 'Laki-laki', 'value': '1.520 Jiwa', 'icon': Icons.male, 'color': Colors.indigo,},
          {'title': 'Perempuan', 'value': '1.480 Jiwa', 'icon': Icons.female, 'color': Colors.pinkAccent,},
          {
            'title': 'Jumlah Laporan', 
            'value': totalLaporanValue, // <-- DATA DINAMIS
            'icon': Icons.assignment, 
            'color': Colors.orange,
          },
          {'title': 'Instansi Terhubung', 'value': '5', 'icon': Icons.apartment, 'color': Colors.purple,},
        ];

        // Tampilkan GridView
        return GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.2,
          ),
          itemCount: infoItems.length,
          itemBuilder: (context, index) {
            final item = infoItems[index];
            return InfoCard(
              title: item['title'],
              value: item['value'],
              icon: item['icon'],
              color: item['color'],
            );
          },
        );
      },
    );
  }
}

// ... (Class InfoCard tidak berubah)
class InfoCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const InfoCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: color, size: 36),
            const Spacer(),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
              ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}


// ... (Class PetaBalongmojoCard dan _LocationMarker tidak berubah)
class PetaBalongmojoCard extends StatefulWidget {
  const PetaBalongmojoCard({super.key});

  @override
  State<PetaBalongmojoCard> createState() => _PetaBalongmojoCardState();
}

class _PetaBalongmojoCardState extends State<PetaBalongmojoCard> {
  final MapController _mapController = MapController();

  @override
  Widget build(BuildContext context) {
    final LatLng balaiDesa = LatLng(-7.51272, 112.44911);

    final List<Marker> importantLocations = [
      Marker(
        point: balaiDesa,
        width: 100,
        height: 100,
        child: const _LocationMarker(
          icon: Icons.location_pin,
          label: "Balai Desa",
          color: Colors.red,
        ),
      ),
    ];

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: 350,
        child: Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: balaiDesa,
                initialZoom: 14.5,
                minZoom: 13.0,
                maxZoom: 18.0,
                cameraConstraint: CameraConstraint.contain(
                  bounds: LatLngBounds(
                    LatLng(-7.54, 112.42),
                    LatLng(-7.49, 112.48),
                  ),
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.lapor_balongmojo',
                ),
                MarkerLayer(
                  markers: importantLocations,
                ),
              ],
            ),
            Positioned(
              top: 12,
              left: 12,
              child: Column(
                children: [
                  FloatingActionButton.small(
                    heroTag: 'zoom_in_button',
                    onPressed: () {
                      _mapController.move(
                          _mapController.camera.center, _mapController.camera.zoom + 1);
                    },
                    child: const Icon(Icons.add),
                  ),
                  const SizedBox(height: 8),
                  FloatingActionButton.small(
                    heroTag: 'zoom_out_button',
                    onPressed: () {
                      _mapController.move(
                          _mapController.camera.center, _mapController.camera.zoom - 1);
                    },
                    child: const Icon(Icons.remove),
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

class _LocationMarker extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _LocationMarker({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 36),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.black54, width: 0.5),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
        ),
      ],
    );
  }
}