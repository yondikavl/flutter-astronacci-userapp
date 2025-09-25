import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../repositories/user_repository.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final repo = RepositoryProvider.of<UserRepository>(context);
    setState(() => _loading = true);

    final success = await repo.updateMe({
      'name': _nameController.text.trim(),
      'email': _emailController.text.trim(),
    });

    setState(() => _loading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success
            ? 'Profil berhasil diperbarui'
            : 'Gagal memperbarui profil'),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );

    if (success) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final repo = RepositoryProvider.of<UserRepository>(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Edit Profil"),
        backgroundColor: Colors.redAccent.shade700,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: repo.me(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Terjadi kesalahan saat memuat data',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final data = snapshot.data;
          if (data != null) {
            _nameController.text = data['name'] ?? '';
            _emailController.text = data['email'] ?? '';
          }

          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: _buildForm(theme),
            ),
          );
        },
      ),
    );
  }

  Widget _buildForm(ThemeData theme) {
    return Column(
      children: [
        Icon(
          Icons.person_outline,
          size: 80,
          color: Colors.redAccent.shade700,
        ),
        const SizedBox(height: 16),
        Text(
          "Perbarui Profil Anda",
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 32),
        _buildTextField(
          controller: _nameController,
          label: "Nama",
          icon: Icons.person_outline,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _emailController,
          label: "Email",
          icon: Icons.email_outlined,
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _loading ? null : _saveProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent.shade700,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: _loading
                ? const CircularProgressIndicator.adaptive(
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  )
                : const Text("Simpan", style: TextStyle(fontSize: 16)),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.redAccent.shade700),
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
    );
  }
}
