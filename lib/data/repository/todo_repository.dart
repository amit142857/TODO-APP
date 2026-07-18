import '../local/database.dart';
import '../../services/encryption_service.dart';

/// Decrypted, UI-facing todo item (as opposed to the raw Drift `Todo` row,
/// whose title/body fields are still ciphertext).
class TodoItem {
  final int id;
  final String title;
  final String body;
  final DateTime createdAt;

  TodoItem({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
  });
}

class TodoRepository {
  final AppDatabase _db;
  final EncryptionService _encryption;

  TodoRepository(this._db, this._encryption);

  /// Decrypts every row as it streams out of the database.
  Stream<List<TodoItem>> watchTodos() {
    return _db.watchAllTodos().map((rows) => rows
        .map((row) => TodoItem(
              id: row.id,
              title: _encryption.decryptText(row.encryptedTitle),
              body: _encryption.decryptText(row.encryptedBody),
              createdAt: row.createdAt,
            ))
        .toList());
  }

  /// Encrypts before persisting; SQLite only ever stores ciphertext.
  Future<void> addTodo(String title, String body) async {
    await _db.insertTodo(TodosCompanion.insert(
      encryptedTitle: _encryption.encryptText(title),
      encryptedBody: _encryption.encryptText(body),
    ));
  }
}
