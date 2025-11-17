import 'package:flutter/material.dart';
import 'package:lapor_balongmojo/providers/laporan_provider.dart';
import 'package:provider/provider.dart';

class RiwayatLaporanScreen extends StatefulWidget {
  const RiwayatLaporanScreen({super.key});

  @override
  State<RiwayatLaporanScreen> createState() => _RiwayatLaporanScreenState();
}

class _RiwayatLaporanScreenState extends State<RiwayatLaporanScreen> {
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
          return const Center(child: Text('Anda belum membuat laporan.'));
        }

        // Tampilkan list laporan
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
                  subtitle: Text(laporan.deskripsi, maxLines: 2, overflow: TextOverflow.ellipsis,),
                  trailing: Chip(
                    label: Text(laporan.status),
                    backgroundColor: _getStatusColor(laporan.status),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'belum terdaftar':
        return Colors.grey;
      case 'terverifikasi':
        return Colors.blue.shade100;
      case 'diproses':
        return Colors.orange.shade100;
      case 'selesai':
        return Colors.green.shade100;
      default:
        return Colors.grey.shade100;
    }
  }
}