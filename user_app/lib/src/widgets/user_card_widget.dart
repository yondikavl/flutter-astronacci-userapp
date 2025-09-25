import 'package:flutter/material.dart';
import 'package:user_app/src/models/user.dart';
import 'package:user_app/src/screens/user_detail_screen.dart';

class UserCardWidget extends StatelessWidget {
  final UserModel user;

  const UserCardWidget({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300, width: 1.5),
      ),
      color: Colors.grey.shade50,
      elevation: 0,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.redAccent.shade700,
          child: Text(
            user.name.isNotEmpty ? user.name[0] : '?',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(
          user.name.isEmpty ? 'Tidak ada nama' : user.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(user.email.isEmpty ? 'Tidak ada email' : user.email),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => UserDetailScreen(userId: user.id),
          ),
        ),
      ),
    );
  }
}
