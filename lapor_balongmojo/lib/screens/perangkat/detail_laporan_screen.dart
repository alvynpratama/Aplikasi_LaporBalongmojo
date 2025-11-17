import 'package:flutter/material.dart';
import 'package:lapor_balongmojo/models/laporan_model.dart';
import 'package:lapor_balongmojo/providers/laporan_provider.dart';
import 'package:lapor_balongmojo/widgets/primary_button.dart';
import 'package:provider/provider.dart';

class DetailLaporanScreen extends StatefulWidget {
  final LaporanModel laporan;
  const DetailLaporanScreen({super.key, required this.laporan});

  @override
  State<DetailLaporanScreen> createState() => _DetailLaporanScreenState();
}

class _DetailLaporanScreenState extends State<DetailLaporanScreen> {
  late String _selectedStatus;
  bool _isLoading = false;
  final List<String> _statusOptions = [
    'belum terdaftar',
    'terverifikasi',
    'diproses',
    'selesai'
  ];

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.laporan.status;
  }

  Future<void> _updateStatus() async {
    setState(() { _isLoading = true; });
    try {
      await Provider.of<LaporanProvider>(context, listen: false)
          .updateStatus(widget.laporan.id, _selectedStatus);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Status berhasil diperbarui!'))
      );
      Navigator.of(context).pop();

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal update status: $e'))
      );
    }
    setState(() { _isLoading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Laporan')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.laporan.judul,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text('Pelapor: ${widget.laporan.namaPelapor ?? 'N/A'}'),
            Text('Dilaporkan pada: ${widget.laporan.createdAt}'), // TODO: Format tanggal
            const Divider(height: 24),
            Text(
              widget.laporan.deskripsi,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const Divider(height: 24),
            Text('Ubah Status Laporan:', style: Theme.of(context).textTheme.titleMedium),
            DropdownButton<String>(
              value: _selectedStatus,
              isExpanded: true,
              items: _statusOptions.map((String status) {
                return DropdownMenuItem<String>(
                  value: status,
                  child: Text(status),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedStatus = newValue!;
                });
              },
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              text: 'UPDATE STATUS',
              onPressed: _updateStatus,
              isLoading: _isLoading,
            )
          ],
        ),
      ),
    );
  }
}