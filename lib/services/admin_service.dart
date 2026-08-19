import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../data/dummy_data.dart';
import '../models/auth_user.dart';
import '../models/guru.dart';
import '../models/sekolah.dart';
import 'auth_service.dart';

class AdminService {
  AdminService._internal();

  static final AdminService instance = AdminService._internal();

  Future<String?> _getToken() async {
    return await AuthService.instance.getToken() ?? AppData.instance.token;
  }

  Map<String, String> _headers(String token, {bool isJson = true}) {
    final headers = <String, String>{
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    };
    if (isJson) {
      headers['Content-Type'] = 'application/json';
    }
    return headers;
  }

  // ── SEKOLAH CRUD ───────────────────────────────────────────────────────────

  /// GET /api/sekolah
  Future<ApiResponse<List<Sekolah>>> getSekolahList() async {
    final token = await _getToken();
    if (token == null || token.isEmpty) {
      return const ApiResponse<List<Sekolah>>(
        success: false,
        message: 'Token autentikasi tidak ditemukan. Silakan login kembali.',
      );
    }

    try {
      final response = await http
          .get(ApiConfig.sekolahUri, headers: _headers(token, isJson: false))
          .timeout(const Duration(seconds: 15));

      final Map<String, dynamic> responseData =
          jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 200 &&
          response.statusCode < 300 &&
          responseData['success'] == true) {
        final rawData = responseData['data'];
        List<Sekolah> list = [];
        if (rawData is List) {
          list = rawData
              .whereType<Map<String, dynamic>>()
              .map((e) => Sekolah.fromJson(e))
              .toList();
        }
        return ApiResponse<List<Sekolah>>(
          success: true,
          message: responseData['message']?.toString() ?? 'Berhasil memuat data sekolah',
          data: list,
        );
      } else {
        return ApiResponse<List<Sekolah>>(
          success: false,
          message: responseData['message']?.toString() ?? 'Gagal memuat daftar sekolah',
        );
      }
    } on SocketException {
      return const ApiResponse<List<Sekolah>>(
        success: false,
        message: 'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.',
      );
    } on TimeoutException {
      return const ApiResponse<List<Sekolah>>(
        success: false,
        message: 'Koneksi ke server timeout. Silakan coba lagi.',
      );
    } catch (e) {
      debugPrint('Error getSekolahList: $e');
      return ApiResponse<List<Sekolah>>(
        success: false,
        message: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  /// GET /api/sekolah/:id
  Future<ApiResponse<Sekolah>> getSekolahDetail(String id) async {
    final token = await _getToken();
    if (token == null || token.isEmpty) {
      return const ApiResponse<Sekolah>(
        success: false,
        message: 'Token autentikasi tidak ditemukan.',
      );
    }

    try {
      final response = await http
          .get(ApiConfig.sekolahDetailUri(id), headers: _headers(token, isJson: false))
          .timeout(const Duration(seconds: 15));

      final Map<String, dynamic> responseData =
          jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 200 &&
          response.statusCode < 300 &&
          responseData['success'] == true) {
        final dataMap = responseData['data'] as Map<String, dynamic>? ?? {};
        return ApiResponse<Sekolah>(
          success: true,
          message: responseData['message']?.toString() ?? 'Berhasil memuat detail sekolah',
          data: Sekolah.fromJson(dataMap),
        );
      } else {
        return ApiResponse<Sekolah>(
          success: false,
          message: responseData['message']?.toString() ?? 'Gagal memuat detail sekolah',
        );
      }
    } catch (e) {
      debugPrint('Error getSekolahDetail: $e');
      return ApiResponse<Sekolah>(
        success: false,
        message: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  /// POST /api/sekolah
  /// Body: { "nama_sekolah": "...", "alamat": "..." }
  Future<ApiResponse<Sekolah>> createSekolah({
    required String namaSekolah,
    required String alamat,
  }) async {
    final token = await _getToken();
    if (token == null || token.isEmpty) {
      return const ApiResponse<Sekolah>(
        success: false,
        message: 'Token autentikasi tidak ditemukan.',
      );
    }

    try {
      final response = await http
          .post(
            ApiConfig.sekolahUri,
            headers: _headers(token),
            body: jsonEncode({
              'nama_sekolah': namaSekolah.trim(),
              'alamat': alamat.trim(),
            }),
          )
          .timeout(const Duration(seconds: 15));

      final Map<String, dynamic> responseData =
          jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 200 &&
          response.statusCode < 300 &&
          responseData['success'] == true) {
        final dataMap = responseData['data'] is Map<String, dynamic>
            ? responseData['data'] as Map<String, dynamic>
            : null;

        return ApiResponse<Sekolah>(
          success: true,
          message: responseData['message']?.toString() ?? 'Sekolah berhasil ditambahkan',
          data: dataMap != null ? Sekolah.fromJson(dataMap) : null,
        );
      } else {
        return ApiResponse<Sekolah>(
          success: false,
          message: responseData['message']?.toString() ?? 'Gagal menambahkan sekolah',
        );
      }
    } catch (e) {
      debugPrint('Error createSekolah: $e');
      return ApiResponse<Sekolah>(
        success: false,
        message: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  /// PUT /api/sekolah/:id
  /// Body: { "nama_sekolah": "...", "alamat": "..." }
  Future<ApiResponse<void>> updateSekolah(
    String id, {
    required String namaSekolah,
    required String alamat,
  }) async {
    final token = await _getToken();
    if (token == null || token.isEmpty) {
      return const ApiResponse<void>(
        success: false,
        message: 'Token autentikasi tidak ditemukan.',
      );
    }

    try {
      final response = await http
          .put(
            ApiConfig.sekolahDetailUri(id),
            headers: _headers(token),
            body: jsonEncode({
              'nama_sekolah': namaSekolah.trim(),
              'alamat': alamat.trim(),
            }),
          )
          .timeout(const Duration(seconds: 15));

      final Map<String, dynamic> responseData =
          jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 200 &&
          response.statusCode < 300 &&
          responseData['success'] == true) {
        return ApiResponse<void>(
          success: true,
          message: responseData['message']?.toString() ?? 'Data sekolah berhasil diperbarui',
        );
      } else {
        return ApiResponse<void>(
          success: false,
          message: responseData['message']?.toString() ?? 'Gagal memperbarui sekolah',
        );
      }
    } catch (e) {
      debugPrint('Error updateSekolah: $e');
      return ApiResponse<void>(
        success: false,
        message: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  /// DELETE /api/sekolah/:id
  Future<ApiResponse<void>> deleteSekolah(String id) async {
    final token = await _getToken();
    if (token == null || token.isEmpty) {
      return const ApiResponse<void>(
        success: false,
        message: 'Token autentikasi tidak ditemukan.',
      );
    }

    try {
      final response = await http
          .delete(ApiConfig.sekolahDetailUri(id), headers: _headers(token, isJson: false))
          .timeout(const Duration(seconds: 15));

      final Map<String, dynamic> responseData =
          jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 200 &&
          response.statusCode < 300 &&
          responseData['success'] == true) {
        return ApiResponse<void>(
          success: true,
          message: responseData['message']?.toString() ?? 'Sekolah berhasil dihapus',
        );
      } else {
        return ApiResponse<void>(
          success: false,
          message: responseData['message']?.toString() ?? 'Gagal menghapus sekolah',
        );
      }
    } catch (e) {
      debugPrint('Error deleteSekolah: $e');
      return ApiResponse<void>(
        success: false,
        message: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  // ── GURU CRUD ──────────────────────────────────────────────────────────────

  /// GET /api/guru?page=&limit=
  Future<ApiResponse<List<Guru>>> getGuruList({int page = 1, int limit = 50}) async {
    final token = await _getToken();
    if (token == null || token.isEmpty) {
      return const ApiResponse<List<Guru>>(
        success: false,
        message: 'Token autentikasi tidak ditemukan.',
      );
    }

    try {
      final uri = ApiConfig.guruUri(page: page, limit: limit);
      final response = await http
          .get(uri, headers: _headers(token, isJson: false))
          .timeout(const Duration(seconds: 15));

      final Map<String, dynamic> responseData =
          jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 200 &&
          response.statusCode < 300 &&
          responseData['success'] == true) {
        final rawData = responseData['data'];
        List<Guru> list = [];
        if (rawData is List) {
          list = rawData
              .whereType<Map<String, dynamic>>()
              .map((e) => Guru.fromJson(e))
              .toList();
        }
        return ApiResponse<List<Guru>>(
          success: true,
          message: responseData['message']?.toString() ?? 'Berhasil memuat daftar guru',
          data: list,
        );
      } else {
        return ApiResponse<List<Guru>>(
          success: false,
          message: responseData['message']?.toString() ?? 'Gagal memuat daftar guru',
        );
      }
    } on SocketException {
      return const ApiResponse<List<Guru>>(
        success: false,
        message: 'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.',
      );
    } on TimeoutException {
      return const ApiResponse<List<Guru>>(
        success: false,
        message: 'Koneksi ke server timeout. Silakan coba lagi.',
      );
    } catch (e) {
      debugPrint('Error getGuruList: $e');
      return ApiResponse<List<Guru>>(
        success: false,
        message: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  /// GET /api/guru/:id
  Future<ApiResponse<Guru>> getGuruDetail(String id) async {
    final token = await _getToken();
    if (token == null || token.isEmpty) {
      return const ApiResponse<Guru>(
        success: false,
        message: 'Token autentikasi tidak ditemukan.',
      );
    }

    try {
      final response = await http
          .get(ApiConfig.guruDetailUri(id), headers: _headers(token, isJson: false))
          .timeout(const Duration(seconds: 15));

      final Map<String, dynamic> responseData =
          jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 200 &&
          response.statusCode < 300 &&
          responseData['success'] == true) {
        final dataMap = responseData['data'] as Map<String, dynamic>? ?? {};
        return ApiResponse<Guru>(
          success: true,
          message: responseData['message']?.toString() ?? 'Berhasil memuat detail guru',
          data: Guru.fromJson(dataMap),
        );
      } else {
        return ApiResponse<Guru>(
          success: false,
          message: responseData['message']?.toString() ?? 'Gagal memuat detail guru',
        );
      }
    } catch (e) {
      debugPrint('Error getGuruDetail: $e');
      return ApiResponse<Guru>(
        success: false,
        message: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  /// POST /api/guru
  /// Body: { "nama_guru": "...", "nim": "...", "nama_sekolah": "...", "kode_kelas": "..." }
  Future<ApiResponse<void>> createGuru({
    required String namaGuru,
    required String nim,
    required String namaSekolah,
    required String kodeKelas,
  }) async {
    final token = await _getToken();
    if (token == null || token.isEmpty) {
      return const ApiResponse<void>(
        success: false,
        message: 'Token autentikasi tidak ditemukan.',
      );
    }

    try {
      final response = await http
          .post(
            ApiConfig.guruUri(),
            headers: _headers(token),
            body: jsonEncode({
              'nama_guru': namaGuru.trim(),
              'nim': nim.trim(),
              'nama_sekolah': namaSekolah.trim(),
              'kode_kelas': kodeKelas.trim(),
            }),
          )
          .timeout(const Duration(seconds: 15));

      final Map<String, dynamic> responseData =
          jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 200 &&
          response.statusCode < 300 &&
          responseData['success'] == true) {
        return ApiResponse<void>(
          success: true,
          message: responseData['message']?.toString() ?? 'Guru berhasil ditambahkan',
        );
      } else {
        return ApiResponse<void>(
          success: false,
          message: responseData['message']?.toString() ?? 'Gagal menambahkan guru',
        );
      }
    } catch (e) {
      debugPrint('Error createGuru: $e');
      return ApiResponse<void>(
        success: false,
        message: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  /// PUT /api/guru/:id
  /// Body: { "nama_guru": "...", "nim": "...", "sekolah_id": "..." }
  Future<ApiResponse<void>> updateGuru(
    String id, {
    required String namaGuru,
    required String nim,
    required String sekolahId,
  }) async {
    final token = await _getToken();
    if (token == null || token.isEmpty) {
      return const ApiResponse<void>(
        success: false,
        message: 'Token autentikasi tidak ditemukan.',
      );
    }

    try {
      final response = await http
          .put(
            ApiConfig.guruDetailUri(id),
            headers: _headers(token),
            body: jsonEncode({
              'nama_guru': namaGuru.trim(),
              'nim': nim.trim(),
              'sekolah_id': sekolahId.trim(),
            }),
          )
          .timeout(const Duration(seconds: 15));

      final Map<String, dynamic> responseData =
          jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 200 &&
          response.statusCode < 300 &&
          responseData['success'] == true) {
        return ApiResponse<void>(
          success: true,
          message: responseData['message']?.toString() ?? 'Data guru berhasil diperbarui',
        );
      } else {
        return ApiResponse<void>(
          success: false,
          message: responseData['message']?.toString() ?? 'Gagal memperbarui data guru',
        );
      }
    } catch (e) {
      debugPrint('Error updateGuru: $e');
      return ApiResponse<void>(
        success: false,
        message: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  /// DELETE /api/guru/:id
  Future<ApiResponse<void>> deleteGuru(String id) async {
    final token = await _getToken();
    if (token == null || token.isEmpty) {
      return const ApiResponse<void>(
        success: false,
        message: 'Token autentikasi tidak ditemukan.',
      );
    }

    try {
      final response = await http
          .delete(ApiConfig.guruDetailUri(id), headers: _headers(token, isJson: false))
          .timeout(const Duration(seconds: 15));

      final Map<String, dynamic> responseData =
          jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 200 &&
          response.statusCode < 300 &&
          responseData['success'] == true) {
        return ApiResponse<void>(
          success: true,
          message: responseData['message']?.toString() ?? 'Guru berhasil dihapus',
        );
      } else {
        return ApiResponse<void>(
          success: false,
          message: responseData['message']?.toString() ?? 'Gagal menghapus guru',
        );
      }
    } catch (e) {
      debugPrint('Error deleteGuru: $e');
      return ApiResponse<void>(
        success: false,
        message: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }
}
