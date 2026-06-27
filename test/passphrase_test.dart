// Recovery-passphrase generator tests: format, entropy floor (>120), the two
// random capitals, and randomness. Uses a synthetic 6-letter wordlist so no
// Flutter asset binding is needed.

import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:agnosticotp/data/passphrase.dart';

// Deterministic 6-letter lowercase words (32768 distinct => 15 bits/word).
String _w(int i) {
  const a = 97;
  final b = List<int>.filled(6, a);
  var n = i;
  for (var p = 5; p >= 0 && n > 0; p--) {
    b[p] = a + (n % 26);
    n ~/= 26;
  }
  return String.fromCharCodes(b);
}

final List<String> _wordlist = List.generate(32768, _w);

// prefix(6-8 digits) * 5 words joined by -,+,= / suffix(6-8 digits)
final _format =
    RegExp(r'^\d{6,8}\*[A-Za-z]{6,}(?:[-+=][A-Za-z]{6,}){4}/\d{6,8}$');

void main() {
  group('format', () {
    test('matches number*word-word+word=word-word/number', () {
      final p = PassphraseGenerator.generate(words: _wordlist);
      expect(p.value, matches(_format), reason: p.value);
    });

    test('exactly two random uppercase letters', () {
      for (var seed = 0; seed < 20; seed++) {
        final p =
            PassphraseGenerator.generate(words: _wordlist, rng: Random(seed));
        final uppers = p.value.runes
            .where((r) => r >= 0x41 && r <= 0x5a) // A-Z
            .length;
        expect(uppers, 2, reason: p.value);
      }
    });

    test('numbers are 6-8 digits each', () {
      final p = PassphraseGenerator.generate(words: _wordlist);
      final m = RegExp(r'^(\d+)\*.*/(\d+)$').firstMatch(p.value)!;
      expect(m.group(1)!.length, inInclusiveRange(6, 8));
      expect(m.group(2)!.length, inInclusiveRange(6, 8));
    });
  });

  group('entropy', () {
    test('generated passphrase clears the 120-bit floor', () {
      for (var seed = 0; seed < 25; seed++) {
        final p =
            PassphraseGenerator.generate(words: _wordlist, rng: Random(seed));
        expect(p.entropyBits, greaterThanOrEqualTo(120.0), reason: p.value);
      }
    });

    test('entropyBits accounts for words + digits + caps', () {
      final bits = PassphraseGenerator.entropyBits(
          wordlistSize: 32768,
          wordCount: 5,
          digits: 12,
          numLetters: 30,
          randomCaps: 2);
      // 5*15 + 12*log2(10) + log2(C(30,2)) ≈ 75 + 39.9 + 8.9
      expect(bits, greaterThan(120.0));
    });

    test('too-small wordlist is rejected', () {
      expect(() => PassphraseGenerator.generate(words: const ['abcdef']),
          throwsArgumentError);
    });
  });

  group('randomness', () {
    test('two generations differ', () {
      final a = PassphraseGenerator.generate(words: _wordlist).value;
      final b = PassphraseGenerator.generate(words: _wordlist).value;
      expect(a, isNot(b));
    });
  });
}
