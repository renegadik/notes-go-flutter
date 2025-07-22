import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import 'login_screen.dart';

class NotesScreen extends StatelessWidget {
  const NotesScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    await StorageService().deleteAllData();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
        actions: [
          FutureBuilder<String?>(
            future: StorageService().getUserLogin(),
            builder: (context, snapshot) {
              final username = snapshot.data ?? '';
              return Row(
                children: [
                  if (username.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Text(
                        username,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  PopupMenuButton(
                    icon: const Icon(Icons.account_circle),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        child: Text(
                          'Выход',
                          style: const TextStyle(color: Colors.red),
                        ),
                        onTap: () => _logout(context),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: const Center(child: Text('Здесь будут заметки')),
    );
  }
}