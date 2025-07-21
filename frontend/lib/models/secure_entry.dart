import 'package:isar/isar.dart';
part 'secure_entry.g.dart';

@collection
class SecureEntry {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  String key = '';

  String encryptedValue = '';
  DateTime? expiresAt;

  @Index(unique: true)
  String get name => key;
}
