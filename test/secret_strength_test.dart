// Secret-strength tiers: 112 (AAL2), 128 (post-2030 future-proof), 160+ (RFC
// 4226 recommended), and the below-AAL2 warning band.

import 'package:flutter_test/flutter_test.dart';
import 'package:agnosticotp/data/account.dart';

void main() {
  group('SecretStrength.forBits boundaries', () {
    test('below AAL2 (80–111 bits)', () {
      expect(SecretStrength.forBits(80), SecretStrength.belowAal2);
      expect(SecretStrength.forBits(111), SecretStrength.belowAal2);
      expect(SecretStrength.forBits(80).isWeak, isTrue);
    });
    test('AAL2 (112–127)', () {
      expect(SecretStrength.forBits(112), SecretStrength.aal2);
      expect(SecretStrength.forBits(127), SecretStrength.aal2);
      expect(SecretStrength.forBits(112).isWeak, isFalse);
    });
    test('future-proof (128–159)', () {
      expect(SecretStrength.forBits(128), SecretStrength.futureProof);
      expect(SecretStrength.forBits(159), SecretStrength.futureProof);
    });
    test('recommended (>=160)', () {
      expect(SecretStrength.forBits(160), SecretStrength.recommended);
      expect(SecretStrength.forBits(256), SecretStrength.recommended);
    });
    test('labels', () {
      expect(SecretStrength.aal2.label, '112-bit');
      expect(SecretStrength.futureProof.label, '128-bit');
      expect(SecretStrength.recommended.label, '160-bit+');
    });
  });

  group('Account.strength', () {
    test('80-bit secret (16-char base32) flags below AAL2', () {
      // 16 base32 chars = 80 bits.
      final a = Account.create(issuer: 'I', label: 'L', rawSecret: 'A' * 16);
      expect(a.secretBits, 80);
      expect(a.strength, SecretStrength.belowAal2);
    });
    test('160-bit secret (32-char base32) is recommended', () {
      // 32 base32 chars = 160 bits (the RFC 6238 seed length).
      final a = Account.create(
          issuer: 'I', label: 'L', rawSecret: 'GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ');
      expect(a.secretBits, 160);
      expect(a.strength, SecretStrength.recommended);
    });
  });
}
