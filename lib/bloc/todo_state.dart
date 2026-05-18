import 'package:equatable/equatable.dart';
import '../../models/todo.dart';

abstract class TodoState extends Equatable {
  const TodoState();
  @override
  List<Object?> get props => [];
}

class TodoInitial extends TodoState {}

class TodoLoading extends TodoState {}

class TodoLoaded extends TodoState {
  final List<Todo> todos;
  final Todo? singleTodo;
  final String message;
  const TodoLoaded({required this.todos, this.singleTodo, required this.message});
  @override
  List<Object?> get props => [todos, singleTodo, message];
}

class TodoError extends TodoState {
  final String error;
  const TodoError(this.error);
  @override
  List<Object> get props => [error];
}