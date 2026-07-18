import 'package:encrypt/encrypt.dart' as enc;

/// Encrypts/decrypts todo text using AES-256 (CBC mode) with a random IV
/// per message. The IV is stored alongside the ciphertext (both base64,
/// joined with ':') since IVs aren't secret, only unique.
///
/// NOTE: For a production app, don't hardcode the key in source. Generate
/// it once and store it with `flutter_secure_storage` (Android Keystore /
/// iOS Keychain backed), then load it here instead of `_secretKey`.
class EncryptionService {
  static const _secretKey =
      'abcdefghijklmnopqrstuvwxyz012345'; //AES-256
  final enc.Key _key = enc.Key.fromUtf8(_secretKey);

  String encryptText(String plainText) {
    final iv = enc.IV.fromSecureRandom(16);
    final encrypter = enc.Encrypter(enc.AES(_key, mode: enc.AESMode.cbc));
    final encrypted = encrypter.encrypt(plainText, iv: iv);
    return '${iv.base64}:${encrypted.base64}';
  }

  String decryptText(String cipherWithIv) {
    final parts = cipherWithIv.split(':');
    final iv = enc.IV.fromBase64(parts[0]);
    final encrypter = enc.Encrypter(enc.AES(_key, mode: enc.AESMode.cbc));
    return encrypter.decrypt64(parts[1], iv: iv);
  }
}
