import 'dart:convert';

import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../functions.dart';

class NoteScreen extends StatefulWidget {
  final int noteId;

  const NoteScreen({super.key, required this.noteId});

  @override
  State<NoteScreen> createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> with WidgetsBindingObserver {
  final _controller = TextEditingController();
  String? _updatedAt;
  String? _noteTitle;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadNote();
  }

  Future<void> _loadNote() async {
    final request = await ApiService().getNoteById(widget.noteId);
    final note = request != null ? request["note"] : null;
    debugPrint(jsonEncode(note));
    if (note != null) {
      setState(() {
        _controller.text = note['Content'] ?? '';
        _updatedAt = note['UpdatedAt'];
        _noteTitle = note['Title'];
        _isLoaded = true;
      });
    }
  }

  Future<void> _saveNote() async {
    await ApiService().updateNote(widget.noteId, _controller.text);
  }

  @override
  void dispose() {
    _saveNote();
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      _saveNote();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () async {
            await _saveNote();
            Navigator.of(context).pop(true);
          },
        ),
        title: Text(_noteTitle ?? 'Note'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            tooltip: 'Delete',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete note?'),
                  content: const Text('Delete note?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Delete', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                await ApiService().deleteNote(widget.noteId);
                Navigator.of(context).pop(true);
              }
            },
          ),
        ],
      ),
      body: !_isLoaded
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      autofocus: true,
                      maxLines: null,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                      ),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      'Last update: ${formatDate(_updatedAt)}',
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}