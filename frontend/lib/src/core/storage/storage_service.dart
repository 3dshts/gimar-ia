// frontend/lib/src/core/storage/storage_service.dart

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer; // Usaremos el logger de Dart

class StorageService {
  static const _tokenKey = 'jwt_token';

  StorageService._privateConstructor();
  static final StorageService instance = StorageService._privateConstructor();

  Future<void> writeToken(String token) async {
    // Usamos el logger para que se vea bien en la consola del navegador.
    developer.log('Intentando escribir el token...', name: 'StorageService');
    developer.log('Token: $token', name: 'StorageService');
    
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
      developer.log('Token escrito en SharedPreferences (localStorage).', name: 'StorageService');
    } else {
      const storage = FlutterSecureStorage();
      await storage.write(key: _tokenKey, value: token);
      developer.log('Token escrito en FlutterSecureStorage.', name: 'StorageService');
    }
  }

  Future<String?> readToken() async {
    developer.log('Intentando leer el token...', name: 'StorageService');
    String? token;
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      token = prefs.getString(_tokenKey);
      developer.log('Token leído de SharedPreferences: ${token ?? "null"}', name: 'StorageService');
    } else {
      const storage = FlutterSecureStorage();
      token = await storage.read(key: _tokenKey);
      developer.log('Token leído de FlutterSecureStorage: ${token != null ? "encontrado" : "null"}', name: 'StorageService');
    }
    return token;
  }

  Future<void> deleteToken() async {
    developer.log('Intentando borrar el token...', name: 'StorageService');
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      developer.log('Token borrado de SharedPreferences.', name: 'StorageService');
    } else {
      const storage = FlutterSecureStorage();
      await storage.delete(key: _tokenKey);
      developer.log('Token borrado de FlutterSecureStorage.', name: 'StorageService');
    }
  }
}