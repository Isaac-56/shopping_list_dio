import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/todo_bloc.dart';
import '../bloc/todo_event.dart';
import '../bloc/todo_state.dart';
import '../models/todo.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _updateIdController = TextEditingController();
  final TextEditingController _updateTitleController = TextEditingController();
  final TextEditingController _deleteIdController = TextEditingController();
  bool _completed = false;
  bool _updateCompleted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('To Do (dio + Bloc)'),
        backgroundColor: const Color(0xFFFFFDD0),
        foregroundColor: Colors.black,
      ),
      body: BlocBuilder<TodoBloc, TodoState>(
        builder: (context, state) {
          final bloc = context.read<TodoBloc>();
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                if (state is TodoLoading)
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Loading...'),
                  ),
                if (state is TodoError)
                  Container(
                    padding: const EdgeInsets.all(8),
                    color: Colors.red[100],
                    child: Text(state.error),
                  ),
                if (state is TodoLoaded && state.message.isNotEmpty)
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
                          onPressed: () => bloc.add(FetchTodos()),
                          child: const Text('GET ALL'),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            minimumSize: const Size(160, 48),
                          ),
                          onPressed: () => _showGetSingleDialog(bloc),
                          child: const Text('GET SINGLE'),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            minimumSize: const Size(160, 48),
                          ),
                          onPressed: () => _showCreateDialog(bloc),
                          child: const Text('CREATE'),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            minimumSize: const Size(160, 48),
                          ),
                          onPressed: () => _showUpdateDialog(bloc),
                          child: const Text('UPDATE'),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            minimumSize: const Size(160, 48),
                          ),
                          onPressed: () => _showDeleteDialog(bloc),
                          child: const Text('DELETE'),
                        ),
                      ],
                    ),
                  ),
                ),
                if (state is TodoLoaded && state.todos.isNotEmpty)
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
                            itemCount: state.todos.length,
                            itemBuilder: (ctx, index) {
                              final todo = state.todos[index];
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
                if (state is TodoLoaded && state.singleTodo != null)
                  Card(
                    color: Colors.lightGreen[100],
                    child: ListTile(
                      title: Text(state.singleTodo!.title),
                      subtitle: Text(
                        'ID: ${state.singleTodo!.id}\nCompleted: ${state.singleTodo!.completed}',
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showGetSingleDialog(TodoBloc bloc) {
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
                if (id != null) {
                  bloc.add(FetchSingleTodo(id));
                }
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

  void _showCreateDialog(TodoBloc bloc) {
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
                  bloc.add(AddTodo(newTodo));
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

  void _showUpdateDialog(TodoBloc bloc) {
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
                  bloc.add(UpdateTodo(id, updatedTodo));
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

  void _showDeleteDialog(TodoBloc bloc) {
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
                if (id != null) {
                  bloc.add(DeleteTodo(id));
                }
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