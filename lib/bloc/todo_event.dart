import 'package:equatable/equatable.dart';
import '../../models/todo.dart';

abstract class TodoEvent extends Equatable {
  const TodoEvent();
  @override
  List<Object?> get props => [];
}

class FetchTodos extends TodoEvent {}

class FetchSingleTodo extends TodoEvent {
  final int id;
  const FetchSingleTodo(this.id);
  @override
  List<Object> get props => [id];
}

class AddTodo extends TodoEvent {
  final Todo todo;
  const AddTodo(this.todo);
  @override
  List<Object> get props => [todo];
}

class UpdateTodo extends TodoEvent {
  final int id;
  final Todo todo;
  const UpdateTodo(this.id, this.todo);
  @override
  List<Object> get props => [id, todo];
}

class DeleteTodo extends TodoEvent {
  final int id;
  const DeleteTodo(this.id);
  @override
  List<Object> get props => [id];
}