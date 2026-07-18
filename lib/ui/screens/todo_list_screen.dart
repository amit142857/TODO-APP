import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubit/todo_cubit.dart';
import '../../cubit/todo_state.dart';
import '../widgets/todo_tile.dart';
import 'add_todo_screen.dart';

class TodoListScreen extends StatelessWidget {
  const TodoListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Todos')),
      body: BlocBuilder<TodoCubit, TodoState>(
        builder: (context, state) {
          if (state is TodoLoading || state is TodoInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is TodoError) {
            return Center(child: Text('Something went wrong: ${state.message}'));
          }
          if (state is TodoLoaded) {
            if (state.todos.isEmpty) {
              return const Center(child: Text('No todos yet. Tap + to add one.'));
            }
            return ListView.builder(
              itemCount: state.todos.length,
              itemBuilder: (context, index) => TodoTile(todo: state.todos[index]),
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<TodoCubit>(),
                child: const AddTodoScreen(),
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
