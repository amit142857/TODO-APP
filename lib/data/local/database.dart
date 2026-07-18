import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'database.g.dart';

/// Todos are stored with title/body already AES-encrypted (ciphertext,
/// base64-encoded) by [EncryptionService]. Drift/SQLite never sees plaintext.
class Todos extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get encryptedTitle => text()();
  TextColumn get encryptedBody => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(tables: [Todos])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  Stream<List<Todo>> watchAllTodos() {
    return (select(todos)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch();
  }

  Future<int> insertTodo(TodosCompanion entry) => into(todos).insert(entry);
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'todos.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
