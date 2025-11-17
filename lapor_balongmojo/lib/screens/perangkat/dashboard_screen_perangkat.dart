import 'package:flutter/material.dart';
import 'package:lapor_balongmojo/providers/auth_provider.dart';
import 'package:lapor_balongmojo/providers/laporan_provider.dart';
import 'package:lapor_balongmojo/screens/perangkat/detail_laporan_screen.dart';
import 'package:lapor_balongmojo/screens/perangkat/form_berita_screen.dart';
import 'package:lapor_balongmojo/screens/perangkat/verifikasi_user_screen.dart';
import 'package:provider/provider.dart';

class DashboardScreenPerangkat extends StatefulWidget {
  static const routeName = '/dashboard-perangkat';
  const DashboardScreenPerangkat({super.key});

  @override
  State<DashboardScreenPerangkat> createState() => _DashboardScreenPerangkatState();
}

class _DashboardScreenPerangkatState extends State<DashboardScreenPerangkat> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    const DaftarLaporanPage(), 
    VerifikasiUserScreen(), 
    FormBeritaScreen(), 
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Perangkat'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
            },
          )
        ],
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Daftar Laporan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.how_to_reg),
            label: 'Verifikasi Warga',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.create),
            label: 'Buat Berita',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}

class DaftarLaporanPage extends StatefulWidget {
  const DaftarLaporanPage({super.key});

  @override
  State<DaftarLaporanPage> createState() => _DaftarLaporanPageState();
}

class _DaftarLaporanPageState extends State<DaftarLaporanPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
      Provider.of<LaporanProvider>(context, listen: false).fetchLaporan()
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LaporanProvider>(
      builder: (context, laporanProvider, child) {
        if (laporanProvider.status == LaporanStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (laporanProvider.status == LaporanStatus.error) {
          return Center(child: Text(laporanProvider.errorMessage));
        }
        if (laporanProvider.laporanList.isEmpty) {
          return const Center(child: Text('Belum ada laporan masuk.'));
        }

        return RefreshIndicator(
          onRefresh: () => laporanProvider.fetchLaporan(),
          child: ListView.builder(
            itemCount: laporanProvider.laporanList.length,
            itemBuilder: (ctx, index) {
              final laporan = laporanProvider.laporanList[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  title: Text(laporan.judul),
                  subtitle: Text('Pelapor: ${laporan.namaPelapor ?? 'N/A'}'),
                  trailing: Chip(label: Text(laporan.status)),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (ctx) => DetailLaporanScreen(laporan: laporan),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }
}