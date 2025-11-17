import 'package:flutter/material.dart';
import 'package:lapor_balongmojo/providers/auth_provider.dart';
import 'package:lapor_balongmojo/widgets/custom_textfield.dart';
import 'package:lapor_balongmojo/widgets/primary_button.dart';
import 'package:provider/provider.dart';

class RegisterMasyarakatScreen extends StatefulWidget {
  static const routeName = '/register-masyarakat';
  const RegisterMasyarakatScreen({super.key});

  @override
  State<RegisterMasyarakatScreen> createState() =>
      _RegisterMasyarakatScreenState();
}

class _RegisterMasyarakatScreenState extends State<RegisterMasyarakatScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _noTelpController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _submitRegister() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() { _isLoading = true; });

    try {
      await Provider.of<AuthProvider>(context, listen: false)
          .registerMasyarakat(
        _namaController.text,
        _emailController.text,
        _noTelpController.text,
        _passwordController.text,
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registrasi berhasil! Silakan tunggu verifikasi perangkat desa.'))
      );
      Navigator.of(context).pop();

    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    }

    setState(() { _isLoading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Akun Masyarakat')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CustomTextField(
                controller: _namaController,
                labelText: 'Nama Lengkap',
                icon: Icons.person,
                validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
              ),
              CustomTextField(
                controller: _emailController,
                labelText: 'Email',
                icon: Icons.email,
                validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
              ),
              CustomTextField(
                controller: _noTelpController,
                labelText: 'No. Telepon',
                icon: Icons.phone,
                validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
              ),
              CustomTextField(
                controller: _passwordController,
                labelText: 'Password',
                icon: Icons.lock,
                isObscure: true,
                validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                text: 'DAFTAR',
                onPressed: _submitRegister,
                isLoading: _isLoading,
              )
            ],
          ),
        ),
      ),
    );
  }
}