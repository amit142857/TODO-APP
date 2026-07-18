import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/repository/todo_repository.dart';

class TodoTile extends StatelessWidget {
  final TodoItem todo;
  const TodoTile({super.key, required this.todo});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const CircleAvatar(child: Icon(Icons.check_box_outline_blank)),
      title: Text(todo.title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(todo.body),
      trailing: Text(DateFormat.Hm().format(todo.createdAt)),
    );
  }
}
