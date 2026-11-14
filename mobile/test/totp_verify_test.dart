import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';

class TotpHelper {
  static const String _base32Chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';

  static Uint8List? decodeBase32(String input) {
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

  static String generateTotp(String secret, {int? timeSeconds, int step = 30}) {
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

  static bool verifyTotp(String secret, String code) {
    if (code.length != 6) return false;

    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    for (final offset in [-30, 0, 30]) {
      final generated = generateTotp(secret, timeSeconds: now + offset);
      if (generated == code) {
        return true;
      }
    }
    return false;
  }
}

void main() {
  test('RFC 6238 TOTP Standard Test Vector', () {
    // Secret: "12345678901234567890" in Base32 is GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ
    const secret = 'GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ';
    // RFC 6238 Appendix B test: Time 59s -> TOTP 287082
    final code59 = TotpHelper.generateTotp(secret, timeSeconds: 59);
    expect(code59, equals('287082'));

    // RFC 6238 test: Time 1111111109s -> TOTP 081804
    final codeEpoch = TotpHelper.generateTotp(secret, timeSeconds: 1111111109);
    expect(codeEpoch, equals('081804'));

    // Verify current time works
    final currentCode = TotpHelper.generateTotp(secret);
    expect(TotpHelper.verifyTotp(secret, currentCode), isTrue);

    // Invalid code fails
    expect(TotpHelper.verifyTotp(secret, '000000'), isFalse);
    expect(TotpHelper.verifyTotp(secret, '999999'), isFalse);
  });
}

