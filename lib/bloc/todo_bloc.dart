import 'package:flutter_bloc/flutter_bloc.dart';
import 'todo_event.dart';
import 'todo_state.dart';
import '../../services/api_service.dart';
import '../../models/todo.dart';

class TodoBloc extends Bloc<TodoEvent, TodoState> {
  final ApiService _apiService = ApiService();

  TodoBloc() : super(TodoInitial()) {
    on<FetchTodos>(_onFetchTodos);
    on<FetchSingleTodo>(_onFetchSingleTodo);
    on<AddTodo>(_onAddTodo);
    on<UpdateTodo>(_onUpdateTodo);
    on<DeleteTodo>(_onDeleteTodo);
  }

  Future<void> _onFetchTodos(FetchTodos event, Emitter<TodoState> emit) async {
    emit(TodoLoading());
    try {
      final todos = await _apiService.getTodos();
      emit(TodoLoaded(todos: todos, message: 'Fetched ${todos.length} todos'));
    } catch (e) {
      emit(TodoError('Error: $e'));
    }
  }

  Future<void> _onFetchSingleTodo(FetchSingleTodo event, Emitter<TodoState> emit) async {
    final previousState = state;
    List<Todo> previousTodos = [];
    if (previousState is TodoLoaded) {
      previousTodos = previousState.todos;
    }
    emit(TodoLoading());
    try {
      final todo = await _apiService.getTodoById(event.id);
      emit(TodoLoaded(todos: previousTodos, singleTodo: todo, message: 'Fetched: ${todo.title}'));
    } catch (e) {
      emit(TodoError('Error: $e'));
    }
  }

  Future<void> _onAddTodo(AddTodo event, Emitter<TodoState> emit) async {
    List<Todo> previousTodos = [];
    if (state is TodoLoaded) {
      previousTodos = (state as TodoLoaded).todos;
    }
    emit(TodoLoading());
    try {
      final newTodo = await _apiService.createTodo(event.todo);
      final updatedTodos = [newTodo, ...previousTodos].take(5).toList();
      emit(TodoLoaded(todos: updatedTodos, message: 'Added: ${newTodo.title}'));
    } catch (e) {
      emit(TodoError('Error: $e'));
    }
  }

  Future<void> _onUpdateTodo(UpdateTodo event, Emitter<TodoState> emit) async {
    List<Todo> previousTodos = [];
    if (state is TodoLoaded) {
      previousTodos = (state as TodoLoaded).todos;
    }
    emit(TodoLoading());
    try {
      final updated = await _apiService.updateTodo(event.id, event.todo);
      final newTodos = previousTodos.map((t) => t.id == event.id ? updated : t).toList();
      emit(TodoLoaded(todos: newTodos, message: 'Updated: ${updated.title}'));
    } catch (e) {
      emit(TodoError('Error: $e'));
    }
  }

  Future<void> _onDeleteTodo(DeleteTodo event, Emitter<TodoState> emit) async {
    List<Todo> previousTodos = [];
    if (state is TodoLoaded) {
      previousTodos = (state as TodoLoaded).todos;
    }
    emit(TodoLoading());
    try {
      await _apiService.deleteTodo(event.id);
      final newTodos = previousTodos.where((t) => t.id != event.id).toList();
      emit(TodoLoaded(todos: newTodos, message: 'Deleted todo id ${event.id}'));
    } catch (e) {
      emit(TodoError('Error: $e'));
    }
  }
}
