import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/repository/todo_repository.dart';
import '../services/notification_service.dart';
import 'todo_state.dart';

class TodoCubit extends Cubit<TodoState> {
  final TodoRepository _repository;
  final NotificationService _notificationService;
  StreamSubscription<List<TodoItem>>? _subscription;

  TodoCubit(this._repository, this._notificationService) : super(TodoInitial());

  void loadTodos() {
    emit(TodoLoading());
    _subscription?.cancel();
    _subscription = _repository.watchTodos().listen(
          (todos) => emit(TodoLoaded(todos)),
          onError: (e) => emit(TodoError(e.toString())),
        );
  }

  Future<void> addTodo(String title, String body) async {
    if (title.trim().isEmpty) return;
    try {
      await _repository.addTodo(title.trim(), body.trim());
      // Fire the native notification after the todo is safely persisted.
      await _notificationService.showTodoNotification(
        title: title.trim(),
        body: body.trim(),
      );
    } catch (e) {
      emit(TodoError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
