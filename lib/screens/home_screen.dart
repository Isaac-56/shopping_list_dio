import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/todo_provider.dart';
import '../models/todo.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _updateIdController = TextEditingController();
  final TextEditingController _updateTitleController = TextEditingController();
  final TextEditingController _deleteIdController = TextEditingController();
  bool _completed = false;
  bool _updateCompleted = false;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(todoProvider);
    final notifier = ref.read(todoProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('To Do'),
        backgroundColor: const Color(0xFFFFFDD0),
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (state.message.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(8),
                color: Colors.grey[200],
                child: Text(state.message),
              ),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        minimumSize: const Size(160, 48),
                      ),
                      onPressed: () => notifier.fetchAll(),
                      child: const Text('GET ALL'),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        minimumSize: const Size(160, 48),
                      ),
                      onPressed: () => _showGetSingleDialog(notifier),
                      child: const Text('GET SINGLE'),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        minimumSize: const Size(160, 48),
                      ),
                      onPressed: () => _showCreateDialog(notifier),
                      child: const Text('CREATE'),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        minimumSize: const Size(160, 48),
                      ),
                      onPressed: () => _showUpdateDialog(notifier),
                      child: const Text('UPDATE'),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        minimumSize: const Size(160, 48),
                      ),
                      onPressed: () => _showDeleteDialog(notifier),
                      child: const Text('DELETE'),
                    ),
                  ],
                ),
              ),
            ),
            if (state.items.isNotEmpty)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'All Todos',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView.builder(
                        itemCount: state.items.length,
                        itemBuilder: (ctx, index) {
                          final todo = state.items[index];
                          return Card(
                            child: ListTile(
                              title: Text(todo.title),
                              subtitle: Text('ID: ${todo.id} | User: ${todo.userId}'),
                              trailing: Icon(
                                todo.completed ? Icons.check_circle : Icons.pending,
                                color: todo.completed ? Colors.green : Colors.orange,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            if (state.singleItem != null)
              Card(
                color: Colors.lightGreen[100],
                child: ListTile(
                  title: Text(state.singleItem!.title),
                  subtitle: Text(
                    'ID: ${state.singleItem!.id}\nCompleted: ${state.singleItem!.completed}',
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showGetSingleDialog(TodoNotifier notifier) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Get Single Todo'),
          content: TextField(
            controller: _idController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Todo ID'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black),
              onPressed: () {
                final id = int.tryParse(_idController.text);
                if (id != null) notifier.fetchSingle(id);
                _idController.clear();
                Navigator.pop(ctx);
              },
              child: const Text('Fetch'),
            ),
          ],
        );
      },
    );
  }

  void _showCreateDialog(TodoNotifier notifier) {
    _titleController.clear();
    _completed = false;
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Create New Todo'),
          content: StatefulBuilder(
            builder: (context, setStateDialog) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'Title'),
                  ),
                  Row(
                    children: [
                      const Text('Completed: '),
                      Checkbox(
                        value: _completed,
                        onChanged: (value) {
                          setStateDialog(() {
                            _completed = value!;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black),
              onPressed: () {
                if (_titleController.text.isNotEmpty) {
                  final newTodo = Todo(
                    userId: 1,
                    title: _titleController.text,
                    completed: _completed,
                  );
                  notifier.addTodo(newTodo);
                }
                Navigator.pop(ctx);
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  void _showUpdateDialog(TodoNotifier notifier) {
    _updateIdController.clear();
    _updateTitleController.clear();
    _updateCompleted = false;
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Update Todo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _updateIdController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Todo ID'),
              ),
              TextField(
                controller: _updateTitleController,
                decoration: const InputDecoration(labelText: 'New Title'),
              ),
              Row(
                children: [
                  const Text('Completed: '),
                  Checkbox(
                    value: _updateCompleted,
                    onChanged: (value) {
                      setState(() {
                        _updateCompleted = value!;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black),
              onPressed: () {
                final id = int.tryParse(_updateIdController.text);
                if (id != null && _updateTitleController.text.isNotEmpty) {
                  final updatedTodo = Todo(
                    userId: 1,
                    title: _updateTitleController.text,
                    completed: _updateCompleted,
                  );
                  notifier.updateTodo(id, updatedTodo);
                }
                Navigator.pop(ctx);
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteDialog(TodoNotifier notifier) {
    _deleteIdController.clear();
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Delete Todo'),
          content: TextField(
            controller: _deleteIdController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Todo ID'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black),
              onPressed: () {
                final id = int.tryParse(_deleteIdController.text);
                if (id != null) notifier.deleteTodo(id);
                _deleteIdController.clear();
                Navigator.pop(ctx);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}