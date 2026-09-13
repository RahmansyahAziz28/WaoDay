import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../config/api_config.dart';
import '../data/dummy_data.dart';
import '../models/auth_user.dart';
import '../models/game_token.dart';
import '../models/materi.dart';
import 'api_client.dart';
import 'auth_service.dart';

class GameTokenService {
  GameTokenService._internal();

  static final GameTokenService instance = GameTokenService._internal();

  Future<String?> _getToken() async {
    return await AuthService.instance.getToken() ?? AppData.instance.token;
  }

  /// GET /api/materi?tingkat_kelas={tingkat}&semester={selectedSemester}
  Future<ApiResponse<List<MateriBab>>> getMateri({
    required int tingkatKelas,
    required int semester,
    String? mataPelajaran,
  }) async {
    final token = await _getToken();
    if (token == null || token.isEmpty) {
      return const ApiResponse<List<MateriBab>>(
        success: false,
        message: 'Token autentikasi tidak ditemukan. Silakan login kembali.',
      );
    }

    try {
      final uri = ApiConfig.materiUri(
        tingkatKelas: tingkatKelas,
        semester: semester,
        mataPelajaran: mataPelajaran,
      );

      final response = await ApiClient.instance.get(uri, token: token);

      if (response.statusCode == 401) {
        return const ApiResponse<List<MateriBab>>(
          success: false,
          message: 'Sesi login telah berakhir. Silakan login kembali.',
        );
      }

      final Map<String, dynamic> responseData =
          jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 200 &&
          response.statusCode < 300 &&
          responseData['success'] == true) {
        final rawData = responseData['data'];
        List<MateriBab> list = [];
        if (rawData is List) {
          list = rawData
              .whereType<Map<String, dynamic>>()
              .map((e) => MateriBab.fromJson(e))
              .toList();
        }
        return ApiResponse<List<MateriBab>>(
          success: true,
          message: responseData['message']?.toString() ?? 'Berhasil memuat materi',
          data: list,
        );
      } else {
        return ApiResponse<List<MateriBab>>(
          success: false,
          message: responseData['message']?.toString() ?? 'Gagal memuat materi',
        );
      }
    } on SocketException {
      return const ApiResponse<List<MateriBab>>(
        success: false,
        message: 'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.',
      );
    } on TimeoutException {
      return const ApiResponse<List<MateriBab>>(
        success: false,
        message: 'Koneksi ke server timeout. Silakan coba lagi.',
      );
    } catch (e) {
      debugPrint('Error getMateri: $e');
      return ApiResponse<List<MateriBab>>(
        success: false,
        message: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  /// POST /api/game/token
  /// Body:
  /// {
  ///   "nama_sesi": String,
  ///   "kelas_id": String,
  ///   "semester": int,
  ///   "materi_bab_ids": List of String,
  ///   "acak": bool,
  ///   "izinkan_offline": bool,
  ///   "berlaku_sampai": String (ISO 8601, opsional)
  /// }
  Future<ApiResponse<Map<String, dynamic>>> createGameToken({
    required String namaSesi,
    required String kelasId,
    required int semester,
    required List<String> materiBabIds,
    required bool acak,
    required bool izinkanOffline,
    DateTime? berlakuSampai,
  }) async {
    final token = await _getToken();
    if (token == null || token.isEmpty) {
      return const ApiResponse<Map<String, dynamic>>(
        success: false,
        message: 'Token autentikasi tidak ditemukan. Silakan login kembali.',
      );
    }

    try {
      final Map<String, dynamic> bodyMap = {
        'nama_sesi': namaSesi.trim(),
        'kelas_id': kelasId.trim(),
        'semester': semester,
        'materi_bab_ids': materiBabIds,
        'acak': acak,
        'izinkan_offline': izinkanOffline,
      };

      if (berlakuSampai != null) {
        bodyMap['berlaku_sampai'] = berlakuSampai.toIso8601String();
      }

      final response = await ApiClient.instance.post(
        ApiConfig.gameTokenUri,
        token: token,
        body: jsonEncode(bodyMap),
      );

      if (response.statusCode == 401) {
        return const ApiResponse<Map<String, dynamic>>(
          success: false,
          message: 'Sesi login telah berakhir. Silakan login kembali.',
        );
      }

      final Map<String, dynamic> responseData =
          jsonDecode(response.body) as Map<String, dynamic>;

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          responseData['success'] == true) {
        final data = responseData['data'] is Map<String, dynamic>
            ? responseData['data'] as Map<String, dynamic>
            : <String, dynamic>{};
        return ApiResponse<Map<String, dynamic>>(
          success: true,
          message: responseData['message']?.toString() ?? 'Token ujian berhasil dibuat',
          data: data,
        );
      } else {
        // Collect express-validator errors or message
        String errMsg = responseData['message']?.toString() ?? 'Gagal membuat token ujian';
        if (responseData['errors'] is List) {
          final errList = responseData['errors'] as List;
          final msgs = errList
              .map((e) => e is Map ? e['msg']?.toString() ?? '' : e.toString())
              .where((m) => m.isNotEmpty)
              .toList();
          if (msgs.isNotEmpty) {
            errMsg = msgs.join(', ');
          }
        }
        return ApiResponse<Map<String, dynamic>>(
          success: false,
          message: errMsg,
        );
      }
    } on SocketException {
      return const ApiResponse<Map<String, dynamic>>(
        success: false,
        message: 'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.',
      );
    } on TimeoutException {
      return const ApiResponse<Map<String, dynamic>>(
        success: false,
        message: 'Koneksi ke server timeout. Silakan coba lagi.',
      );
    } catch (e) {
      debugPrint('Error createGameToken: $e');
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  /// GET /api/game/token?kelas_id={kelas.id}
  Future<ApiResponse<List<GameTokenItem>>> getTokensByKelas(String kelasId) async {
    final token = await _getToken();
    if (token == null || token.isEmpty) {
      return const ApiResponse<List<GameTokenItem>>(
        success: false,
        message: 'Token autentikasi tidak ditemukan. Silakan login kembali.',
      );
    }

    try {
      final uri = ApiConfig.gameTokensByKelasUri(kelasId);
      final response = await ApiClient.instance.get(uri, token: token);

      if (response.statusCode == 401) {
        return const ApiResponse<List<GameTokenItem>>(
          success: false,
          message: 'Sesi login telah berakhir. Silakan login kembali.',
        );
      }

      final Map<String, dynamic> responseData =
          jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 200 &&
          response.statusCode < 300 &&
          responseData['success'] == true) {
        final rawData = responseData['data'];
        List<GameTokenItem> list = [];
        if (rawData is List) {
          list = rawData
              .whereType<Map<String, dynamic>>()
              .map((e) => GameTokenItem.fromJson(e))
              .toList();
        }
        return ApiResponse<List<GameTokenItem>>(
          success: true,
          message: responseData['message']?.toString() ?? 'Berhasil memuat token kelas',
          data: list,
        );
      } else {
        return ApiResponse<List<GameTokenItem>>(
          success: false,
          message: responseData['message']?.toString() ?? 'Gagal memuat token kelas',
        );
      }
    } on SocketException {
      return const ApiResponse<List<GameTokenItem>>(
        success: false,
        message: 'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.',
      );
    } on TimeoutException {
      return const ApiResponse<List<GameTokenItem>>(
        success: false,
        message: 'Koneksi ke server timeout. Silakan coba lagi.',
      );
    } catch (e) {
      debugPrint('Error getTokensByKelas: $e');
      return ApiResponse<List<GameTokenItem>>(
        success: false,
        message: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  /// GET /api/game/token/{tokenId}/nilai?kkm=70
  Future<ApiResponse<RekapNilaiData>> getRekapNilai(
    String tokenId, {
    int kkm = 70,
  }) async {
    final token = await _getToken();
    if (token == null || token.isEmpty) {
      return const ApiResponse<RekapNilaiData>(
        success: false,
        message: 'Token autentikasi tidak ditemukan. Silakan login kembali.',
      );
    }

    try {
      final uri = ApiConfig.gameTokenNilaiUri(tokenId, kkm: kkm);
      final response = await ApiClient.instance.get(uri, token: token);

      if (response.statusCode == 401) {
        return const ApiResponse<RekapNilaiData>(
          success: false,
          message: 'Sesi login telah berakhir. Silakan login kembali.',
        );
      }

      final Map<String, dynamic> responseData =
          jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 200 &&
          response.statusCode < 300 &&
          responseData['success'] == true) {
        final dataMap = responseData['data'] is Map<String, dynamic>
            ? responseData['data'] as Map<String, dynamic>
            : <String, dynamic>{};
        final rekap = RekapNilaiData.fromJson(dataMap);
        return ApiResponse<RekapNilaiData>(
          success: true,
          message: responseData['message']?.toString() ?? 'Berhasil memuat rekap nilai',
          data: rekap,
        );
      } else {
        return ApiResponse<RekapNilaiData>(
          success: false,
          message: responseData['message']?.toString() ?? 'Gagal memuat rekap nilai ujian',
        );
      }
    } on SocketException {
      return const ApiResponse<RekapNilaiData>(
        success: false,
        message: 'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.',
      );
    } on TimeoutException {
      return const ApiResponse<RekapNilaiData>(
        success: false,
        message: 'Koneksi ke server timeout. Silakan coba lagi.',
      );
    } catch (e) {
      debugPrint('Error getRekapNilai: $e');
      return ApiResponse<RekapNilaiData>(
        success: false,
        message: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }
}
