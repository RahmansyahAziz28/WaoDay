import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config/api_config.dart';
import '../data/dummy_data.dart';
import '../models/auth_user.dart';

class AuthService {
  AuthService._internal();

  static final AuthService instance = AuthService._internal();

  static const String _keyToken = 'auth_token';
  static const String _keyRefreshToken = 'auth_refresh_token';
  static const String _keyUser = 'auth_user';

  Future<ApiResponse<AuthData>> login({
    String? identifier,
    String? email,
    required String password,
  }) async {
    final loginIdentifier = (identifier ?? email ?? '').trim();
    try {
      final response = await http
          .post(
            ApiConfig.loginUri,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'identifier': loginIdentifier,
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 15));

      final Map<String, dynamic> responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 200 && response.statusCode < 300 && responseData['success'] == true) {
        final authData = AuthData.fromJson(responseData['data'] as Map<String, dynamic>? ?? {});

        await _saveSession(authData);
        AppData.instance.setAuthData(authData);

        return ApiResponse<AuthData>(
          success: true,
          message: responseData['message']?.toString() ?? 'Login berhasil',
          data: authData,
        );
      } else {
        return ApiResponse<AuthData>(
          success: false,
          message: responseData['message']?.toString() ?? 'Email atau password salah',
        );
      }
    } on SocketException {
      return const ApiResponse<AuthData>(
        success: false,
        message: 'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.',
      );
    } on TimeoutException {
      return const ApiResponse<AuthData>(
        success: false,
        message: 'Koneksi ke server time out. Silakan coba lagi.',
      );
    } catch (e) {
      debugPrint('Error login: $e');
      return ApiResponse<AuthData>(
        success: false,
        message: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  Future<ApiResponse<void>> logout() async {
    final token = await getToken() ?? AppData.instance.token;

    if (token != null && token.isNotEmpty) {
      try {
        await http.post(
          ApiConfig.logoutUri,
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ).timeout(const Duration(seconds: 10));
      } catch (e) {
        debugPrint('Logout API request error: $e');
      }
    }

    await _clearSession();
    AppData.instance.clearAuth();

    return const ApiResponse<void>(
      success: true,
      message: 'Berhasil keluar',
    );
  }

  Future<void> _saveSession(AuthData authData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, authData.token);
    if (authData.refreshToken != null) {
      await prefs.setString(_keyRefreshToken, authData.refreshToken!);
    }
    await prefs.setString(_keyUser, jsonEncode(authData.user.toJson()));
  }

  Future<void> _clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
    await prefs.remove(_keyRefreshToken);
    await prefs.remove(_keyUser);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  Future<AuthData?> restoreSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_keyToken);
      final userJsonStr = prefs.getString(_keyUser);
      final refreshToken = prefs.getString(_keyRefreshToken);

      if (token != null && token.isNotEmpty && userJsonStr != null) {
        final userMap = jsonDecode(userJsonStr) as Map<String, dynamic>;
        final user = UserModel.fromJson(userMap);
        final authData = AuthData(
          token: token,
          refreshToken: refreshToken,
          user: user,
        );

        AppData.instance.setAuthData(authData);
        return authData;
      }
    } catch (e) {
      debugPrint('Error restoring session: $e');
    }
    return null;
  }
}
