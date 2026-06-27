// Importer tests. Builds a genuine Google-Authenticator-format MigrationPayload
// protobuf in-test (tiny encoder below) and asserts: TOTP entries import, HOTP
// is skipped, the unspecified-algorithm => SHA1 rule holds, and an imported
// secret regenerates the correct RFC 6238 code (so a decode bug can't hide).

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:agnosticotp/core/migration_import.dart';
import 'package:agnosticotp/core/totp.dart';

// --- tiny protobuf encoder (mirror of the reader under test) ---
List<int> _varint(int v) {
  final out = <int>[];
  var n = v;
  while (true) {
    final b = n & 0x7f;
    n >>= 7;
    if (n != 0) {
      out.add(b | 0x80);
    } else {
      out.add(b);
      break;
    }
  }
  return out;
}

List<int> _tag(int field, int wire) => _varint((field << 3) | wire);
List<int> _lenField(int field, List<int> bytes) =>
    [..._tag(field, 2), ..._varint(bytes.length), ...bytes];
List<int> _varField(int field, int value) =>
    [..._tag(field, 0), ..._varint(value)];

/// One OtpParameters message.
List<int> _otp({
  required List<int> secret,
  required String name,
  String issuer = '',
  int? algo, // null => omit field (unspecified)
  int digits = 1, // 1=six, 2=eight
  int type = 2, // 1=hotp, 2=totp
}) =>
    [
      ..._lenField(1, secret),
      ..._lenField(2, utf8.encode(name)),
      if (issuer.isNotEmpty) ..._lenField(3, utf8.encode(issuer)),
      if (algo != null) ..._varField(4, algo),
      ..._varField(5, digits),
      ..._varField(6, type),
    ];

String _migrationUri(List<List<int>> otps) {
  final payload = <int>[];
  for (final o in otps) {
    payload.addAll(_lenField(1, o)); // repeated otp_parameters
  }
  final data = base64.encode(payload);
  return 'otpauth-migration://offline?data=${Uri.encodeQueryComponent(data)}';
}

// RFC 6238 SHA1 seed "12345678901234567890" and its base32.
final _seed = Uint8List.fromList(utf8.encode('12345678901234567890'));
const _seedB32 = 'GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ';
DateTime _utc(int s) => DateTime.fromMillisecondsSinceEpoch(s * 1000, isUtc: true);

void main() {
  group('Google Authenticator migration import', () {
    test('imports TOTP, skips HOTP, applies digits', () {
      final uri = _migrationUri([
        _otp(
            secret: _seed,
            name: 'Example:alice@google.com',
            issuer: 'Example',
            algo: 1, // SHA1
            digits: 2, // eight
            type: 2),
        _otp(secret: _seed, name: 'CounterThing', algo: 1, type: 1), // HOTP
      ]);

      final result = AuthenticatorImport.fromMigrationUri(uri);
      expect(result.importedCount, 1);
      expect(result.skippedCount, 1);
      expect(result.skipped.first, contains('HOTP'));

      final a = result.accounts.single;
      expect(a.issuer, 'Example');
      expect(a.label, 'alice@google.com');
      expect(a.secretBase32, _seedB32);
      expect(a.algorithm, TotpAlgorithm.sha1);
      expect(a.params.digits, 8);

      // The imported secret must regenerate the real RFC 6238 SHA1 vector.
      final gen = TotpGenerator(a.params);
      expect(gen.code(a.keyBytes(), now: _utc(59)), '94287082');
    });

    test('unspecified algorithm => SHA1 (preserve legacy secrets)', () {
      final uri = _migrationUri([
        _otp(secret: _seed, name: 'NoAlgo', algo: null, type: 2),
      ]);
      final r = AuthenticatorImport.fromMigrationUri(uri);
      expect(r.accounts.single.algorithm, TotpAlgorithm.sha1);
    });

    test('SHA256 / SHA512 preserved', () {
      final uri = _migrationUri([
        _otp(secret: _seed, name: 'a256', algo: 2, type: 2),
        _otp(secret: _seed, name: 'a512', algo: 3, type: 2),
      ]);
      final r = AuthenticatorImport.fromMigrationUri(uri);
      final algos = r.accounts.map((a) => a.algorithm).toSet();
      expect(algos, {TotpAlgorithm.sha256, TotpAlgorithm.sha512});
    });

    test('non-migration URI rejected', () {
      expect(() => AuthenticatorImport.fromMigrationUri('https://x'),
          throwsA(anything));
    });
  });

  group('otpauth URI list (browser/extension export)', () {
    test('imports multiple otpauth:// lines and dedupes', () {
      final text = '''
otpauth://totp/GitHub:octo?secret=$_seedB32&algorithm=SHA256
otpauth://totp/GitLab:dev?secret=$_seedB32&algorithm=SHA1

otpauth://totp/GitHub:octo?secret=$_seedB32&algorithm=SHA256
not-a-uri
''';
      final r = AuthenticatorImport.fromText(text);
      expect(r.importedCount, 2); // duplicate GitHub collapsed
      expect(r.skipped, isNotEmpty); // the "not-a-uri" line
      expect(r.accounts.map((a) => a.issuer), containsAll(['GitHub', 'GitLab']));
    });

    test('fromText also handles an embedded migration URI', () {
      final mig = _migrationUri([_otp(secret: _seed, name: 'M', algo: 2)]);
      final r = AuthenticatorImport.fromText(
          'otpauth://totp/A?secret=$_seedB32\n$mig');
      expect(r.importedCount, 2);
    });
  });
}
