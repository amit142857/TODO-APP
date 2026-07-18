import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'cubit/todo_cubit.dart';
import 'data/local/database.dart';
import 'data/repository/todo_repository.dart';
import 'services/encryption_service.dart';
import 'services/notification_service.dart';
import 'ui/screens/todo_list_screen.dart';

void main() {
  runApp(const TodoApp());
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    final database = AppDatabase();
    final encryptionService = EncryptionService();
    final repository = TodoRepository(database, encryptionService);
    final notificationService = NotificationService();

    return MaterialApp(
      title: 'Flutter Todo',
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),
      home: BlocProvider(
        create: (_) => TodoCubit(repository, notificationService)..loadTodos(),
        child: const TodoListScreen(),
      ),
    );
  }
}
