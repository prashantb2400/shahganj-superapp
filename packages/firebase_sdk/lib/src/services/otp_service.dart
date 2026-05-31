// packages/firebase_sdk/lib/src/services/otp_service.dart
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class OtpService {
  /// Generates a highly random 4-digit numeric string for delivery handoff
  static String generate4Digit() {
    final rand = Random.secure();
    return (1000 + rand.nextInt(9000)).toString();
  }

  /// Converts a plaintext 4-digit OTP into a SHA-256 hex string
  static String hash(String otp) {
    final bytes = utf8.encode(otp);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Locally validates a plaintext OTP against a secure stored SHA-256 hash
  static bool verify(String inputOtp, String storedHash) {
    return hash(inputOtp) == storedHash;
  }
}
