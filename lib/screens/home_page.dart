// lib/screens/home_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/note_provider.dart';
import '../models/note.dart';
import '../widgets/note_card.dart';
import 'note_editor_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // Load data khi mở app
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NoteProvider>().loadNotes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Notes'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Consumer<NoteProvider>(
        builder: (context, noteProvider, child) {
          if (noteProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (noteProvider.notes.isEmpty) {
            return const Center(child: Text('No notes yet. Create one!'));
          }

          return ListView.builder(
            itemCount: noteProvider.notes.length,
            itemBuilder: (context, index) {
              final note = noteProvider.notes[index];
              return NoteCard(
                note: note,
                onTap: () {
                  // Chuyển sang màn hình sửa
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NoteEditorScreen(note: note),
                    ),
                  );
                },
                onDelete: () async {
                  // Xác nhận xóa
                  final confirm = await showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Delete Note'),
                      content: const Text(
                        'Are you sure you want to delete this note?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text(
                            'Delete',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    // ignore: use_build_context_synchronously
                    context.read<NoteProvider>().deleteNote(note.id!);
                  }
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Chuyển sang màn hình thêm mới
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NoteEditorScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
