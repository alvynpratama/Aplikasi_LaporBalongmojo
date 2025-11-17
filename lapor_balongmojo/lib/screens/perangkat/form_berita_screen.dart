import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lapor_balongmojo/services/api_service.dart';
import 'package:lapor_balongmojo/widgets/custom_textfield.dart';
import 'package:lapor_balongmojo/widgets/primary_button.dart';

class FormBeritaScreen extends StatefulWidget {
  const FormBeritaScreen({super.key});

  @override
  State<FormBeritaScreen> createState() => _FormBeritaScreenState();
}

class _FormBeritaScreenState extends State<FormBeritaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _judulController = TextEditingController();
  final _isiController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  File? _pickedImage;
  final ImagePicker _picker = ImagePicker();

  // State checkbox
  bool _isPeringatanDarurat = false;

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
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil gambar: $e')),
      );
    }
  }

  Future<void> _submitBerita() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() { _isLoading = true; });

    // --- [CCTV 1] DEBUG UI ---
    print("==================================================");
    print(">>> [FLUTTER UI] Nilai Checkbox saat submit: $_isPeringatanDarurat");
    print("==================================================");

    try {
      String? uploadedGambarUrl;

      if (_pickedImage != null) {
        uploadedGambarUrl = await _apiService.uploadImage(_pickedImage!);
      }

      if (!mounted) return;
      
      await _apiService.postBerita(
        _judulController.text,
        _isiController.text,
        uploadedGambarUrl,
        _isPeringatanDarurat, // Pastikan variabel ini yang dikirim
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Berita berhasil dipublikasikan!'))
      );

      _judulController.clear();
      _isiController.clear();
      setState(() {
        _pickedImage = null;
        _isPeringatanDarurat = false; 
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal publikasi: $e')),
      );
    }

    setState(() { _isLoading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            CustomTextField(
              controller: _judulController,
              labelText: 'Judul Berita',
              icon: Icons.title,
              validator: (val) => val!.isEmpty ? 'Judul wajib diisi' : null,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: TextFormField(
                controller: _isiController,
                decoration: InputDecoration(
                  labelText: 'Isi Berita',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                maxLines: 10,
                validator: (val) => val!.isEmpty ? 'Isi wajib diisi' : null,
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
                      child: Text('Belum ada gambar cover dipilih'),
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

            const SizedBox(height: 16),
            CheckboxListTile(
              title: const Text("Peringatan Darurat?"),
              subtitle: const Text("Ceklis untuk mengirim notifikasi ke semua warga."),
              value: _isPeringatanDarurat,
              onChanged: (newValue) {
                setState(() {
                  _isPeringatanDarurat = newValue ?? false;
                  // Print setiap kali diklik
                  print("Checkbox diklik. Nilai sekarang: $_isPeringatanDarurat"); 
                });
              },
              activeColor: Colors.red,
              controlAffinity: ListTileControlAffinity.leading,
              tileColor: Colors.red.shade50,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),

            const SizedBox(height: 24),
            PrimaryButton(
              text: 'PUBLIKASIKAN BERITA',
              onPressed: _submitBerita,
              isLoading: _isLoading,
            )
          ],
        ),
      ),
    );
  }
}