import 'package:flutter/material.dart';
import 'package:lapor_balongmojo/screens/auth/register_masyarakat_screen.dart';
import 'package:lapor_balongmojo/widgets/custom_textfield.dart';
import 'package:lapor_balongmojo/widgets/primary_button.dart';
import 'package:lapor_balongmojo/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = '/login';
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _submitLogin() async {
    if (!_formKey.currentState!.validate()) {
      return; 
    }
    _formKey.currentState!.save();
    
    setState(() { _isLoading = true; });
    
    try {
      await Provider.of<AuthProvider>(context, listen: false).login(
        _emailController.text,
        _passwordController.text,
      );
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
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Lapor Balongmojo',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 32),
                CustomTextField(
                  controller: _emailController,
                  labelText: 'Email',
                  icon: Icons.email,
                  validator: (val) =>
                      val!.isEmpty ? 'Email tidak boleh kosong' : null,
                ),
                CustomTextField(
                  controller: _passwordController,
                  labelText: 'Password',
                  icon: Icons.lock,
                  isObscure: true,
                  validator: (val) =>
                      val!.isEmpty ? 'Password tidak boleh kosong' : null,
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  text: 'LOGIN',
                  onPressed: _submitLogin,
                  isLoading: _isLoading,
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context)
                        .pushNamed(RegisterMasyarakatScreen.routeName);
                  },
                  child: const Text('Belum punya akun? Daftar (Masyarakat)'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}