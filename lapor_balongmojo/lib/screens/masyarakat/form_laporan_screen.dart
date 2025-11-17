import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lapor_balongmojo/providers/laporan_provider.dart';
import 'package:lapor_balongmojo/services/api_service.dart';
import 'package:lapor_balongmojo/widgets/custom_textfield.dart';
import 'package:lapor_balongmojo/widgets/primary_button.dart';
import 'package:provider/provider.dart';

class FormLaporanScreen extends StatefulWidget {
  const FormLaporanScreen({super.key});

  @override
  State<FormLaporanScreen> createState() => _FormLaporanScreenState();
}

class _FormLaporanScreenState extends State<FormLaporanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _judulController = TextEditingController();
  final _deskripsiController = TextEditingController();
  File? _pickedImage;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  final ApiService _apiService = ApiService();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image == null) return;

      final File imageFile = File(image.path);
      final int fileSize = await imageFile.length();
      final double fileSizeInMB = fileSize / (1024 * 1024);

      if (fileSizeInMB > 2.0) {
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Ukuran File Terlalu Besar'),
            content: const Text('Ukuran foto tidak boleh melebihi 2 MB.'),
            actions: [
              TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('OK'))
            ],
          ),
        );
        return; 
      }

      setState(() {
        _pickedImage = imageFile;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil gambar: $e')),
      );
    }
  }

  Future<void> _submitLaporan() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() { _isLoading = true; });

    try {
      String? uploadedFotoUrl;
      if (_pickedImage != null) {
        uploadedFotoUrl = await _apiService.uploadImage(_pickedImage!);
      }
      if (!mounted) return;
      await Provider.of<LaporanProvider>(context, listen: false)
          .addLaporan(
              _judulController.text, 
              _deskripsiController.text, 
              uploadedFotoUrl 
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Laporan berhasil dikirim!'))
      );
      Navigator.of(context).pop(); 

    } catch (e) {
       ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengirim laporan: $e'))
      );
    }
    
    setState(() { _isLoading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buat Laporan Baru')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CustomTextField(
                controller: _judulController,
                labelText: 'Judul Laporan',
                icon: Icons.title,
                validator: (val) => val!.isEmpty ? 'Judul wajib diisi' : null,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextFormField(
                  controller: _deskripsiController,
                  decoration: InputDecoration(
                    labelText: 'Deskripsi Lengkap',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  maxLines: 5,
                  validator: (val) => val!.isEmpty ? 'Deskripsi wajib diisi' : null,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _pickedImage != null
                    ? Image.file(_pickedImage!, fit: BoxFit.cover)
                    : const Center(
                        child: Text('Belum ada foto dipilih'),
                      ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton.icon(
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Galeri'),
                    onPressed: () => _pickImage(ImageSource.gallery),
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Kamera'),
                    onPressed: () => _pickImage(ImageSource.camera),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                text: 'KIRIM LAPORAN',
                onPressed: _submitLaporan,
                isLoading: _isLoading,
              )
            ],
          ),
        ),
      ),
    );
  }
}