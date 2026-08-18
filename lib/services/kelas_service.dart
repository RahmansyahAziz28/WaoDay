import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../data/dummy_data.dart';
import '../models/auth_user.dart';
import '../models/kelas.dart';
import '../models/siswa.dart';
import 'auth_service.dart';

class KelasService {
  KelasService._internal();

  static final KelasService instance = KelasService._internal();

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

  // ── KELAS CRUD ─────────────────────────────────────────────────────────────

  /// GET /api/kelas
  Future<ApiResponse<List<Kelas>>> getKelas() async {
    final token = await _getToken();
    if (token == null || token.isEmpty) {
      return const ApiResponse<List<Kelas>>(
        success: false,
        message: 'Token autentikasi tidak ditemukan. Silakan login kembali.',
      );
    }

    try {
      final response = await http
          .get(ApiConfig.kelasUri, headers: _headers(token, isJson: false))
          .timeout(const Duration(seconds: 15));

      final Map<String, dynamic> responseData =
          jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 200 &&
          response.statusCode < 300 &&
          responseData['success'] == true) {
        final rawData = responseData['data'];
        List<Kelas> list = [];
        if (rawData is List) {
          list = rawData
              .whereType<Map<String, dynamic>>()
              .map((e) => Kelas.fromJson(e))
              .toList();
        }
        return ApiResponse<List<Kelas>>(
          success: true,
          message: responseData['message']?.toString() ?? 'Berhasil memuat kelas',
          data: list,
        );
      } else {
        return ApiResponse<List<Kelas>>(
          success: false,
          message: responseData['message']?.toString() ?? 'Gagal memuat daftar kelas',
        );
      }
    } on SocketException {
      return const ApiResponse<List<Kelas>>(
        success: false,
        message: 'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.',
      );
    } on TimeoutException {
      return const ApiResponse<List<Kelas>>(
        success: false,
        message: 'Koneksi ke server timeout. Silakan coba lagi.',
      );
    } catch (e) {
      debugPrint('Error getKelas: $e');
      return ApiResponse<List<Kelas>>(
        success: false,
        message: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  /// GET /api/kelas/:id
  Future<ApiResponse<Kelas>> getKelasDetail(String id) async {
    final token = await _getToken();
    if (token == null || token.isEmpty) {
      return const ApiResponse<Kelas>(
        success: false,
        message: 'Token autentikasi tidak ditemukan.',
      );
    }

    try {
      final response = await http
          .get(ApiConfig.kelasDetailUri(id), headers: _headers(token, isJson: false))
          .timeout(const Duration(seconds: 15));

      final Map<String, dynamic> responseData =
          jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 200 &&
          response.statusCode < 300 &&
          responseData['success'] == true) {
        final dataMap = responseData['data'] as Map<String, dynamic>? ?? {};
        final kelas = Kelas.fromJson(dataMap);
        return ApiResponse<Kelas>(
          success: true,
          message: responseData['message']?.toString() ?? 'Berhasil memuat detail kelas',
          data: kelas,
        );
      } else {
        return ApiResponse<Kelas>(
          success: false,
          message: responseData['message']?.toString() ?? 'Gagal memuat detail kelas',
        );
      }
    } catch (e) {
      debugPrint('Error getKelasDetail: $e');
      return ApiResponse<Kelas>(
        success: false,
        message: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  /// POST /api/kelas
  /// Body: { kode_kelas, nama_kelas, nama_sekolah }
  Future<ApiResponse<void>> createKelas({
    required String kodeKelas,
    required String namaKelas,
    required String namaSekolah,
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
            ApiConfig.kelasUri,
            headers: _headers(token),
            body: jsonEncode({
              'kode_kelas': kodeKelas.trim(),
              'nama_kelas': namaKelas.trim(),
              'nama_sekolah': namaSekolah.trim(),
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
          message: responseData['message']?.toString() ?? 'Kelas berhasil dibuat',
        );
      } else {
        return ApiResponse<void>(
          success: false,
          message: responseData['message']?.toString() ?? 'Gagal membuat kelas',
        );
      }
    } catch (e) {
      debugPrint('Error createKelas: $e');
      return ApiResponse<void>(
        success: false,
        message: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  /// PUT /api/kelas/:id
  /// Body: { kode_kelas, nama_kelas, sekolah_id, guru_id }
  Future<ApiResponse<void>> updateKelas({
    required String id,
    required String kodeKelas,
    required String namaKelas,
    required String sekolahId,
    required String guruId,
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
            ApiConfig.kelasDetailUri(id),
            headers: _headers(token),
            body: jsonEncode({
              'kode_kelas': kodeKelas.trim(),
              'nama_kelas': namaKelas.trim(),
              'sekolah_id': sekolahId.trim(),
              'guru_id': guruId.trim(),
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
          message: responseData['message']?.toString() ?? 'Kelas berhasil diperbarui',
        );
      } else {
        return ApiResponse<void>(
          success: false,
          message: responseData['message']?.toString() ?? 'Gagal memperbarui kelas',
        );
      }
    } catch (e) {
      debugPrint('Error updateKelas: $e');
      return ApiResponse<void>(
        success: false,
        message: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  /// DELETE /api/kelas/:id
  Future<ApiResponse<void>> deleteKelas(String id) async {
    final token = await _getToken();
    if (token == null || token.isEmpty) {
      return const ApiResponse<void>(
        success: false,
        message: 'Token autentikasi tidak ditemukan.',
      );
    }

    try {
      final response = await http
          .delete(ApiConfig.kelasDetailUri(id), headers: _headers(token, isJson: false))
          .timeout(const Duration(seconds: 15));

      final Map<String, dynamic> responseData =
          jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 200 &&
          response.statusCode < 300 &&
          responseData['success'] == true) {
        return ApiResponse<void>(
          success: true,
          message: responseData['message']?.toString() ?? 'Kelas berhasil dihapus',
        );
      } else {
        return ApiResponse<void>(
          success: false,
          message: responseData['message']?.toString() ?? 'Gagal menghapus kelas',
        );
      }
    } catch (e) {
      debugPrint('Error deleteKelas: $e');
      return ApiResponse<void>(
        success: false,
        message: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  // ── SISWA CRUD ─────────────────────────────────────────────────────────────

  /// GET /api/kelas/:id/siswa
  Future<ApiResponse<List<Siswa>>> getSiswaInKelas(String kelasId) async {
    final token = await _getToken();
    if (token == null || token.isEmpty) {
      return const ApiResponse<List<Siswa>>(
        success: false,
        message: 'Token autentikasi tidak ditemukan.',
      );
    }

    try {
      final response = await http
          .get(ApiConfig.kelasSiswaUri(kelasId), headers: _headers(token, isJson: false))
          .timeout(const Duration(seconds: 15));

      final Map<String, dynamic> responseData =
          jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 200 &&
          response.statusCode < 300 &&
          responseData['success'] == true) {
        final rawData = responseData['data'];
        List<Siswa> list = [];
        if (rawData is List) {
          list = rawData
              .whereType<Map<String, dynamic>>()
              .map((e) => Siswa.fromJson(e))
              .toList();
        }
        return ApiResponse<List<Siswa>>(
          success: true,
          message: responseData['message']?.toString() ?? 'Berhasil memuat daftar siswa',
          data: list,
        );
      } else {
        return ApiResponse<List<Siswa>>(
          success: false,
          message: responseData['message']?.toString() ?? 'Gagal memuat daftar siswa',
        );
      }
    } catch (e) {
      debugPrint('Error getSiswaInKelas: $e');
      return ApiResponse<List<Siswa>>(
        success: false,
        message: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  /// POST /api/siswa
  /// Body: { nama_siswa, nis, nama_sekolah, kode_kelas }
  Future<ApiResponse<void>> createSiswa({
    required String namaSiswa,
    required String nis,
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
            ApiConfig.siswaUri,
            headers: _headers(token),
            body: jsonEncode({
              'nama_siswa': namaSiswa.trim(),
              'nis': nis.trim(),
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
          message: responseData['message']?.toString() ?? 'Siswa berhasil ditambahkan',
        );
      } else {
        return ApiResponse<void>(
          success: false,
          message: responseData['message']?.toString() ?? 'Gagal menambahkan siswa',
        );
      }
    } catch (e) {
      debugPrint('Error createSiswa: $e');
      return ApiResponse<void>(
        success: false,
        message: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  /// PUT /api/siswa/:id
  /// Body: { nama_siswa, nis, sekolah_id }
  Future<ApiResponse<void>> updateSiswa({
    required String id,
    required String namaSiswa,
    required String nis,
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
            ApiConfig.siswaDetailUri(id),
            headers: _headers(token),
            body: jsonEncode({
              'nama_siswa': namaSiswa.trim(),
              'nis': nis.trim(),
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
          message: responseData['message']?.toString() ?? 'Data siswa berhasil diperbarui',
        );
      } else {
        return ApiResponse<void>(
          success: false,
          message: responseData['message']?.toString() ?? 'Gagal memperbarui data siswa',
        );
      }
    } catch (e) {
      debugPrint('Error updateSiswa: $e');
      return ApiResponse<void>(
        success: false,
        message: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  /// DELETE /api/siswa/:id
  Future<ApiResponse<void>> deleteSiswa(String id) async {
    final token = await _getToken();
    if (token == null || token.isEmpty) {
      return const ApiResponse<void>(
        success: false,
        message: 'Token autentikasi tidak ditemukan.',
      );
    }

    try {
      final response = await http
          .delete(ApiConfig.siswaDetailUri(id), headers: _headers(token, isJson: false))
          .timeout(const Duration(seconds: 15));

      final Map<String, dynamic> responseData =
          jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 200 &&
          response.statusCode < 300 &&
          responseData['success'] == true) {
        return ApiResponse<void>(
          success: true,
          message: responseData['message']?.toString() ?? 'Siswa berhasil dihapus',
        );
      } else {
        return ApiResponse<void>(
          success: false,
          message: responseData['message']?.toString() ?? 'Gagal menghapus siswa',
        );
      }
    } catch (e) {
      debugPrint('Error deleteSiswa: $e');
      return ApiResponse<void>(
        success: false,
        message: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }
}
