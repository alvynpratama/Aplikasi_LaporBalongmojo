import 'package:flutter/material.dart';
import 'package:lapor_balongmojo/services/api_service.dart';

class VerifikasiUserScreen extends StatefulWidget {
  const VerifikasiUserScreen({super.key});

  @override
  State<VerifikasiUserScreen> createState() => _VerifikasiUserScreenState();
}

class _VerifikasiUserScreenState extends State<VerifikasiUserScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<dynamic>> _pendingUsersFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _pendingUsersFuture = _apiService.getPendingUsers();
  }

  Future<void> _verifikasiUser(int userId) async {
    try {
      await _apiService.verifikasiUser(userId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User berhasil diverifikasi!'))
      );
      setState(() {
        _loadData();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal verifikasi: $e'))
      );
    }
  }

  Future<void> _tolakUser(int userId) async {
    try {
      await _apiService.tolakUser(userId);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User berhasil ditolak!')));
      // Refresh list
      setState(() {
        _loadData();
      });
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Gagal menolak: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: _pendingUsersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Tidak ada user yang perlu diverifikasi.'));
        }

        final users = snapshot.data!;
        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (ctx, index) {
            final user = users[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: ListTile(
                title: Text(user['nama_lengkap']),
                subtitle: Text(user['email'] + '\n' + user['no_telepon']),
                isThreeLine: true,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check_circle, color: Colors.green),
                      tooltip: 'Verifikasi',
                      onPressed: () => _verifikasiUser(user['id']),
                    ),
                    IconButton(
                      icon: const Icon(Icons.cancel, color: Colors.red),
                      tooltip: 'Tolak',
                      onPressed: () => _tolakUser(user['id']),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}