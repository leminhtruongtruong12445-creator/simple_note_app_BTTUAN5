// lib/screens/note_editor_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/note.dart';
import '../providers/note_provider.dart';

class NoteEditorScreen extends StatefulWidget {
  final Note? note; // Nếu null -> Thêm mới, Nếu có dữ liệu -> Sửa

  const NoteEditorScreen({super.key, this.note});

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(
      text: widget.note?.content ?? '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _saveNote() {
    if (_formKey.currentState!.validate()) {
      final isUpdating = widget.note != null;
      final now = DateTime.now();

      if (isUpdating) {
        // Cập nhật
        final updatedNote = widget.note!.copy(
          title: _titleController.text,
          content: _contentController.text,
          updatedAt: now,
        );
        context.read<NoteProvider>().updateNote(updatedNote);
      } else {
        // Thêm mới
        final newNote = Note(
          title: _titleController.text,
          content: _contentController.text,
          createdAt: now,
          updatedAt: now,
        );
        context.read<NoteProvider>().addNote(newNote);
      }
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note == null ? 'Add Note' : 'Edit Note'),
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _saveNote),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: 'Title',
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Title cannot be empty' : null,
              ),
              const SizedBox(height: 10),
              Expanded(
                child: TextFormField(
                  controller: _contentController,
                  decoration: const InputDecoration(
                    hintText: 'Type something...',
                    border: InputBorder.none,
                  ),
                  maxLines: null,
                  expands: true,
                  validator: (value) =>
                      value!.isEmpty ? 'Content cannot be empty' : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
