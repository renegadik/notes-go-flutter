import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../services/api_service.dart';
import 'login_screen.dart';
import 'note_screen.dart';
import '../functions.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  Future<void> _logout(BuildContext context) async {
    await StorageService().deleteAllData();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => LoginScreen()),
      (route) => false,
    );
  }

  Future<void> _showCreateNoteDialog(BuildContext context) async {
    final TextEditingController _titleController = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Name'),
        content: TextField(
          controller: _titleController,
          decoration: const InputDecoration(hintText: 'Insert note title'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(_titleController.text);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
    
    if (result != null && result.trim().isNotEmpty) {
      final note = await ApiService().createNote(result.trim());
      final noteId = note != null ? note[0]['id_note'] : null;
      final message = note != null ? note[0]['message'] : 'Error creating note';

      if (noteId != null) {
        final res = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => NoteScreen(noteId: noteId),
          ),
        );
        if (res == true) setState(() {});
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    }
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
                          'Logout',
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
      body: FutureBuilder<Map<String, dynamic>?>(
        future: ApiService().getUserNotes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final notes = (snapshot.data?['notes']) ?? [];

          if (notes.isEmpty) {
            return const Center(child: Text('Empty notes'));
          }
          
          return ListView.builder(
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final note = notes[index];
              final title = note['Title'] ?? 'No name';
              final updatedAt = note['UpdatedAt'] ?? '';
              final noteId = note['ID'];
              return ListTile(
                title: Text(title),
                subtitle: Text('Last update: ${formatDate(updatedAt)}'),
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => NoteScreen(noteId: noteId),
                    ),
                  );
                  if (result == true) {
                    setState(() {});
                  }
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateNoteDialog(context),
        tooltip: 'Create note',
        child: const Icon(Icons.add),
      ),
    );
  }
}