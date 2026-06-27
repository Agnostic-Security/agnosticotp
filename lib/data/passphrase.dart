// AgnosticOTP — recovery-passphrase generator.
//
// Format the product settled on (5 words → ~128 bits, comfortably > 120):
//   4821760*velVet-annexing+veracIty=pregnant-mariTime/93715204
//   └prefix┘│└ five 6+ letter words joined by ───────┘│└ suffix ┘
//    number * cycling -, +, =, - with TWO random        / number
//            uppercase letters
//
// ENTROPY (every component below is uniformly random; only the fixed separator
// pattern `*`, `-`, `+`, `=`, `/` contributes nothing):
//   words   : wordCount * log2(wordlistSize)
//   numbers : (prefixLen + suffixLen) * log2(10),  each number 6..8 digits
//   caps    : log2( C(numLetters, randomCaps) )    two random capitals
// Sized to stay above [minEntropyBits] (>90). The passphrase is GENERATED
// (never user-invented) and stored in a password manager — the B-HIGH-1 fix.

import 'dart:math';

import 'package:flutter/services.dart' show rootBundle;

class GeneratedPassphrase {
  GeneratedPassphrase(this.value, this.entropyBits);

  /// e.g. `4821760*velVet-annexing+veracIty=pregnant/93715204`.
  final String value;

  /// Estimated entropy in bits (words + numbers + random caps).
  final double entropyBits;
}

class PassphraseGenerator {
  PassphraseGenerator._();

  static const List<String> _separators = ['-', '+', '='];
  static const int defaultWordCount = 5; // ~128 bits with the numbers below
  static const int defaultMinDigits = 6; // per number
  static const int defaultMaxDigits = 8; // per number (cap)
  static const int defaultRandomCaps = 2;

  /// Hard floor for an offline-attacked cloud backup (target >120; pentest B-HIGH-1).
  static const double minEntropyBits = 120;

  /// Languages we ship a 6+ letter wordlist for. Others fall back to English.
  static const Set<String> supportedLanguages = {'en'};

  /// Generate a recovery passphrase from [words] (a 6+ letter wordlist).
  static GeneratedPassphrase generate({
    required List<String> words,
    int wordCount = defaultWordCount,
    int minDigits = defaultMinDigits,
    int maxDigits = defaultMaxDigits,
    int randomCaps = defaultRandomCaps,
    Random? rng,
  }) {
    if (words.length < 256) {
      throw ArgumentError('Wordlist too small for safe generation.');
    }
    if (minDigits < 1 || maxDigits < minDigits) {
      throw ArgumentError('Invalid digit bounds.');
    }
    final r = rng ?? Random.secure();

    String number() {
      final len = minDigits + r.nextInt(maxDigits - minDigits + 1);
      final b = StringBuffer();
      for (var i = 0; i < len; i++) {
        b.write(r.nextInt(10));
      }
      return b.toString();
    }

    final prefix = number();
    final suffix = number();

    final chosen = <String>[
      for (var i = 0; i < wordCount; i++) words[r.nextInt(words.length)],
    ];
    final wordsSb = StringBuffer(chosen.first);
    for (var i = 1; i < wordCount; i++) {
      wordsSb
        ..write(_separators[(i - 1) % _separators.length])
        ..write(chosen[i]);
    }

    // prefix * words / suffix
    final chars = '$prefix*$wordsSb/$suffix'.split('');

    // Uppercase `randomCaps` distinct random letter positions (only the words
    // contain a-z, so caps always land on word letters).
    final letterPositions = <int>[
      for (var i = 0; i < chars.length; i++)
        if (_isLower(chars[i])) i,
    ];
    final caps = randomCaps.clamp(0, letterPositions.length);
    final picked = <int>{};
    while (picked.length < caps) {
      picked.add(letterPositions[r.nextInt(letterPositions.length)]);
    }
    for (final i in picked) {
      chars[i] = chars[i].toUpperCase();
    }

    final bits = entropyBits(
      wordlistSize: words.length,
      wordCount: wordCount,
      digits: prefix.length + suffix.length,
      numLetters: letterPositions.length,
      randomCaps: caps,
    );
    if (bits < minEntropyBits) {
      throw StateError(
          'Configuration yields ${bits.toStringAsFixed(1)} bits, below the '
          '$minEntropyBits-bit floor. Increase wordCount or digits.');
    }
    return GeneratedPassphrase(chars.join(), bits);
  }

  /// Entropy from the random components (words + total digits + random caps).
  static double entropyBits({
    required int wordlistSize,
    int wordCount = defaultWordCount,
    int digits = 2 * defaultMinDigits,
    int numLetters = 0,
    int randomCaps = 0,
  }) {
    final wordBits = wordCount * (log(wordlistSize) / ln2);
    final digitBits = digits * (ln10 / ln2);
    final capsBits = _log2Choose(numLetters, randomCaps);
    return wordBits + digitBits + capsBits;
  }

  static bool _isLower(String c) {
    final u = c.codeUnitAt(0);
    return u >= 0x61 && u <= 0x7a; // a-z
  }

  /// log2( C(n, k) ) — extra entropy from choosing k of n positions to capitalise.
  static double _log2Choose(int n, int k) {
    if (k <= 0 || k > n) return 0;
    var bits = 0.0;
    for (var i = 0; i < k; i++) {
      bits += (log(n - i) / ln2) - (log(i + 1) / ln2);
    }
    return bits;
  }

  /// Load the 6+ letter wordlist for [localeCode], falling back to English.
  static Future<List<String>> loadWordlist(String localeCode) async {
    final lang = supportedLanguages.contains(localeCode) ? localeCode : 'en';
    final raw = await rootBundle.loadString('assets/wordlists/$lang.txt');
    return raw
        .split('\n')
        .map((w) => w.trim())
        .where((w) => w.isNotEmpty)
        .toList(growable: false);
  }
}
