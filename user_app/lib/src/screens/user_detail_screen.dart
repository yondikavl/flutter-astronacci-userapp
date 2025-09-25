import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../repositories/user_repository.dart';
import '../models/user.dart';

class UserDetailScreen extends StatefulWidget {
  final UserModel? user;
  final int? userId;

  const UserDetailScreen({
    super.key,
    this.user,
    this.userId,
  });

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  UserModel? _user;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.user != null) {
      _user = widget.user;
      _loading = false;
    } else if (widget.userId != null) {
      _loadUser(widget.userId!);
    } else {
      _error = 'Tidak ada data atau ID pengguna';
      _loading = false;
    }
  }

  Future<void> _loadUser(int id) async {
    try {
      final repo = RepositoryProvider.of<UserRepository>(context);
      final fetchedUser = await repo.fetchUserDetail(id);
      setState(() {
        _user = fetchedUser;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Pengguna'),
        centerTitle: true,
        backgroundColor: Colors.redAccent.shade700,
        foregroundColor: Colors.white,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Text(
          'Terjadi kesalahan: $_error',
          style: const TextStyle(color: Colors.redAccent),
          textAlign: TextAlign.center,
        ),
      );
    }
    if (_user == null) {
      return const Center(child: Text('Pengguna tidak ditemukan'));
    }

    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: _user!.avatar != null
                      ? NetworkImage(_user!.avatar!)
                      : null,
                  child: _user!.avatar == null
                      ? Text(
                          _user!.name.isNotEmpty ? _user!.name[0] : '?',
                          style: const TextStyle(fontSize: 40),
                        )
                      : null,
                ),
                const SizedBox(height: 24),
                Text(
                  _user!.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Text(
                    _user!.email,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
