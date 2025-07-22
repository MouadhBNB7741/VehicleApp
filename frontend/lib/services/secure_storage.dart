import 'package:encrypt/encrypt.dart' as enc;
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../models/secure_entry.dart';
import 'dart:convert';

class SecureStorageService {
  late Isar _isar;
  final enc.Encrypter _encrypter;

  SecureStorageService(String secretKey)
    : _encrypter = enc.Encrypter(
        enc.AES(_getKey(secretKey), mode: enc.AESMode.cbc),
      );

  static enc.Key _getKey(String key) {
    final padded = key.padRight(32).substring(0, 32);
    return enc.Key.fromUtf8(padded);
  }

  Future<void> init() async {
    final dir = await getApplicationSupportDirectory();
    _isar = await Isar.open([SecureEntrySchema], directory: dir.path);
  }

  Future<void> write({required String key, required String value}) async {
    final iv = enc.IV.fromSecureRandom(16);
    final encrypted = _encrypter.encrypt(value, iv: iv);

    final jsonPayload = jsonEncode({'iv': iv.base64, 'data': encrypted.base64});

    await _isar.writeTxn(() async {
      final existing = await _isar.secureEntrys
          .filter()
          .keyEqualTo(key)
          .findFirst();

      if (existing != null) {
        existing.encryptedValue = jsonPayload;
        await _isar.secureEntrys.put(existing);
      } else {
        await _isar.secureEntrys.put(
          SecureEntry()
            ..key = key
            ..encryptedValue = jsonPayload,
        );
      }
    });
  }

  Future<String?> read({required String key}) async {
    final entry = await _isar.secureEntrys.filter().keyEqualTo(key).findFirst();
    if (entry == null) return null;

    try {
      final value = entry.encryptedValue;

      if (value.trim().startsWith('{')) {
        final payload = jsonDecode(value);
        final iv = enc.IV.fromBase64(payload['iv']);
        final data = payload['data'];

        final decrypted = _encrypter.decrypt64(data, iv: iv);
        return decrypted;
      } else {
        print("⚠️ Old format detected.");
        final iv = enc.IV.fromLength(16);
        return _encrypter.decrypt64(value, iv: iv);
      }
    } catch (e) {
      print("Decryption error: $e");
      return null;
    }
  }

  Future<void> delete({required String key}) async {
    final entry = await _isar.secureEntrys.filter().keyEqualTo(key).findFirst();
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
