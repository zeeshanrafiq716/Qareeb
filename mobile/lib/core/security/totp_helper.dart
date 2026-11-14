import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

/// RFC 6238 TOTP (Time-Based One-Time Password) Helper
/// Compatible with Google Authenticator, Microsoft Authenticator, 1Password, and Authy.
class TotpHelper {
  static const String _base32Chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';

  /// Generates a random standard 16-character Base32 secret
  static String generateSecret() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';
    final random = Random.secure();
    return List.generate(16, (_) => chars[random.nextInt(chars.length)]).join();
  }

  /// Formats secret into groups of 4 for display: "JBSW Y3DP EHPK 3PXP"
  /// Safe against null/empty/undefined inputs.
  static String formatSecret(String? secret) {
    if (secret == null || secret.isEmpty) return '';
    final clean = secret.toUpperCase().replaceAll(RegExp(r'[^A-Z2-7]'), '');
    if (clean.isEmpty) return '';
    final chunks = <String>[];
    for (int i = 0; i < clean.length; i += 4) {
      final end = (i + 4 <= clean.length) ? i + 4 : clean.length;
      chunks.add(clean.substring(i, end));
    }
    return chunks.join(' ');
  }

  /// Decodes Base32 to raw bytes
  /// Safe against null/empty/undefined inputs.
  static Uint8List? decodeBase32(String? input) {
    if (input == null || input.isEmpty) return null;
    final cleanInput = input.toUpperCase().replaceAll(RegExp(r'[^A-Z2-7]'), '');
    if (cleanInput.isEmpty) return null;

    final List<int> bytes = [];
    int buffer = 0;
    int bitsLeft = 0;

    for (int i = 0; i < cleanInput.length; i++) {
      final val = _base32Chars.indexOf(cleanInput[i]);
      if (val == -1) continue;
      buffer = (buffer << 5) | val;
      bitsLeft += 5;
      if (bitsLeft >= 8) {
        bitsLeft -= 8;
        bytes.add((buffer >> bitsLeft) & 0xFF);
      }
    }
    return Uint8List.fromList(bytes);
  }

  /// Generates standard 6-digit TOTP code (RFC 6238 HMAC-SHA1 30-second step)
  static String generateTotp(String? secret, {int? timeSeconds, int step = 30}) {
    if (secret == null || secret.isEmpty) return '000000';
    final secretBytes = decodeBase32(secret);
    if (secretBytes == null || secretBytes.isEmpty) return '000000';

    final epochSeconds = timeSeconds ?? (DateTime.now().millisecondsSinceEpoch ~/ 1000);
    final counter = epochSeconds ~/ step;

    final counterBytes = Uint8List(8);
    var temp = counter;
    for (int i = 7; i >= 0; i--) {
      counterBytes[i] = temp & 0xFF;
      temp >>= 8;
    }

    final hmac = Hmac(sha1, secretBytes);
    final digest = hmac.convert(counterBytes).bytes;

    final offset = digest[19] & 0x0F;
    final binary = ((digest[offset] & 0x7F) << 24) |
        ((digest[offset + 1] & 0xFF) << 16) |
        ((digest[offset + 2] & 0xFF) << 8) |
        (digest[offset + 3] & 0xFF);

    final otp = binary % 1000000;
    return otp.toString().padLeft(6, '0');
  }

  /// Verifies a TOTP code against secret with ±1 step drift tolerance (90s window).
  /// Verifies authentic RFC 6238 time-based codes from Google Authenticator, Authy, etc.
  static bool verifyTotp(String? secret, String? code) {
    if (code == null) return false;
    final cleanCode = code.trim().replaceAll(RegExp(r'\D'), '');
    if (cleanCode.length != 6) return false;
    if (secret == null || secret.isEmpty) return false;

    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    for (final offset in [-30, 0, 30]) {
      final generated = generateTotp(secret, timeSeconds: now + offset);
      if (generated == cleanCode) {
        return true;
      }
    }
    return false;
  }
}
