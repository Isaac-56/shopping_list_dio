import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/todo.dart';
import '../services/api_service.dart';

final todoProvider = StateNotifierProvider<TodoNotifier, TodoState>((ref) {
  return TodoNotifier();
});

class TodoState {
  final List<Todo> items;
  final bool isLoading;
  final String message;
  final Todo? singleItem;

  TodoState({required this.items, this.isLoading = false, this.message = '', this.singleItem});
}

class TodoNotifier extends StateNotifier<TodoState> {
  final ApiService _api = ApiService();

  TodoNotifier() : super(TodoState(items: []));

  Future<void> fetchAll() async {
    state = TodoState(items: state.items, isLoading: true);
    try {
      final items = await _api.getTodos();
      state = TodoState(items: items, message: 'Fetched ${items.length} todos');
    } catch (e) {
      state = TodoState(items: [], message: 'Error: $e');
    }
  }

  Future<void> fetchSingle(int id) async {
    state = TodoState(items: state.items, isLoading: true);
    try {
      final item = await _api.getTodoById(id);
      state = TodoState(items: state.items, singleItem: item, message: 'Fetched: ${item.title}');
    } catch (e) {
      state = TodoState(items: state.items, message: 'Error: $e');
    }
  }

  Future<void> addTodo(Todo todo) async {
    state = TodoState(items: state.items, isLoading: true);
    try {
      final newItem = await _api.createTodo(todo);
      final newList = [newItem, ...state.items].take(5).toList();
      state = TodoState(items: newList, message: 'Added: ${newItem.title}');
    } catch (e) {
      state = TodoState(items: state.items, message: 'Error: $e');
    }
  }

  Future<void> updateTodo(int id, Todo todo) async {
    state = TodoState(items: state.items, isLoading: true);
    try {
      final updated = await _api.updateTodo(id, todo);
      final newList = state.items.map((i) => i.id == id ? updated : i).toList();
      state = TodoState(items: newList, message: 'Updated: ${updated.title}');
    } catch (e) {
      state = TodoState(items: state.items, message: 'Error: $e');
    }
  }

  Future<void> deleteTodo(int id) async {
    state = TodoState(items: state.items, isLoading: true);
    try {
      await _api.deleteTodo(id);
      final newList = state.items.where((i) => i.id != id).toList();
      state = TodoState(items: newList, message: 'Deleted todo id $id');
    } catch (e) {
      state = TodoState(items: state.items, message: 'Error: $e');
    }
  }
}
