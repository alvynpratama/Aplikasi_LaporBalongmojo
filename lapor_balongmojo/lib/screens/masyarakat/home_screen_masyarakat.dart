// File: lib/screens/masyarakat/home_screen_masyarakat.dart

import 'package:flutter/material.dart';
import 'package:lapor_balongmojo/providers/auth_provider.dart';
// --- TAMBAHKAN IMPORT LAPORAN PROVIDER ---
import 'package:lapor_balongmojo/providers/laporan_provider.dart'; 
import 'package:lapor_balongmojo/screens/masyarakat/form_laporan_screen.dart';
import 'package:lapor_balongmojo/screens/masyarakat/riwayat_laporan_screen.dart';
import 'package:lapor_balongmojo/services/api_service.dart';
import 'package:lapor_balongmojo/models/berita_model.dart';
import 'package:provider/provider.dart';

import 'pages/home_page.dart';

class HomeScreenMasyarakat extends StatefulWidget {
  static const routeName = '/home-masyarakat';
  const HomeScreenMasyarakat({super.key});

  @override
  State<HomeScreenMasyarakat> createState() => _HomeScreenMasyarakatState();
}

class _HomeScreenMasyarakatState extends State<HomeScreenMasyarakat> {
  int _selectedIndex = 1;

  static final List<Widget> _widgetOptions = <Widget>[
    const BeritaPage(), // <-- Diganti
    const HomePage(),
    const RiwayatLaporanScreen(),
  ];

  // --- TAMBAHKAN initState UNTUK FETCH DATA ---
  @override
  void initState() {
    super.initState();
    // Panggil fetchLaporan() saat halaman ini pertama kali dimuat
    // Ini akan mengisi data untuk tab Home dan tab Riwayat
    Future.microtask(() {
      Provider.of<LaporanProvider>(context, listen: false).fetchLaporan();
    });
  }
  // --- BATAS TAMBAHAN ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lapor Balongmojo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
            },
          ),
        ],
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (ctx) => const FormLaporanScreen()),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: BottomAppBar(
        shape: null,
        notchMargin: 0,
        child: BottomNavigationBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          selectedFontSize: 12.0,
          unselectedFontSize: 12.0,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.article_outlined),
              activeIcon: Icon(Icons.article),
              label: 'Berita', // <-- Diganti
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history_outlined),
              activeIcon: Icon(Icons.history),
              label: 'Riwayat',
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
        ),
      ),
    );
  }
}

// --- WIDGET HALAMAN BERITA ---
class BeritaPage extends StatefulWidget { // <-- Diganti
  const BeritaPage({super.key}); // <-- Diganti
  @override
  State<BeritaPage> createState() => _BeritaPageState(); // <-- Diganti
}
class _BeritaPageState extends State<BeritaPage> { // <-- Diganti
  late Future<List<BeritaModel>> _beritaFuture;
  final ApiService _apiService = ApiService();
  @override
  void initState() {
    super.initState();
    _beritaFuture = _apiService.getBerita();
  }
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<BeritaModel>>(
      future: _beritaFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Belum ada berita.')); // <-- Diganti
        }
        final beritaList = snapshot.data!;
        return ListView.builder(
          itemCount: beritaList.length,
          itemBuilder: (ctx, index) {
            final berita = beritaList[index];
            final String isiSingkat = berita.isi.length > 50
                ? '${berita.isi.substring(0, 50)}...'
                : berita.isi;
            final bool hasImage =
                berita.gambar_url != null && berita.gambar_url!.isNotEmpty;
            return Card(
              margin: const EdgeInsets.all(8),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (hasImage)
                    Image.network(
                      '${ApiService.publicBaseUrl}${berita.gambar_url!}',
                      width: double.infinity,
                      height: 150,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 150,
                        color: Colors.grey[200],
                        child: const Icon(Icons.broken_image),
                      ),
                    ),
                  ListTile(
                    title: Text(
                      berita.judul,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Oleh: ${berita.authorName ?? 'Admin'}\n$isiSingkat',
                    ),
                    isThreeLine: true,
                    onTap: () {
                      // TODO: Buat halaman detail berita // <-- Diganti
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}