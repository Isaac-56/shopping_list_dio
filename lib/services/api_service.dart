import 'package:dio/dio.dart';
import '../models/todo.dart';

class ApiService {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'https://dummyjson.com'));

  Future<List<Todo>> getTodos() async {
    final response = await _dio.get('/todos');
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = response.data;
      final List<dynamic> todos = data['todos'];
      List<Todo> all = todos.map((json) => Todo.fromJson(json)).toList();
      return all.take(5).toList();
    }
    throw Exception('Failed to load todos');
  }

  Future<Todo> getTodoById(int id) async {
    final response = await _dio.get('/todos/$id');
    if (response.statusCode == 200) {
      return Todo.fromJson(response.data);
    }
    throw Exception('Todo not found');
  }

  Future<Todo> createTodo(Todo todo) async {
    final response = await _dio.post('/todos/add', data: todo.toJson());
    if (response.statusCode == 201 || response.statusCode == 200) {
      return Todo.fromJson(response.data);
    }
    throw Exception('Create failed');
  }

  Future<Todo> updateTodo(int id, Todo todo) async {
    final response = await _dio.put('/todos/$id', data: todo.toJson());
    if (response.statusCode == 200) {
      return Todo.fromJson(response.data);
    }
    throw Exception('Update failed');
  }

  Future<void> deleteTodo(int id) async {
    final response = await _dio.delete('/todos/$id');
    if (response.statusCode != 200) {
      throw Exception('Delete failed');
    }
  }
}
