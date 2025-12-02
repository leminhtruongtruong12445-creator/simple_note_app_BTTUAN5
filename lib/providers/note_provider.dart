// lib/providers/note_provider.dart
import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/note.dart';

class NoteProvider extends ChangeNotifier {
  List<Note> _notes = [];
  List<Note> get notes => _notes;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Load notes từ DB
  Future<void> loadNotes() async {
    _isLoading = true;
    notifyListeners();

    _notes = await DatabaseHelper.instance.readAllNotes();

    _isLoading = false;
    notifyListeners();
  }

  // Thêm note
  Future<void> addNote(Note note) async {
    await DatabaseHelper.instance.create(note);
    await loadNotes(); // Reload lại danh sách sau khi thêm
  }

  // Cập nhật note
  Future<void> updateNote(Note note) async {
    await DatabaseHelper.instance.update(note);
    await loadNotes();
  }

  // Xóa note
  Future<void> deleteNote(int id) async {
    await DatabaseHelper.instance.delete(id);
    await loadNotes();
  }
}
