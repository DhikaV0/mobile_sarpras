import 'package:flutter/material.dart';
import 'package:mobile_sarpras/services/api_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  final _api = ApiService();

  void _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    final result = await _api.updateProfile(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    setState(() => _loading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result['message'] ?? 'Gagal update profil')),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  void _loadUser() async {
    final user = await _api.getCurrentUser();
    if (user != null) {
      _emailController.text = user.email;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) => value!.isEmpty ? 'Email tidak boleh kosong' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password Baru'),
                obscureText: true,
                validator: (value) =>
                    value!.isNotEmpty && value.length < 5 ? 'Minimal 5 karakter' : null,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _loading ? null : _updateProfile,
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Update Profil'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
