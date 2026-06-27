// Encrypted-backup codec tests: round-trip under both KDFs, the work/personal
// usage mapping, and the security properties (wrong passphrase & tamper both
// rejected, indistinguishably).

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:agnosticotp/data/backup.dart';

void main() {
  const vaultJson =
      '[{"id":"abc","issuer":"ACME","label":"a@x","secret":"GEZDGNBVGY3TQOJQ","algorithm":"SHA256","digits":6,"period":30}]';

  group('usage → KDF policy', () {
    test('work-related selects PBKDF2 (FIPS)', () {
      expect(BackupKdf.forUsage(workRelated: true), BackupKdf.pbkdf2);
    });
    test('personal selects Argon2id (default)', () {
      expect(BackupKdf.forUsage(workRelated: false), BackupKdf.argon2id);
      expect(BackupKdf.defaultKdf, BackupKdf.argon2id);
    });
  });

  group('round-trip', () {
    test('Argon2id (personal default)', () async {
      final env = await BackupCodec.encrypt(
          plaintext: vaultJson, passphrase: 'correct horse battery staple');
      expect(BackupCodec.kdfOf(env), BackupKdf.argon2id); // default
      final out = await BackupCodec.decrypt(
          envelopeJson: env, passphrase: 'correct horse battery staple');
      expect(out, vaultJson);
    });

    test('PBKDF2 (work)', () async {
      final env = await BackupCodec.encrypt(
          plaintext: vaultJson,
          passphrase: 'work pass',
          kdf: BackupKdf.forUsage(workRelated: true));
      expect(BackupCodec.kdfOf(env), BackupKdf.pbkdf2);
      // header records the FIPS KDF + params
      final header = jsonDecode(env) as Map<String, dynamic>;
      expect(header['kdf'], 'pbkdf2-hmac-sha256');
      expect(header['cipher'], 'aes-256-gcm');
      final out = await BackupCodec.decrypt(
          envelopeJson: env, passphrase: 'work pass');
      expect(out, vaultJson);
    });
  });

  group('security properties', () {
    test('wrong passphrase is rejected', () async {
      final env = await BackupCodec.encrypt(
          plaintext: vaultJson, passphrase: 'right', kdf: BackupKdf.pbkdf2);
      expect(
        () => BackupCodec.decrypt(envelopeJson: env, passphrase: 'wrong'),
        throwsA(isA<BackupDecryptException>()),
      );
    });

    test('tampered ciphertext is rejected (GCM auth)', () async {
      final env = await BackupCodec.encrypt(
          plaintext: vaultJson, passphrase: 'pw', kdf: BackupKdf.pbkdf2);
      final m = jsonDecode(env) as Map<String, dynamic>;
      final ct = base64.decode(m['ciphertext'] as String);
      ct[0] ^= 0xFF; // flip a byte
      m['ciphertext'] = base64.encode(ct);
      expect(
        () => BackupCodec.decrypt(
            envelopeJson: jsonEncode(m), passphrase: 'pw'),
        throwsA(isA<BackupDecryptException>()),
      );
    });

    test('empty passphrase refused at encrypt', () async {
      expect(
        () => BackupCodec.encrypt(plaintext: vaultJson, passphrase: ''),
        throwsA(isA<BackupFormatException>()),
      );
    });

    test('non-backup input refused', () async {
      expect(
        () => BackupCodec.decrypt(envelopeJson: '{"hello":1}', passphrase: 'x'),
        throwsA(isA<BackupFormatException>()),
      );
    });
  });
}
