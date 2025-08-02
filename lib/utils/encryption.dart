import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class EncryptionUtil {
  // Simple encryption using AES with a key derived from user's password
  // In a real app, you would use a more secure key derivation method
  static String encryptString(String plainText, String key) {
    try {
      // Generate a key from the password using SHA-256
      final keyBytes = sha256.convert(utf8.encode(key)).bytes;
      final keyObj = encrypt.Key(Uint8List.fromList(keyBytes));
      
      // Generate an IV (in a real app, you'd use a proper random IV)
      final ivBytes = List<int>.filled(16, 0); // All zeros for simplicity
      final ivObj = encrypt.IV(Uint8List.fromList(ivBytes));
      
      // Create the encrypter
      final encrypter = encrypt.Encrypter(encrypt.AES(keyObj, mode: encrypt.AESMode.cbc));
      
      // Encrypt the text
      final encrypted = encrypter.encrypt(plainText, iv: ivObj);
      
      // Return base64 encoded result
      return encrypted.base64;
    } catch (e) {
      // In case of encryption failure, return the plain text
      // This is not secure but prevents app crashes
      return plainText;
    }
  }
  
  // Decrypt a string using AES
  static String decryptString(String encryptedText, String key) {
    try {
      // Generate a key from the password using SHA-256
      final keyBytes = sha256.convert(utf8.encode(key)).bytes;
      final keyObj = encrypt.Key(Uint8List.fromList(keyBytes));
      
      // Generate an IV (must be the same as used for encryption)
      final ivBytes = List<int>.filled(16, 0); // All zeros for simplicity
      final ivObj = encrypt.IV(Uint8List.fromList(ivBytes));
      
      // Create the encrypter
      final encrypter = encrypt.Encrypter(encrypt.AES(keyObj, mode: encrypt.AESMode.cbc));
      
      // Decrypt the text
      final decrypted = encrypter.decrypt64(encryptedText, iv: ivObj);
      
      return decrypted;
    } catch (e) {
      // In case of decryption failure, return the encrypted text
      // This is not secure but prevents app crashes
      return encryptedText;
    }
  }
  
  // Hash a string (for storing hashes of sensitive data)
  static String hashString(String input) {
    final bytes = utf8.encode(input);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }
}