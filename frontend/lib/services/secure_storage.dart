import 'package:encrypt/encrypt.dart' as enc;
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../models/secure_entry.dart';

class SecureStorageService {
  late Isar _isar;
  final enc.Encrypter _encrypter;

  // Use a strong passphrase (in production, derive from biometrics or password)
  SecureStorageService(String secretKey)
    : _encrypter = enc.Encrypter(
        enc.AES(_getKey(secretKey), mode: enc.AESMode.cbc),
      );

  static enc.Key _getKey(String key) {
    // Ensure 32-byte key (AES-256)
    final padded = key.padRight(32).substring(0, 32);
    return enc.Key.fromUtf8(padded);
  }

  final enc.IV _iv = enc.IV.fromLength(16); // Keep fixed or store with entry

  Future<void> init() async {
    final dir = await getApplicationSupportDirectory();
    _isar = await Isar.open([SecureEntrySchema], directory: dir.path);
  }

  Future<void> write({required String key, required String value}) async {
    final encrypted = _encrypter.encrypt(value, iv: _iv);

    await _isar.writeTxn(() async {
      final existing = await _isar.secureEntrys
          .filter()
          .keyEqualTo(key)
          .findFirst();

      if (existing != null) {
        existing.encryptedValue = encrypted.base64;
        await _isar.secureEntrys.put(existing);
      } else {
        await _isar.secureEntrys.put(
          SecureEntry()
            ..key = key
            ..encryptedValue = encrypted.base64,
        );
      }
    });
  }

  Future<String?> read({required String key}) async {
    final entry = await _isar.secureEntrys.filter().keyEqualTo(key).findFirst();
    if (entry == null) return null;

    try {
      final decrypted = _encrypter.decrypt64(entry.encryptedValue, iv: _iv);
      return decrypted;
    } catch (e) {
      print("Decryption error: $e");
      return null;
    }
  }

  Future<void> delete({required String key}) async {
    final entry = await _isar.secureEntrys.getByName(key);
    if (entry != null) {
      await _isar.writeTxn(() async {
        await _isar.secureEntrys.delete(entry.id);
      });
    }
  }

  Future<void> clear() async {
    await _isar.writeTxn(() async {
      await _isar.secureEntrys.clear();
    });
  }
}
