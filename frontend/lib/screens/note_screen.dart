import 'dart:convert';

import 'package:flutter/material.dart';
import '../services/api_service.dart';

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
            Navigator.of(context).pop();
          },
        ),
        title: Text(_noteTitle ?? 'Note'),
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
                      'Last update: ${_formatDate(_updatedAt)}',
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    final date = DateTime.tryParse(dateStr);
    if (date == null) return dateStr;
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}